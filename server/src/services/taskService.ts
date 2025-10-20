import prisma from '../db/connection';
import { NotFoundError, ForbiddenError, ValidationError } from '../utils/errors';
// Enum types as string literals
type TaskStatus = 'TODO' | 'IN_PROGRESS' | 'DONE';
type Priority = 'LOW' | 'NORMAL' | 'HIGH';

export interface CreateTaskInput {
  topicId?: string;
  title: string;
  note?: string;
  assigneeId?: string;
  status?: TaskStatus;
  priority?: Priority;
  dueDate?: Date;
}

export interface CreateMemberTaskInput {
  topicId: string;
  title: string;
  note?: string;
  priority?: Priority;
  dueDate?: Date;
  assigneeId: string; // Set by the system
}

export interface UpdateTaskInput {
  title?: string;
  note?: string;
  status?: TaskStatus;
  priority?: Priority;
  dueDate?: Date;
}

const fullTaskSelect = {
  id: true,
  topicId: true,
  title: true,
  note: true,
  assigneeId: true,
  status: true,
  priority: true,
  dueDate: true,
  createdAt: true,
  updatedAt: true,
  completedAt: true,
  topic: {
    select: {
      id: true,
      title: true,
    },
  },
  assignee: {
    select: {
      id: true,
      name: true,
      username: true,
    },
  },
};


export const getMyActiveTasks = async (userId: string) => {
  return prisma.task.findMany({
    where: {
      assigneeId: userId,
      status: { in: ['TODO', 'IN_PROGRESS'] },
    },
    select: fullTaskSelect,
    orderBy: [{ priority: 'desc' }, { dueDate: 'asc' }, { createdAt: 'desc' }],
  });
};

export const getTeamActiveTasks = async (userRole: string) => {
  const tasks = await prisma.task.findMany({
    where: {
      status: { in: ['TODO', 'IN_PROGRESS'] },
    },
    select: fullTaskSelect,
    orderBy: [{ priority: 'desc' }, { dueDate: 'asc' }, { createdAt: 'desc' }],
  });

  // Filter sensitive fields for guest users
  if (userRole === 'GUEST') {
    return tasks.map((task) => ({
      id: task.id,
      title: task.title,
      status: task.status,
      priority: task.priority,
      dueDate: task.dueDate,
      assignee: task.assignee
        ? {
            id: task.assignee.id,
            name: task.assignee.name,
          }
        : null,
    }));
  }

  return tasks;
};

export const getMyCompletedTasks = async (userId: string) => {
  return prisma.task.findMany({
    where: {
      assigneeId: userId,
      status: 'DONE',
    },
    select: fullTaskSelect,
    orderBy: { completedAt: 'desc' },
  });
};

export const updateTaskStatus = async (
  taskId: string,
  newStatus: TaskStatus,
  userId: string,
  userRole: string
) => {
  const task = await prisma.task.findUnique({
    where: { id: taskId },
  });

  if (!task) {
    throw new NotFoundError('Task not found');
  }

  // Only admin or assignee can update task status
  if (userRole !== 'ADMIN' && task.assigneeId !== userId) {
    throw new ForbiddenError('You can only update your own tasks');
  }

  const updateData: any = { status: newStatus };

  // Set completedAt when status changes to DONE
  if (newStatus === 'DONE' && task.status !== 'DONE') {
    updateData.completedAt = new Date();
  }

  // Clear completedAt when status changes from DONE to something else
  if (newStatus !== 'DONE' && task.status === 'DONE') {
    updateData.completedAt = null;
  }

  return prisma.task.update({
    where: { id: taskId },
    data: updateData,
    select: fullTaskSelect,
  });
};

export const createTask = async (input: CreateTaskInput) => {
  // Validate topic exists and is active if provided
  if (input.topicId) {
    const topic = await prisma.topic.findUnique({
      where: { id: input.topicId },
    });

    if (!topic) {
      throw new ValidationError('Topic not found');
    }

    if (!topic.isActive) {
      throw new ValidationError('Cannot create task for inactive topic');
    }
  }

  return prisma.task.create({
    data: {
      topicId: input.topicId,
      title: input.title,
      note: input.note,
      assigneeId: input.assigneeId,
      status: input.status ?? 'TODO',
      priority: input.priority ?? 'NORMAL',
      dueDate: input.dueDate,
    },
    select: fullTaskSelect,
  });
};

export const createMemberTask = async (input: CreateMemberTaskInput) => {
  // Validate topic exists and is active
  const topic = await prisma.topic.findUnique({
    where: { id: input.topicId },
  });

  if (!topic) {
    throw new ValidationError('Topic not found');
  }

  if (!topic.isActive) {
    throw new ValidationError('Cannot create task for inactive topic');
  }

  return prisma.task.create({
    data: {
      topicId: input.topicId,
      title: input.title,
      note: input.note,
      assigneeId: input.assigneeId, // Always set to current user
      status: 'TODO',
      priority: input.priority ?? 'NORMAL',
      dueDate: input.dueDate,
    },
    select: fullTaskSelect,
  });
};

export const updateTask = async (taskId: string, input: UpdateTaskInput) => {
  const task = await prisma.task.findUnique({
    where: { id: taskId },
  });

  if (!task) {
    throw new NotFoundError('Task not found');
  }

  const updateData: any = {};

  if (input.title !== undefined) updateData.title = input.title;
  if (input.note !== undefined) updateData.note = input.note;
  if (input.status !== undefined) {
    updateData.status = input.status;
    // Handle completedAt when status changes
    if (input.status === 'DONE' && task.status !== 'DONE') {
      updateData.completedAt = new Date();
    }
    if (input.status !== 'DONE' && task.status === 'DONE') {
      updateData.completedAt = null;
    }
  }
  if (input.priority !== undefined) updateData.priority = input.priority;
  if (input.dueDate !== undefined) updateData.dueDate = input.dueDate;

  return prisma.task.update({
    where: { id: taskId },
    data: updateData,
    select: fullTaskSelect,
  });
};

export const updateMemberTask = async (
  taskId: string,
  input: UpdateTaskInput,
  userId: string
) => {
  const task = await prisma.task.findUnique({
    where: { id: taskId },
  });

  if (!task) {
    throw new NotFoundError('Task not found');
  }

  // Only the task owner can update their task
  if (task.assigneeId !== userId) {
    throw new ForbiddenError('You can only update your own tasks');
  }

  return updateTask(taskId, input);
};

export const deleteTask = async (taskId: string) => {
  const task = await prisma.task.findUnique({
    where: { id: taskId },
  });

  if (!task) {
    throw new NotFoundError('Task not found');
  }

  await prisma.task.delete({
    where: { id: taskId },
  });

  return { success: true };
};

export const getAllTasks = async () => {
  return prisma.task.findMany({
    select: fullTaskSelect,
    orderBy: [{ status: 'asc' }, { priority: 'desc' }, { createdAt: 'desc' }],
  });
};

export const getTask = async (taskId: string) => {
  const task = await prisma.task.findUnique({
    where: { id: taskId },
    select: fullTaskSelect,
  });

  if (!task) {
    throw new NotFoundError('Task not found');
  }

  return task;
};
