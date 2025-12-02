import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import * as bcrypt from 'bcrypt';
import { registerTeamSchema } from '../utils/validation';
import { handleError, ConflictError, ValidationError } from '../utils/errors';
import { setCustomClaims } from '../utils/auth';

function generateSlug(companyName: string, teamName: string): string {
  const combined = `${companyName}-${teamName}`;
  return combined
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, '')
    .replace(/[\s_-]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

async function ensureUniqueSlug(db: FirebaseFirestore.Firestore, baseSlug: string): Promise<string> {
  let slug = baseSlug;
  let counter = 1;

  while (true) {
    const existing = await db.collection('organizations')
      .where('slug', '==', slug)
      .limit(1)
      .get();

    if (existing.empty) {
      return slug;
    }

    slug = `${baseSlug}-${counter}`;
    counter++;
  }
}

async function isEmailTaken(db: FirebaseFirestore.Firestore, email: string): Promise<boolean> {
  const snapshot = await db.collectionGroup('users')
    .where('email', '==', email)
    .limit(1)
    .get();
  return !snapshot.empty;
}

async function isUsernameTaken(db: FirebaseFirestore.Firestore, username: string): Promise<boolean> {
  const snapshot = await db.collectionGroup('users')
    .where('username', '==', username)
    .limit(1)
    .get();
  return !snapshot.empty;
}

export const registerTeam = onCall(async (request) => {
  try {
    // Validate input
    const validationResult = registerTeamSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new HttpsError('invalid-argument', validationResult.error.errors[0].message);
    }

    const { companyName, teamName, managerName, username, email, password } = validationResult.data;
    const db = admin.firestore();

    // Check email uniqueness
    if (await isEmailTaken(db, email)) {
      throw new ConflictError('Email is already registered');
    }

    // Check username uniqueness
    if (await isUsernameTaken(db, username)) {
      throw new ConflictError('Username is already taken');
    }

    // Generate unique slug
    const baseSlug = generateSlug(companyName, teamName);
    if (!baseSlug) {
      throw new ValidationError('Could not generate valid slug from company and team names');
    }
    const slug = await ensureUniqueSlug(db, baseSlug);

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    const now = admin.firestore.FieldValue.serverTimestamp();

    // Create organization and user in batch
    const batch = db.batch();

    // Create organization
    const orgRef = db.collection('organizations').doc();
    batch.set(orgRef, {
      name: companyName,
      teamName,
      slug,
      isActive: true,
      maxUsers: 15,
      createdAt: now,
      updatedAt: now,
    });

    // Create team manager user
    const userRef = orgRef.collection('users').doc();
    batch.set(userRef, {
      name: managerName,
      username,
      email,
      passwordHash,
      avatar: null,
      role: 'TEAM_MANAGER',
      active: true,
      visibleTopicIds: [],
      createdAt: now,
      updatedAt: now,
    });

    await batch.commit();

    // Create Firebase Auth user
    const firebaseUser = await admin.auth().createUser({
      uid: userRef.id,
      email,
      displayName: managerName,
    });

    // Set custom claims
    await setCustomClaims(firebaseUser.uid, orgRef.id, 'TEAM_MANAGER', email);

    // Create custom token
    const customToken = await admin.auth().createCustomToken(firebaseUser.uid);

    // Get created documents for response
    const [orgDoc, userDoc] = await Promise.all([
      orgRef.get(),
      userRef.get(),
    ]);

    const orgData = orgDoc.data()!;
    const userData = userDoc.data()!;

    return {
      customToken,
      organization: {
        id: orgRef.id,
        name: orgData.name,
        teamName: orgData.teamName,
        slug: orgData.slug,
        isActive: orgData.isActive,
        maxUsers: orgData.maxUsers,
        createdAt: orgData.createdAt?.toDate?.()?.toISOString() || new Date().toISOString(),
        updatedAt: orgData.updatedAt?.toDate?.()?.toISOString() || new Date().toISOString(),
      },
      user: {
        id: userRef.id,
        organizationId: orgRef.id,
        name: userData.name,
        username: userData.username,
        email: userData.email,
        avatar: null,
        role: userData.role,
        active: userData.active,
        visibleTopicIds: [],
        createdAt: userData.createdAt?.toDate?.()?.toISOString() || new Date().toISOString(),
        updatedAt: userData.updatedAt?.toDate?.()?.toISOString() || new Date().toISOString(),
      },
    };
  } catch (error) {
    throw handleError(error);
  }
});
