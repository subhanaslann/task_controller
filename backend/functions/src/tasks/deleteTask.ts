import { onCall } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { deleteTaskSchema } from '../utils/validation';
import { handleError, ValidationError, NotFoundError, ForbiddenError } from '../utils/errors';
import { requireAuth, requireTeamManager } from '../utils/auth';

// Team Manager task delete
export const deleteTask = onCall(async (request) => {
  try {
    const context = await requireAuth(request);
    requireTeamManager(context);

    const validationResult = deleteTaskSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new ValidationError(validationResult.error.errors[0].message);
    }

    const { taskId } = validationResult.data;
    const db = admin.firestore();
    const { organizationId } = context;

    const taskRef = db
      .collection('organizations').doc(organizationId)
      .collection('tasks').doc(taskId);

    const taskDoc = await taskRef.get();
    if (!taskDoc.exists) {
      throw new NotFoundError('Task not found');
    }

    await taskRef.delete();

    return { success: true, message: 'Task deleted successfully' };
  } catch (error) {
    throw handleError(error);
  }
});

// Member task delete (own tasks only)
export const deleteMemberTask = onCall(async (request) => {
  try {
    const context = await requireAuth(request);

    // Guests cannot delete tasks
    if (context.role === 'GUEST') {
      throw new ForbiddenError('Guest users cannot delete tasks');
    }

    const validationResult = deleteTaskSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new ValidationError(validationResult.error.errors[0].message);
    }

    const { taskId } = validationResult.data;
    const db = admin.firestore();
    const { organizationId, uid } = context;

    const taskRef = db
      .collection('organizations').doc(organizationId)
      .collection('tasks').doc(taskId);

    const taskDoc = await taskRef.get();
    if (!taskDoc.exists) {
      throw new NotFoundError('Task not found');
    }

    const taskData = taskDoc.data()!;

    // Check ownership
    if (taskData.assigneeId !== uid) {
      throw new ForbiddenError('You can only delete your own tasks');
    }

    await taskRef.delete();

    return { success: true, message: 'Task deleted successfully' };
  } catch (error) {
    throw handleError(error);
  }
});
