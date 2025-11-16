import prisma from '../db/connection';
import { NotFoundError } from '../utils/errors';
import { UpdateOrganizationDto, OrganizationStatsResponse, OrganizationResponse } from '../types';

/**
 * Get organization by ID
 */
export async function getOrganizationById(id: string): Promise<OrganizationResponse> {
  const organization = await prisma.organization.findUnique({
    where: { id },
  });

  if (!organization) {
    throw new NotFoundError('Organization not found');
  }

  return {
    id: organization.id,
    name: organization.name,
    teamName: organization.teamName,
    slug: organization.slug,
    isActive: organization.isActive,
    maxUsers: organization.maxUsers,
    createdAt: organization.createdAt,
    updatedAt: organization.updatedAt,
  };
}

/**
 * Update organization details (TEAM_MANAGER or ADMIN only)
 */
export async function updateOrganization(
  id: string,
  data: UpdateOrganizationDto
): Promise<OrganizationResponse> {
  const organization = await prisma.organization.update({
    where: { id },
    data: {
      ...(data.name && { name: data.name }),
      ...(data.teamName && { teamName: data.teamName }),
      ...(data.maxUsers !== undefined && { maxUsers: data.maxUsers }),
    },
  });

  return {
    id: organization.id,
    name: organization.name,
    teamName: organization.teamName,
    slug: organization.slug,
    isActive: organization.isActive,
    maxUsers: organization.maxUsers,
    createdAt: organization.createdAt,
    updatedAt: organization.updatedAt,
  };
}

/**
 * Get organization statistics
 */
export async function getOrganizationStats(organizationId: string): Promise<OrganizationStatsResponse> {
  const [userCount, activeUserCount, taskCount, activeTaskCount, completedTaskCount, topicCount, activeTopicCount] = await Promise.all([
    prisma.user.count({
      where: { organizationId },
    }),
    prisma.user.count({
      where: { organizationId, active: true },
    }),
    prisma.task.count({
      where: { organizationId },
    }),
    prisma.task.count({
      where: { organizationId, status: { in: ['TODO', 'IN_PROGRESS'] } },
    }),
    prisma.task.count({
      where: { organizationId, status: 'DONE' },
    }),
    prisma.topic.count({
      where: { organizationId },
    }),
    prisma.topic.count({
      where: { organizationId, isActive: true },
    }),
  ]);

  return {
    userCount,
    activeUserCount,
    taskCount,
    activeTaskCount,
    completedTaskCount,
    topicCount,
    activeTopicCount,
  };
}

/**
 * Deactivate organization (ADMIN only)
 */
export async function deactivateOrganization(id: string): Promise<void> {
  await prisma.organization.update({
    where: { id },
    data: { isActive: false },
  });
}

/**
 * Activate organization (ADMIN only)
 */
export async function activateOrganization(id: string): Promise<void> {
  await prisma.organization.update({
    where: { id },
    data: { isActive: true },
  });
}
