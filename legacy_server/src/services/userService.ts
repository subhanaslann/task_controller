import prisma from '../db/connection';
import { hashPassword } from '../utils/password';
import { NotFoundError, ForbiddenError, OrganizationUserLimitReachedError } from '../utils/errors';
import { Role } from '../types';

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

export interface UpdateProfileInput {
  name?: string;
  avatar?: string;
  password?: string;
}

/**
 * Check if adding a user would exceed the organization's user limit
 */
const checkActiveUserLimit = async (
  organizationId: string,
  excludeUserId?: string
): Promise<void> => {
  // Get organization to check maxUsers
  const organization = await prisma.organization.findUnique({
    where: { id: organizationId },
    select: { maxUsers: true },
  });

  if (!organization) {
    throw new NotFoundError('Organization not found');
  }

  // Count active users in the organization
  const activeUserCount = await prisma.user.count({
    where: {
      organizationId,
      active: true,
      ...(excludeUserId && { id: { not: excludeUserId } }),
    },
  });

  if (activeUserCount >= organization.maxUsers) {
    throw new OrganizationUserLimitReachedError(organization.maxUsers);
  }
};

/**
 * Create a new user in an organization
 * @param organizationId - The organization the user belongs to
 * @param input - User creation data
 * @param creatorRole - Role of the user creating this user (for permission checks)
 */
export const createUser = async (
  organizationId: string,
  input: CreateUserInput,
  creatorRole: Role
) => {
  // Prevent TEAM_MANAGER from creating ADMIN users
  if (creatorRole === Role.TEAM_MANAGER && input.role === Role.ADMIN) {
    throw new ForbiddenError('Team Managers cannot create Admin users');
  }

  // Prevent TEAM_MANAGER from creating other TEAM_MANAGER users
  if (creatorRole === Role.TEAM_MANAGER && input.role === Role.TEAM_MANAGER) {
    throw new ForbiddenError('Team Managers cannot create other Team Manager users');
  }

  // Check if creating an active user would exceed limit
  if (input.active !== false) {
    await checkActiveUserLimit(organizationId);
  }

  const passwordHash = await hashPassword(input.password);

  const user = await prisma.user.create({
    data: {
      organizationId,
      name: input.name,
      username: input.username,
      email: input.email,
      passwordHash,
      role: input.role,
      active: input.active ?? true,
    },
    select: {
      id: true,
      organizationId: true,
      name: true,
      username: true,
      email: true,
      avatar: true,
      role: true,
      active: true,
      createdAt: true,
      updatedAt: true,
    },
  });

  // If guest user, set accessible topics
  if (input.role === Role.GUEST && input.visibleTopicIds && input.visibleTopicIds.length > 0) {
    await prisma.guestTopicAccess.createMany({
      data: input.visibleTopicIds.map((topicId) => ({
        userId: user.id,
        topicId,
      })),
    });
  }

  return user;
};

/**
 * Update a user in an organization
 * @param userId - User ID to update
 * @param organizationId - Organization ID (for filtering)
 * @param input - Update data
 * @param updaterRole - Role of the user performing the update (for permission checks)
 */
export const updateUser = async (
  userId: string,
  organizationId: string,
  input: UpdateUserInput,
  updaterRole: Role
) => {
  const existingUser = await prisma.user.findFirst({
    where: {
      id: userId,
      organizationId,
    },
  });

  if (!existingUser) {
    throw new NotFoundError('User not found');
  }

  // Prevent TEAM_MANAGER from escalating to ADMIN
  if (updaterRole === Role.TEAM_MANAGER && input.role === Role.ADMIN) {
    throw new ForbiddenError('Team Managers cannot promote users to Admin');
  }

  // Prevent TEAM_MANAGER from promoting to TEAM_MANAGER
  if (updaterRole === Role.TEAM_MANAGER && input.role === Role.TEAM_MANAGER) {
    throw new ForbiddenError('Team Managers cannot promote users to Team Manager');
  }

  // If activating a currently inactive user, check limit
  if (input.active === true && !existingUser.active) {
    await checkActiveUserLimit(organizationId, userId);
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
      organizationId: true,
      name: true,
      username: true,
      email: true,
      avatar: true,
      role: true,
      active: true,
      createdAt: true,
      updatedAt: true,
    },
  });

  // Update accessible topics if provided and user is GUEST
  if (input.visibleTopicIds !== undefined && (input.role === Role.GUEST || existingUser.role === Role.GUEST)) {
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

/**
 * Update current user's profile (name, avatar, password)
 */
export const updateProfile = async (
  userId: string,
  organizationId: string,
  input: UpdateProfileInput
) => {
  const existingUser = await prisma.user.findFirst({
    where: {
      id: userId,
      organizationId,
    },
  });

  if (!existingUser) {
    throw new NotFoundError('User not found');
  }

  const updateData: any = {};

  if (input.name !== undefined) updateData.name = input.name;
  if (input.avatar !== undefined) updateData.avatar = input.avatar;
  if (input.password !== undefined) {
    updateData.passwordHash = await hashPassword(input.password);
  }

  const user = await prisma.user.update({
    where: { id: userId },
    data: updateData,
    select: {
      id: true,
      organizationId: true,
      name: true,
      username: true,
      email: true,
      avatar: true,
      role: true,
      active: true,
      createdAt: true,
      updatedAt: true,
    },
  });

  return user;
};

/**
 * Get all users in an organization
 */
export const getUsers = async (organizationId: string) => {
  const users = await prisma.user.findMany({
    where: { organizationId },
    select: {
      id: true,
      organizationId: true,
      name: true,
      username: true,
      email: true,
      avatar: true,
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

/**
 * Get a specific user by ID (organization-scoped)
 */
export const getUser = async (userId: string, organizationId: string) => {
  const user = await prisma.user.findFirst({
    where: {
      id: userId,
      organizationId,
    },
    select: {
      id: true,
      organizationId: true,
      name: true,
      username: true,
      email: true,
      avatar: true,
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

/**
 * Delete a user (soft delete by deactivating)
 */
export const deleteUser = async (userId: string, organizationId: string) => {
  const user = await prisma.user.findFirst({
    where: {
      id: userId,
      organizationId,
    },
  });

  if (!user) {
    throw new NotFoundError('User not found');
  }

  // Soft delete: deactivate the user instead of hard delete
  await prisma.user.update({
    where: { id: userId },
    data: { active: false },
  });

  return { success: true, message: 'User deactivated successfully' };
};
