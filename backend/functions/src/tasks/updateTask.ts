import { onCall } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { updateTaskSchema } from '../utils/validation';
import { handleError, ValidationError, NotFoundError, ForbiddenError } from '../utils/errors';
import { requireAuth, requireTeamManagerOrAdmin } from '../utils/auth';

// Admin task update (can update any task)
export const updateTask = onCall(async (request) => {
  try {
    const context = await requireAuth(request);
    requireTeamManagerOrAdmin(context);

    const validationResult = updateTaskSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new ValidationError(validationResult.error.errors[0].message);
    }

    const { taskId, title, note, assigneeId, status, priority, dueDate } = validationResult.data;
    const db = admin.firestore();
    const { organizationId } = context;

    const taskRef = db
      .collection('organizations').doc(organizationId)
      .collection('tasks').doc(taskId);

    const taskDoc = await taskRef.get();
    if (!taskDoc.exists) {
      throw new NotFoundError('Task not found');
    }

    const currentData = taskDoc.data()!;
    const updateData: Record<string, unknown> = {
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (title !== undefined) updateData.title = title;
    if (note !== undefined) updateData.note = note;
    if (assigneeId !== undefined) {
      // Validate assignee if provided
      if (assigneeId !== null) {
        const assigneeDoc = await db
          .collection('organizations').doc(organizationId)
          .collection('users').doc(assigneeId)
          .get();

        if (!assigneeDoc.exists) {
          throw new ValidationError('Assignee not found in your organization');
        }

        const assigneeData = assigneeDoc.data()!;
        if (assigneeData.role === 'GUEST') {
          throw new ValidationError('Cannot assign tasks to guest users');
        }
      }
      updateData.assigneeId = assigneeId;
    }
    if (priority !== undefined) updateData.priority = priority;
    if (dueDate !== undefined) updateData.dueDate = dueDate ? new Date(dueDate) : null;

    // Handle status change and completedAt
    if (status !== undefined) {
      updateData.status = status;
      if (status === 'DONE' && currentData.status !== 'DONE') {
        updateData.completedAt = admin.firestore.FieldValue.serverTimestamp();
      } else if (status !== 'DONE' && currentData.status === 'DONE') {
        updateData.completedAt = null;
      }
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

// Member task update (own tasks only)
export const updateMemberTask = onCall(async (request) => {
  try {
    const context = await requireAuth(request);

    // Guests cannot update tasks
    if (context.role === 'GUEST') {
      throw new ForbiddenError('Guest users cannot update tasks');
    }

    const validationResult = updateTaskSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new ValidationError(validationResult.error.errors[0].message);
    }

    const { taskId, title, note, status, priority, dueDate } = validationResult.data;
    const db = admin.firestore();
    const { organizationId, uid } = context;

    const taskRef = db
      .collection('organizations').doc(organizationId)
      .collection('tasks').doc(taskId);

    const taskDoc = await taskRef.get();
    if (!taskDoc.exists) {
      throw new NotFoundError('Task not found');
    }

    const currentData = taskDoc.data()!;

    // Check ownership
    if (currentData.assigneeId !== uid) {
      throw new ForbiddenError('You can only update your own tasks');
    }

    const updateData: Record<string, unknown> = {
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (title !== undefined) updateData.title = title;
    if (note !== undefined) updateData.note = note;
    if (priority !== undefined) updateData.priority = priority;
    if (dueDate !== undefined) updateData.dueDate = dueDate ? new Date(dueDate) : null;

    // Handle status change and completedAt
    if (status !== undefined) {
      updateData.status = status;
      if (status === 'DONE' && currentData.status !== 'DONE') {
        updateData.completedAt = admin.firestore.FieldValue.serverTimestamp();
      } else if (status !== 'DONE' && currentData.status === 'DONE') {
        updateData.completedAt = null;
      }
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
