import { onCall } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { deleteTopicSchema } from '../utils/validation';
import { handleError, ValidationError, NotFoundError } from '../utils/errors';
import { requireAuth, requireTeamManager } from '../utils/auth';

export const deleteTopic = onCall(async (request) => {
  try {
    const context = await requireAuth(request);
    requireTeamManager(context);

    const validationResult = deleteTopicSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new ValidationError(validationResult.error.errors[0].message);
    }

    const { topicId } = validationResult.data;
    const db = admin.firestore();
    const { organizationId } = context;

    const topicRef = db
      .collection('organizations').doc(organizationId)
      .collection('topics').doc(topicId);

    const topicDoc = await topicRef.get();
    if (!topicDoc.exists) {
      throw new NotFoundError('Topic not found');
    }

    const topicData = topicDoc.data()!;

    // Get all tasks in this topic and update them
    const tasksSnapshot = await db
      .collection('organizations').doc(organizationId)
      .collection('tasks')
      .where('topicId', '==', topicId)
      .get();

    const batch = db.batch();

    // Set topicId to null for all tasks in this topic
    tasksSnapshot.docs.forEach(taskDoc => {
      batch.update(taskDoc.ref, { topicId: null });
    });

    // Remove visibleTopicIds from guest users who had access
    const accessControl = topicData.accessControl || {};
    const guestUserIds = Object.keys(accessControl);

    for (const userId of guestUserIds) {
      const userRef = db
        .collection('organizations').doc(organizationId)
        .collection('users').doc(userId);
      batch.update(userRef, {
        visibleTopicIds: admin.firestore.FieldValue.arrayRemove(topicId),
      });
    }

    // Delete the topic
    batch.delete(topicRef);

    await batch.commit();

    return { success: true, message: 'Topic deleted successfully' };
  } catch (error) {
    throw handleError(error);
  }
});
