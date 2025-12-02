import { onCall } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import * as bcrypt from 'bcrypt';
import { updateUserSchema } from '../utils/validation';
import {
  handleError,
  ValidationError,
  NotFoundError,
  OrganizationUserLimitReachedError
} from '../utils/errors';
import { requireAuth, requireTeamManager, setCustomClaims } from '../utils/auth';

async function checkActiveUserLimit(
  db: FirebaseFirestore.Firestore,
  organizationId: string,
  excludeUserId?: string
): Promise<void> {
  const orgDoc = await db.collection('organizations').doc(organizationId).get();
  if (!orgDoc.exists) {
    throw new NotFoundError('Organization not found');
  }

  const orgData = orgDoc.data()!;
  const maxUsers = orgData.maxUsers || 15;

  const query = db
    .collection('organizations').doc(organizationId)
    .collection('users')
    .where('active', '==', true);

  const activeUsersSnapshot = await query.get();
  let count = activeUsersSnapshot.size;

  // Exclude current user from count if provided
  if (excludeUserId) {
    const isCurrentUserActive = activeUsersSnapshot.docs.some(doc => doc.id === excludeUserId);
    if (isCurrentUserActive) {
      count--;
    }
  }

  if (count >= maxUsers) {
    throw new OrganizationUserLimitReachedError(maxUsers);
  }
}

export const updateUser = onCall(async (request) => {
  try {
    const context = await requireAuth(request);
    requireTeamManager(context);

    const validationResult = updateUserSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new ValidationError(validationResult.error.errors[0].message);
    }

    const { userId, name, role, active, password, visibleTopicIds } = validationResult.data;
    const db = admin.firestore();
    const { organizationId } = context;

    const userRef = db
      .collection('organizations').doc(organizationId)
      .collection('users').doc(userId);

    const userDoc = await userRef.get();
    if (!userDoc.exists) {
      throw new NotFoundError('User not found');
    }

    const existingData = userDoc.data()!;

    // If activating a currently inactive user, check limit
    if (active === true && !existingData.active) {
      await checkActiveUserLimit(db, organizationId, userId);
    }

    const updateData: Record<string, unknown> = {
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (name !== undefined) updateData.name = name;
    if (role !== undefined) updateData.role = role;
    if (active !== undefined) updateData.active = active;
    if (password !== undefined) {
      updateData.passwordHash = await bcrypt.hash(password, 10);
    }

    // Handle visibleTopicIds for guest users
    const newRole = role ?? existingData.role;
    if (visibleTopicIds !== undefined && newRole === 'GUEST') {
      updateData.visibleTopicIds = visibleTopicIds;

      // Update topic accessControl
      const batch = db.batch();

      // Remove from old topics
      const oldTopicIds = existingData.visibleTopicIds || [];
      for (const topicId of oldTopicIds) {
        if (!visibleTopicIds.includes(topicId)) {
          const topicRef = db
            .collection('organizations').doc(organizationId)
            .collection('topics').doc(topicId);
          batch.update(topicRef, {
            [`accessControl.${userId}`]: admin.firestore.FieldValue.delete(),
          });
        }
      }

      // Add to new topics
      for (const topicId of visibleTopicIds) {
        if (!oldTopicIds.includes(topicId)) {
          const topicRef = db
            .collection('organizations').doc(organizationId)
            .collection('topics').doc(topicId);
          batch.update(topicRef, {
            [`accessControl.${userId}`]: 'guest',
          });
        }
      }

      await batch.commit();
    }

    // If role changed from GUEST to something else, clear visibleTopicIds
    if (role !== undefined && role !== 'GUEST' && existingData.role === 'GUEST') {
      updateData.visibleTopicIds = [];

      // Remove from all topics
      const batch = db.batch();
      const oldTopicIds = existingData.visibleTopicIds || [];
      for (const topicId of oldTopicIds) {
        const topicRef = db
          .collection('organizations').doc(organizationId)
          .collection('topics').doc(topicId);
        batch.update(topicRef, {
          [`accessControl.${userId}`]: admin.firestore.FieldValue.delete(),
        });
      }
      await batch.commit();
    }

    await userRef.update(updateData);

    // Update Firebase Auth custom claims if role changed
    if (role !== undefined && role !== existingData.role) {
      try {
        await setCustomClaims(userId, organizationId, role, existingData.email);
      } catch (authError) {
        console.warn('Could not update Firebase Auth claims:', authError);
      }
    }

    const updatedDoc = await userRef.get();
    const data = updatedDoc.data()!;

    return {
      id: userId,
      organizationId,
      name: data.name,
      username: data.username,
      email: data.email,
      avatar: data.avatar,
      role: data.role,
      active: data.active,
      visibleTopicIds: data.visibleTopicIds || [],
      createdAt: data.createdAt?.toDate?.()?.toISOString() || null,
      updatedAt: data.updatedAt?.toDate?.()?.toISOString() || new Date().toISOString(),
    };
  } catch (error) {
    throw handleError(error);
  }
});
