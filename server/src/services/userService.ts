import prisma from '../db/connection';
import { hashPassword } from '../utils/password';
import { ConflictError, NotFoundError } from '../utils/errors';
import { config } from '../config';
// Role type: 'ADMIN' | 'MEMBER' | 'GUEST'
type Role = 'ADMIN' | 'MEMBER' | 'GUEST';

export interface CreateUserInput {
  name: string;
  username: string;
  email: string;
  password: string;
  role: Role;
  active?: boolean;
  visibleTopicIds?: string[];
}

export interface UpdateUserInput {
  name?: string;
  role?: Role;
  active?: boolean;
  password?: string;
  visibleTopicIds?: string[];
}

const checkActiveUserLimit = async (excludeUserId?: string): Promise<void> => {
  const activeUserCount = await prisma.user.count({
    where: {
      active: true,
      ...(excludeUserId && { id: { not: excludeUserId } }),
    },
  });

  if (activeUserCount >= config.maxActiveUsers) {
    throw new ConflictError(
      `Maximum active user limit (${config.maxActiveUsers}) reached`
    );
  }
};

export const createUser = async (input: CreateUserInput) => {
  // Check if creating an active user would exceed limit
  if (input.active !== false) {
    await checkActiveUserLimit();
  }

  const passwordHash = await hashPassword(input.password);

  const user = await prisma.user.create({
    data: {
      name: input.name,
      username: input.username,
      email: input.email,
      passwordHash,
      role: input.role,
      active: input.active ?? true,
    },
    select: {
      id: true,
      name: true,
      username: true,
      email: true,
      role: true,
      active: true,
      createdAt: true,
      updatedAt: true,
    },
  });

  // If guest user, set accessible topics
  if (input.role === 'GUEST' && input.visibleTopicIds && input.visibleTopicIds.length > 0) {
    await prisma.guestTopicAccess.createMany({
      data: input.visibleTopicIds.map((topicId) => ({
        userId: user.id,
        topicId,
      })),
    });
  }

  return user;
};

export const updateUser = async (userId: string, input: UpdateUserInput) => {
  const existingUser = await prisma.user.findUnique({
    where: { id: userId },
  });

  if (!existingUser) {
    throw new NotFoundError('User not found');
  }

  // If activating a currently inactive user, check limit
  if (input.active === true && !existingUser.active) {
    await checkActiveUserLimit(userId);
  }

  const updateData: any = {};

  if (input.name !== undefined) updateData.name = input.name;
  if (input.role !== undefined) updateData.role = input.role;
  if (input.active !== undefined) updateData.active = input.active;
  if (input.password !== undefined) {
    updateData.passwordHash = await hashPassword(input.password);
  }

  const user = await prisma.user.update({
    where: { id: userId },
    data: updateData,
    select: {
      id: true,
      name: true,
      username: true,
      email: true,
      role: true,
      active: true,
      createdAt: true,
      updatedAt: true,
    },
  });

  // Update accessible topics if provided and user is GUEST
  if (input.visibleTopicIds !== undefined && (input.role === 'GUEST' || existingUser.role === 'GUEST')) {
    // Delete existing access
    await prisma.guestTopicAccess.deleteMany({
      where: { userId },
    });

    // Add new access if any topics provided
    if (input.visibleTopicIds.length > 0) {
      await prisma.guestTopicAccess.createMany({
        data: input.visibleTopicIds.map((topicId) => ({
          userId,
          topicId,
        })),
      });
    }
  }

  return user;
};

export const getUsers = async () => {
  const users = await prisma.user.findMany({
    select: {
      id: true,
      name: true,
      username: true,
      email: true,
      role: true,
      active: true,
      createdAt: true,
      updatedAt: true,
      accessibleTopics: {
        select: {
          topicId: true,
        },
      },
    },
    orderBy: { createdAt: 'desc' },
  });

  // Transform accessibleTopics to visibleTopicIds
  return users.map(user => {
    const { accessibleTopics, ...userData } = user;
    return {
      ...userData,
      visibleTopicIds: accessibleTopics.map((a) => a.topicId),
    };
  });
};

export const getUser = async (userId: string) => {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      name: true,
      username: true,
      email: true,
      role: true,
      active: true,
      createdAt: true,
      updatedAt: true,
      accessibleTopics: {
        select: {
          topicId: true,
        },
      },
    },
  });

  if (!user) {
    throw new NotFoundError('User not found');
  }

  // Transform accessibleTopics to array of topic IDs
  const { accessibleTopics, ...userData } = user;
  return {
    ...userData,
    visibleTopicIds: accessibleTopics.map((a) => a.topicId),
  };
};

export const deleteUser = async (userId: string) => {
  const user = await prisma.user.findUnique({
    where: { id: userId },
  });

  if (!user) {
    throw new NotFoundError('User not found');
  }

  await prisma.user.delete({
    where: { id: userId },
  });

  return { success: true, message: 'User deleted successfully' };
};
