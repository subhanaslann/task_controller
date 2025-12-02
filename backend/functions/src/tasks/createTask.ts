import { onCall } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { createTaskSchema, createMemberTaskSchema } from '../utils/validation';
import { handleError, ValidationError, ForbiddenError } from '../utils/errors';
import { requireAuth, requireTeamManager } from '../utils/auth';

// Team Manager task creation (can assign to anyone)
export const createTask = onCall(async (request) => {
  try {
    const context = await requireAuth(request);
    requireTeamManager(context);

    const validationResult = createTaskSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new ValidationError(validationResult.error.errors[0].message);
    }

    const { topicId, title, note, assigneeId, status, priority, dueDate } = validationResult.data;
    const db = admin.firestore();
    const { organizationId } = context;

    // Validate topic if provided
    if (topicId) {
      const topicDoc = await db
        .collection('organizations').doc(organizationId)
        .collection('topics').doc(topicId)
        .get();

      if (!topicDoc.exists) {
        throw new ValidationError('Topic not found');
      }

      const topicData = topicDoc.data()!;
      if (!topicData.isActive) {
        throw new ValidationError('Cannot create task for inactive topic');
      }
    }

    // Validate assignee if provided
    if (assigneeId) {
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

    const now = admin.firestore.FieldValue.serverTimestamp();
    const taskRef = db
      .collection('organizations').doc(organizationId)
      .collection('tasks').doc();

    const taskData = {
      topicId: topicId || null,
      title,
      note: note || null,
      assigneeId: assigneeId || null,
      status: status || 'TODO',
      priority: priority || 'NORMAL',
      dueDate: dueDate ? new Date(dueDate) : null,
      completedAt: null,
      createdAt: now,
      updatedAt: now,
    };

    await taskRef.set(taskData);

    const createdDoc = await taskRef.get();
    const data = createdDoc.data()!;

    return {
      id: taskRef.id,
      organizationId,
      topicId: data.topicId,
      title: data.title,
      note: data.note,
      assigneeId: data.assigneeId,
      status: data.status,
      priority: data.priority,
      dueDate: data.dueDate?.toDate?.()?.toISOString() || null,
      completedAt: null,
      createdAt: data.createdAt?.toDate?.()?.toISOString() || new Date().toISOString(),
      updatedAt: data.updatedAt?.toDate?.()?.toISOString() || new Date().toISOString(),
    };
  } catch (error) {
    throw handleError(error);
  }
});

// Member task creation (self-assigned only)
export const createMemberTask = onCall(async (request) => {
  try {
    const context = await requireAuth(request);

    // Guests cannot create tasks
    if (context.role === 'GUEST') {
      throw new ForbiddenError('Guest users cannot create tasks');
    }

    const validationResult = createMemberTaskSchema.safeParse(request.data);
    if (!validationResult.success) {
      throw new ValidationError(validationResult.error.errors[0].message);
    }

    const { topicId, title, note, status, priority, dueDate } = validationResult.data;
    const db = admin.firestore();
    const { organizationId, uid } = context;

    // Validate topic if provided
    if (topicId) {
      const topicDoc = await db
        .collection('organizations').doc(organizationId)
        .collection('topics').doc(topicId)
        .get();

      if (!topicDoc.exists) {
        throw new ValidationError('Topic not found');
      }

      const topicData = topicDoc.data()!;
      if (!topicData.isActive) {
        throw new ValidationError('Cannot create task for inactive topic');
      }
    }

    const now = admin.firestore.FieldValue.serverTimestamp();
    const taskRef = db
      .collection('organizations').doc(organizationId)
      .collection('tasks').doc();

    const taskData = {
      topicId: topicId || null,
      title,
      note: note || null,
      assigneeId: uid, // Always self-assigned
      status: status || 'TODO',
      priority: priority || 'NORMAL',
      dueDate: dueDate ? new Date(dueDate) : null,
      completedAt: null,
      createdAt: now,
      updatedAt: now,
    };

    await taskRef.set(taskData);

    const createdDoc = await taskRef.get();
    const data = createdDoc.data()!;

    return {
      id: taskRef.id,
      organizationId,
      topicId: data.topicId,
      title: data.title,
      note: data.note,
      assigneeId: data.assigneeId,
      status: data.status,
      priority: data.priority,
      dueDate: data.dueDate?.toDate?.()?.toISOString() || null,
      completedAt: null,
      createdAt: data.createdAt?.toDate?.()?.toISOString() || new Date().toISOString(),
      updatedAt: data.updatedAt?.toDate?.()?.toISOString() || new Date().toISOString(),
    };
  } catch (error) {
    throw handleError(error);
  }
});
