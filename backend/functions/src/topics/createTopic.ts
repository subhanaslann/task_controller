import { onCall } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { createTopicSchema } from '../utils/validation';
import { handleError, ValidationError } from '../utils/errors';
import { requireAuth, requireTeamManager } from '../utils/auth';

export const createTopic = onCall(async (request) => {
  try {
    const context = await requireAuth(request);
    requireTeamManager(context);

    const validationResult = createTopicSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new ValidationError(validationResult.error.errors[0].message);
    }

    const { title, description, isActive } = validationResult.data;
    const db = admin.firestore();
    const { organizationId } = context;

    const now = admin.firestore.FieldValue.serverTimestamp();
    const topicRef = db
      .collection('organizations').doc(organizationId)
      .collection('topics').doc();

    const topicData = {
      title,
      description: description || null,
      isActive: isActive ?? true,
      accessControl: {}, // Empty map for guest access
      createdAt: now,
      updatedAt: now,
    };

    await topicRef.set(topicData);

    const createdDoc = await topicRef.get();
    const data = createdDoc.data()!;

    return {
      id: topicRef.id,
      organizationId,
      title: data.title,
      description: data.description,
      isActive: data.isActive,
      createdAt: data.createdAt?.toDate?.()?.toISOString() || new Date().toISOString(),
      updatedAt: data.updatedAt?.toDate?.()?.toISOString() || new Date().toISOString(),
    };
  } catch (error) {
    throw handleError(error);
  }
});
