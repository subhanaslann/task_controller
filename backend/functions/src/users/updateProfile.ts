import { onCall } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import * as bcrypt from 'bcrypt';
import { updateProfileSchema } from '../utils/validation';
import { handleError, ValidationError, NotFoundError } from '../utils/errors';
import { requireAuth } from '../utils/auth';

export const updateProfile = onCall(async (request) => {
  try {
    const context = await requireAuth(request);

    const validationResult = updateProfileSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new ValidationError(validationResult.error.errors[0].message);
    }

    const { name, avatar, password } = validationResult.data;
    const db = admin.firestore();
    const { organizationId, uid } = context;

    const userRef = db
      .collection('organizations').doc(organizationId)
      .collection('users').doc(uid);

    const userDoc = await userRef.get();
    if (!userDoc.exists) {
      throw new NotFoundError('User not found');
    }

    const updateData: Record<string, unknown> = {
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (name !== undefined) updateData.name = name;
    if (avatar !== undefined) updateData.avatar = avatar;
    if (password !== undefined) {
      updateData.passwordHash = await bcrypt.hash(password, 10);
    }

    await userRef.update(updateData);

    // Update Firebase Auth displayName if name changed
    if (name !== undefined) {
      try {
        await admin.auth().updateUser(uid, { displayName: name });
      } catch (authError) {
        console.warn('Could not update Firebase Auth displayName:', authError);
      }
    }

    const updatedDoc = await userRef.get();
    const data = updatedDoc.data()!;

    return {
      id: uid,
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
