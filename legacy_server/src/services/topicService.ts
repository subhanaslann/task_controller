import prisma from '../db/connection';
import { NotFoundError } from '../utils/errors';
import { Role } from '../types';

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

export const createTopic = async (organizationId: string, input: CreateTopicInput) => {
  const topic = await prisma.topic.create({
    data: {
      organizationId,
      title: input.title,
      description: input.description,
      isActive: input.isActive ?? true,
    },
  });

  return topic;
};

export const updateTopic = async (topicId: string, organizationId: string, input: UpdateTopicInput) => {
  const existingTopic = await prisma.topic.findFirst({
    where: {
      id: topicId,
      organizationId,
    },
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

export const deleteTopic = async (topicId: string, organizationId: string) => {
  const existingTopic = await prisma.topic.findFirst({
    where: {
      id: topicId,
      organizationId,
    },
  });

  if (!existingTopic) {
    throw new NotFoundError('Topic not found');
  }

  await prisma.topic.delete({
    where: { id: topicId },
  });

  return { success: true, message: 'Topic deleted successfully' };
};

export const getTopic = async (topicId: string, organizationId: string) => {
  const topic = await prisma.topic.findFirst({
    where: {
      id: topicId,
      organizationId,
    },
    include: {
      tasks: {
        where: { organizationId },
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

export const getTopics = async (organizationId: string) => {
  return prisma.topic.findMany({
    where: { organizationId },
    orderBy: { createdAt: 'desc' },
    include: {
      _count: {
        select: { tasks: true },
      },
    },
  });
};

export const getActiveTopics = async (
  organizationId: string,
  userId?: string,
  userRole?: Role
) => {
  // Build where clause based on user role
  const whereClause: any = {
    organizationId,
    isActive: true,
  };

  // If guest user, filter by accessible topics
  if (userRole === Role.GUEST && userId) {
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
        where: { organizationId },
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
