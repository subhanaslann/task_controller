import prisma from '../db/connection';
import { NotFoundError } from '../utils/errors';

export interface CreateTopicInput {
  title: string;
  description?: string;
  isActive?: boolean;
}

export interface UpdateTopicInput {
  title?: string;
  description?: string;
  isActive?: boolean;
}

export const createTopic = async (input: CreateTopicInput) => {
  const topic = await prisma.topic.create({
    data: {
      title: input.title,
      description: input.description,
      isActive: input.isActive ?? true,
    },
  });

  return topic;
};

export const updateTopic = async (topicId: string, input: UpdateTopicInput) => {
  const existingTopic = await prisma.topic.findUnique({
    where: { id: topicId },
  });

  if (!existingTopic) {
    throw new NotFoundError('Topic not found');
  }

  const topic = await prisma.topic.update({
    where: { id: topicId },
    data: {
      ...(input.title !== undefined && { title: input.title }),
      ...(input.description !== undefined && { description: input.description }),
      ...(input.isActive !== undefined && { isActive: input.isActive }),
    },
  });

  return topic;
};

export const deleteTopic = async (topicId: string) => {
  const existingTopic = await prisma.topic.findUnique({
    where: { id: topicId },
  });

  if (!existingTopic) {
    throw new NotFoundError('Topic not found');
  }

  await prisma.topic.delete({
    where: { id: topicId },
  });

  return { success: true, message: 'Topic deleted successfully' };
};

export const getTopic = async (topicId: string) => {
  const topic = await prisma.topic.findUnique({
    where: { id: topicId },
    include: {
      tasks: {
        include: {
          assignee: {
            select: {
              id: true,
              name: true,
              username: true,
            },
          },
        },
      },
    },
  });

  if (!topic) {
    throw new NotFoundError('Topic not found');
  }

  return topic;
};

export const getTopics = async () => {
  return prisma.topic.findMany({
    orderBy: { createdAt: 'desc' },
    include: {
      _count: {
        select: { tasks: true },
      },
    },
  });
};

export const getActiveTopics = async (userId?: string, userRole?: string) => {
  // Build where clause based on user role
  const whereClause: any = { isActive: true };

  // If guest user, filter by accessible topics
  if (userRole === 'GUEST' && userId) {
    whereClause.guestAccess = {
      some: {
        userId,
      },
    };
  }

  return prisma.topic.findMany({
    where: whereClause,
    orderBy: { createdAt: 'desc' },
    include: {
      tasks: {
        include: {
          assignee: {
            select: {
              id: true,
              name: true,
              username: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      },
    },
  });
};
