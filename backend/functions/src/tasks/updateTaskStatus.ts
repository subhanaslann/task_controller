import { onCall } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { updateTaskStatusSchema } from '../utils/validation';
import { handleError, ValidationError, NotFoundError, ForbiddenError } from '../utils/errors';
import { requireAuth } from '../utils/auth';

export const updateTaskStatus = onCall(async (request) => {
  try {
    const context = await requireAuth(request);

    // Guests cannot update task status
    if (context.role === 'GUEST') {
      throw new ForbiddenError('Guest users cannot update task status');
    }

    const validationResult = updateTaskStatusSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new ValidationError(validationResult.error.errors[0].message);
    }

    const { taskId, status } = validationResult.data;
    const db = admin.firestore();
    const { organizationId, uid, role } = context;

    const taskRef = db
      .collection('organizations').doc(organizationId)
      .collection('tasks').doc(taskId);

    const taskDoc = await taskRef.get();
    if (!taskDoc.exists) {
      throw new NotFoundError('Task not found');
    }

    const currentData = taskDoc.data()!;

    // Only admin/team manager or assignee can update task status
    const isManager = role === 'ADMIN' || role === 'TEAM_MANAGER';
    const isAssignee = currentData.assigneeId === uid;

    if (!isManager && !isAssignee) {
      throw new ForbiddenError('You can only update your own tasks');
    }

    const updateData: Record<string, unknown> = {
      status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Handle completedAt
    if (status === 'DONE' && currentData.status !== 'DONE') {
      updateData.completedAt = admin.firestore.FieldValue.serverTimestamp();
    } else if (status !== 'DONE' && currentData.status === 'DONE') {
      updateData.completedAt = null;
    }

    await taskRef.update(updateData);

    const updatedDoc = await taskRef.get();
    const data = updatedDoc.data()!;

    return {
      id: taskId,
      organizationId,
      topicId: data.topicId,
      title: data.title,
      note: data.note,
      assigneeId: data.assigneeId,
      status: data.status,
      priority: data.priority,
      dueDate: data.dueDate?.toDate?.()?.toISOString() || null,
      completedAt: data.completedAt?.toDate?.()?.toISOString() || null,
      createdAt: data.createdAt?.toDate?.()?.toISOString() || null,
      updatedAt: data.updatedAt?.toDate?.()?.toISOString() || new Date().toISOString(),
    };
  } catch (error) {
    throw handleError(error);
  }
});
