import { onCall } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { updateOrganizationSchema } from '../utils/validation';
import { handleError, ValidationError } from '../utils/errors';
import { requireAuth, requireTeamManager } from '../utils/auth';

export const updateOrganization = onCall(async (request) => {
  try {
    const context = await requireAuth(request);
    requireTeamManager(context);

    const validationResult = updateOrganizationSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new ValidationError(validationResult.error.errors[0].message);
    }

    const { name, teamName, maxUsers } = validationResult.data;
    const db = admin.firestore();
    const { organizationId } = context;

    const orgRef = db.collection('organizations').doc(organizationId);

    const updateData: Record<string, unknown> = {
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (name !== undefined) updateData.name = name;
    if (teamName !== undefined) updateData.teamName = teamName;
    if (maxUsers !== undefined) updateData.maxUsers = maxUsers;

    await orgRef.update(updateData);

    const updatedDoc = await orgRef.get();
    const data = updatedDoc.data()!;

    return {
      id: organizationId,
      name: data.name,
      teamName: data.teamName,
      slug: data.slug,
      isActive: data.isActive,
      maxUsers: data.maxUsers,
      createdAt: data.createdAt?.toDate?.()?.toISOString() || null,
      updatedAt: data.updatedAt?.toDate?.()?.toISOString() || new Date().toISOString(),
    };
  } catch (error) {
    throw handleError(error);
  }
});

export const getOrganizationStats = onCall(async (request) => {
  try {
    const context = await requireAuth(request);

    const db = admin.firestore();
    const { organizationId } = context;

    const usersRef = db.collection('organizations').doc(organizationId).collection('users');
    const tasksRef = db.collection('organizations').doc(organizationId).collection('tasks');
    const topicsRef = db.collection('organizations').doc(organizationId).collection('topics');

    const [
      userCountSnapshot,
      activeUserCountSnapshot,
      taskCountSnapshot,
      activeTaskCountSnapshot,
      completedTaskCountSnapshot,
      topicCountSnapshot,
      activeTopicCountSnapshot,
    ] = await Promise.all([
      usersRef.count().get(),
      usersRef.where('active', '==', true).count().get(),
      tasksRef.count().get(),
      tasksRef.where('status', 'in', ['TODO', 'IN_PROGRESS']).count().get(),
      tasksRef.where('status', '==', 'DONE').count().get(),
      topicsRef.count().get(),
      topicsRef.where('isActive', '==', true).count().get(),
    ]);

    return {
      userCount: userCountSnapshot.data().count,
      activeUserCount: activeUserCountSnapshot.data().count,
      taskCount: taskCountSnapshot.data().count,
      activeTaskCount: activeTaskCountSnapshot.data().count,
      completedTaskCount: completedTaskCountSnapshot.data().count,
      topicCount: topicCountSnapshot.data().count,
      activeTopicCount: activeTopicCountSnapshot.data().count,
    };
  } catch (error) {
    throw handleError(error);
  }
});
