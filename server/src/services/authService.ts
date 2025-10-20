import prisma from '../db/connection';
import { comparePassword } from '../utils/password';
import { generateToken } from '../utils/jwt';
import { UnauthorizedError } from '../utils/errors';

export interface LoginResult {
  token: string;
  user: {
    id: string;
    name: string;
    username: string;
    email: string;
    role: string;
    active: boolean;
    visibleTopicIds: string[];
  };
}

export const login = async (
  usernameOrEmail: string,
  password: string
): Promise<LoginResult> => {
  // Find user by username or email
  const user = await prisma.user.findFirst({
    where: {
      OR: [{ username: usernameOrEmail }, { email: usernameOrEmail }],
    },
    include: {
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

  // Verify password
  const isValidPassword = await comparePassword(password, user.passwordHash);
  if (!isValidPassword) {
    throw new UnauthorizedError('Invalid credentials');
  }

  // Generate JWT token
  const token = generateToken({
    userId: user.id,
    role: user.role,
  });

  return {
    token,
    user: {
      id: user.id,
      name: user.name,
      username: user.username,
      email: user.email,
      role: user.role,
      active: user.active,
      visibleTopicIds: user.accessibleTopics.map((a) => a.topicId),
    },
  };
};
