import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import * as bcrypt from 'bcrypt';
import { loginSchema } from '../utils/validation';
import { handleError, UnauthorizedError, OrganizationInactiveError } from '../utils/errors';
import { setCustomClaims } from '../utils/auth';

export const loginUser = onCall(async (request) => {
  try {
    // Validate input
    const validationResult = loginSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new HttpsError('invalid-argument', validationResult.error.errors[0].message);
    }

    const { usernameOrEmail, password } = validationResult.data;
    const db = admin.firestore();

    // Find user by username or email across all organizations
    const usersSnapshot = await db.collectionGroup('users')
      .where('username', '==', usernameOrEmail)
      .limit(1)
      .get();

    let userDoc = usersSnapshot.docs[0];

    // If not found by username, try email
    if (!userDoc) {
      const emailSnapshot = await db.collectionGroup('users')
        .where('email', '==', usernameOrEmail)
        .limit(1)
        .get();
      userDoc = emailSnapshot.docs[0];
    }

    if (!userDoc) {
      throw new UnauthorizedError('Invalid credentials');
    }

    const userData = userDoc.data();
    const organizationId = userDoc.ref.parent.parent?.id;

    if (!organizationId) {
      throw new UnauthorizedError('Invalid user data');
    }

    // Check if user is active
    if (!userData.active) {
      throw new UnauthorizedError('Account is deactivated');
    }

    // Get organization
    const orgDoc = await db.collection('organizations').doc(organizationId).get();
    if (!orgDoc.exists) {
      throw new UnauthorizedError('Organization not found');
    }

    const orgData = orgDoc.data()!;

    // Check if organization is active
    if (!orgData.isActive) {
      throw new OrganizationInactiveError('Your organization has been deactivated. Please contact support.');
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, userData.passwordHash);
    if (!isValidPassword) {
      throw new UnauthorizedError('Invalid credentials');
    }

    // Get or create Firebase Auth user
    let firebaseUser;
    try {
      firebaseUser = await admin.auth().getUserByEmail(userData.email);
    } catch {
      // Create Firebase Auth user if doesn't exist
      firebaseUser = await admin.auth().createUser({
        uid: userDoc.id,
        email: userData.email,
        displayName: userData.name,
      });
    }

    // Set custom claims
    await setCustomClaims(firebaseUser.uid, organizationId, userData.role, userData.email);

    // Create custom token
    const customToken = await admin.auth().createCustomToken(firebaseUser.uid);

    // Get visible topic IDs for guest users
    const visibleTopicIds: string[] = userData.visibleTopicIds || [];

    return {
      customToken,
      user: {
        id: userDoc.id,
        organizationId,
        name: userData.name,
        username: userData.username,
        email: userData.email,
        avatar: userData.avatar || null,
        role: userData.role,
        active: userData.active,
        visibleTopicIds,
        createdAt: userData.createdAt?.toDate?.()?.toISOString() || null,
        updatedAt: userData.updatedAt?.toDate?.()?.toISOString() || null,
      },
      organization: {
        id: organizationId,
        name: orgData.name,
        teamName: orgData.teamName,
        slug: orgData.slug,
        isActive: orgData.isActive,
        maxUsers: orgData.maxUsers,
        createdAt: orgData.createdAt?.toDate?.()?.toISOString() || null,
        updatedAt: orgData.updatedAt?.toDate?.()?.toISOString() || null,
      },
    };
  } catch (error) {
    throw handleError(error);
  }
});
