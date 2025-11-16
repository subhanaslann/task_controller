import prisma from '../db/connection';
import { comparePassword } from '../utils/password';
import { generateToken } from '../utils/jwt';
import { UnauthorizedError, OrganizationInactiveError } from '../utils/errors';
import { Role } from '@prisma/client';

export interface LoginResult {
  token: string;
  user: {
    id: string;
    organizationId: string;
    name: string;
    username: string;
    email: string;
    role: Role;
    active: boolean;
    visibleTopicIds: string[];
  };
  organization: {
    id: string;
    name: string;
    teamName: string;
    slug: string;
  };
}

export const login = async (
  usernameOrEmail: string,
  password: string
): Promise<LoginResult> => {
  // Find user by username or email, including organization
  const user = await prisma.user.findFirst({
    where: {
      OR: [{ username: usernameOrEmail }, { email: usernameOrEmail }],
    },
    include: {
      organization: true,
      accessibleTopics: {
        select: {
          topicId: true,
        },
      },
    },
  });

  if (!user) {
    throw new UnauthorizedError('Invalid credentials');
  }

  // Check if user is active
  if (!user.active) {
    throw new UnauthorizedError('Account is deactivated');
  }

  // Check if organization is active
  if (!user.organization.isActive) {
    throw new OrganizationInactiveError('Your organization has been deactivated. Please contact support.');
  }

  // Verify password
  const isValidPassword = await comparePassword(password, user.passwordHash);
  if (!isValidPassword) {
    throw new UnauthorizedError('Invalid credentials');
  }

  // Generate JWT token with organizationId
  const token = generateToken({
    userId: user.id,
    organizationId: user.organizationId,
    role: user.role,
    email: user.email,
  });

  return {
    token,
    user: {
      id: user.id,
      organizationId: user.organizationId,
      name: user.name,
      username: user.username,
      email: user.email,
      role: user.role,
      active: user.active,
      visibleTopicIds: user.accessibleTopics.map((a) => a.topicId),
    },
    organization: {
      id: user.organization.id,
      name: user.organization.name,
      teamName: user.organization.teamName,
      slug: user.organization.slug,
    },
  };
};
