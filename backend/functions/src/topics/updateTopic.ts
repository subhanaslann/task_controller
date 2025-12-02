import { onCall } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { updateTopicSchema } from '../utils/validation';
import { handleError, ValidationError, NotFoundError } from '../utils/errors';
import { requireAuth, requireTeamManager } from '../utils/auth';

export const updateTopic = onCall(async (request) => {
  try {
    const context = await requireAuth(request);
    requireTeamManager(context);

    const validationResult = updateTopicSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new ValidationError(validationResult.error.errors[0].message);
    }

    const { topicId, title, description, isActive } = validationResult.data;
    const db = admin.firestore();
    const { organizationId } = context;

    const topicRef = db
      .collection('organizations').doc(organizationId)
      .collection('topics').doc(topicId);

    const topicDoc = await topicRef.get();
    if (!topicDoc.exists) {
      throw new NotFoundError('Topic not found');
    }

    const updateData: Record<string, unknown> = {
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (title !== undefined) updateData.title = title;
    if (description !== undefined) updateData.description = description;
    if (isActive !== undefined) updateData.isActive = isActive;

    await topicRef.update(updateData);

    const updatedDoc = await topicRef.get();
    const data = updatedDoc.data()!;

    return {
      id: topicId,
      organizationId,
      title: data.title,
      description: data.description,
      isActive: data.isActive,
      createdAt: data.createdAt?.toDate?.()?.toISOString() || null,
      updatedAt: data.updatedAt?.toDate?.()?.toISOString() || new Date().toISOString(),
    };
  } catch (error) {
    throw handleError(error);
  }
});
