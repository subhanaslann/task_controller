import { onCall } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { handleError, ValidationError, NotFoundError } from '../utils/errors';
import { requireAuth, requireTeamManager } from '../utils/auth';
import { z } from 'zod';

const deleteUserSchema = z.object({
  userId: z.string().min(1),
});

export const deleteUser = onCall(async (request) => {
  try {
    const context = await requireAuth(request);
    requireTeamManager(context);

    const validationResult = deleteUserSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new ValidationError(validationResult.error.errors[0].message);
    }

    const { userId } = validationResult.data;
    const db = admin.firestore();
    const { organizationId } = context;

    const userRef = db
      .collection('organizations').doc(organizationId)
      .collection('users').doc(userId);

    const userDoc = await userRef.get();
    if (!userDoc.exists) {
      throw new NotFoundError('User not found');
    }

    const userData = userDoc.data()!;

    // Soft delete: deactivate the user
    await userRef.update({
      active: false,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Remove from topic accessControl if guest
    if (userData.role === 'GUEST' && userData.visibleTopicIds?.length > 0) {
      const batch = db.batch();
      for (const topicId of userData.visibleTopicIds) {
        const topicRef = db
          .collection('organizations').doc(organizationId)
          .collection('topics').doc(topicId);
        batch.update(topicRef, {
          [`accessControl.${userId}`]: admin.firestore.FieldValue.delete(),
        });
      }
      await batch.commit();
    }

    return { success: true, message: 'User deactivated successfully' };
  } catch (error) {
    throw handleError(error);
  }
});
