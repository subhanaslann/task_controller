import { onCall } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import * as bcrypt from 'bcrypt';
import { createUserSchema } from '../utils/validation';
import {
  handleError,
  ValidationError,
  ForbiddenError,
  ConflictError,
  OrganizationUserLimitReachedError,
  NotFoundError
} from '../utils/errors';
import { requireAuth, requireTeamManagerOrAdmin, setCustomClaims } from '../utils/auth';

async function checkActiveUserLimit(
  db: FirebaseFirestore.Firestore,
  organizationId: string
): Promise<void> {
  const orgDoc = await db.collection('organizations').doc(organizationId).get();
  if (!orgDoc.exists) {
    throw new NotFoundError('Organization not found');
  }

  const orgData = orgDoc.data()!;
  const maxUsers = orgData.maxUsers || 15;

  const activeUsersSnapshot = await db
    .collection('organizations').doc(organizationId)
    .collection('users')
    .where('active', '==', true)
    .get();

  if (activeUsersSnapshot.size >= maxUsers) {
    throw new OrganizationUserLimitReachedError(maxUsers);
  }
}

export const createUser = onCall(async (request) => {
  try {
    const context = await requireAuth(request);
    requireTeamManagerOrAdmin(context);

    const validationResult = createUserSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new ValidationError(validationResult.error.errors[0].message);
    }

    const { name, username, email, password, role, active, visibleTopicIds } = validationResult.data;
    const db = admin.firestore();
    const { organizationId } = context;

    // Permission checks
    if (context.role === 'TEAM_MANAGER' && role === 'ADMIN') {
      throw new ForbiddenError('Team Managers cannot create Admin users');
    }
    if (context.role === 'TEAM_MANAGER' && role === 'TEAM_MANAGER') {
      throw new ForbiddenError('Team Managers cannot create other Team Manager users');
    }

    // Check user limit if creating active user
    if (active !== false) {
      await checkActiveUserLimit(db, organizationId);
    }

    // Check email uniqueness within organization
    const emailCheck = await db
      .collection('organizations').doc(organizationId)
      .collection('users')
      .where('email', '==', email)
      .limit(1)
      .get();

    if (!emailCheck.empty) {
      throw new ConflictError('Email is already registered in this organization');
    }

    // Check username uniqueness within organization
    const usernameCheck = await db
      .collection('organizations').doc(organizationId)
      .collection('users')
      .where('username', '==', username)
      .limit(1)
      .get();

    if (!usernameCheck.empty) {
      throw new ConflictError('Username is already taken in this organization');
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    const now = admin.firestore.FieldValue.serverTimestamp();
    const userRef = db
      .collection('organizations').doc(organizationId)
      .collection('users').doc();

    const userData = {
      name,
      username,
      email,
      passwordHash,
      avatar: null,
      role,
      active: active ?? true,
      visibleTopicIds: role === 'GUEST' ? (visibleTopicIds || []) : [],
      createdAt: now,
      updatedAt: now,
    };

    await userRef.set(userData);

    // If active user, create Firebase Auth user
    if (active !== false) {
      try {
        const firebaseUser = await admin.auth().createUser({
          uid: userRef.id,
          email,
          displayName: name,
        });
        await setCustomClaims(firebaseUser.uid, organizationId, role, email);
      } catch (authError) {
        console.warn('Could not create Firebase Auth user:', authError);
      }
    }

    // Update topic accessControl for guest users
    if (role === 'GUEST' && visibleTopicIds && visibleTopicIds.length > 0) {
      const batch = db.batch();
      for (const topicId of visibleTopicIds) {
        const topicRef = db
          .collection('organizations').doc(organizationId)
          .collection('topics').doc(topicId);
        batch.update(topicRef, {
          [`accessControl.${userRef.id}`]: 'guest',
        });
      }
      await batch.commit();
    }

    const createdDoc = await userRef.get();
    const data = createdDoc.data()!;

    return {
      id: userRef.id,
      organizationId,
      name: data.name,
      username: data.username,
      email: data.email,
      avatar: data.avatar,
      role: data.role,
      active: data.active,
      visibleTopicIds: data.visibleTopicIds || [],
      createdAt: data.createdAt?.toDate?.()?.toISOString() || new Date().toISOString(),
      updatedAt: data.updatedAt?.toDate?.()?.toISOString() || new Date().toISOString(),
    };
  } catch (error) {
    throw handleError(error);
  }
});
