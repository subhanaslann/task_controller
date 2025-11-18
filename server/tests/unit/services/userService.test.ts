import {
  createUser,
  updateUser,
  getUsers,
  getUser,
  deleteUser,
} from '../../../src/services/userService';
import prisma from '../../../src/db/connection';
import { hashPassword } from '../../../src/utils/password';
import {
  NotFoundError,
  ForbiddenError,
  OrganizationUserLimitReachedError,
} from '../../../src/utils/errors';
import { Role } from '../../../src/types';
import { createMockUser, createMockOrganization } from '../utils/testUtils';

// Mock dependencies
jest.mock('../../../src/db/connection', () => ({
  __esModule: true,
  default: {
    user: {
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      findMany: jest.fn(),
      count: jest.fn(),
    },
    organization: {
      findUnique: jest.fn(),
    },
    guestTopicAccess: {
      createMany: jest.fn(),
      deleteMany: jest.fn(),
    },
  },
}));

jest.mock('../../../src/utils/password');

describe('UserService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('createUser', () => {
    const mockOrganization = createMockOrganization({ maxUsers: 15 });

    beforeEach(() => {
      (hashPassword as jest.Mock).mockResolvedValue('hashed-password');
      (prisma.organization.findUnique as jest.Mock).mockResolvedValue(mockOrganization);
      (prisma.user.count as jest.Mock).mockResolvedValue(5); // Current active users
    });

    it('should create a user successfully', async () => {
      // Arrange
      const input = {
        name: 'New User',
        username: 'newuser',
        email: 'new@example.com',
        password: 'password123',
        role: Role.MEMBER,
      };
      const createdUser = createMockUser(input);
      (prisma.user.create as jest.Mock).mockResolvedValue(createdUser);

      // Act
      const result = await createUser('org-123', input, Role.ADMIN);

      // Assert
      expect(hashPassword).toHaveBeenCalledWith('password123');
      expect(prisma.user.create).toHaveBeenCalledWith({
        data: {
          organizationId: 'org-123',
          name: input.name,
          username: input.username,
          email: input.email,
          passwordHash: 'hashed-password',
          role: input.role,
          active: true,
        },
        select: expect.any(Object),
      });
      expect(result).toEqual(createdUser);
    });

    it('should prevent TEAM_MANAGER from creating ADMIN users', async () => {
      // Arrange
      const input = {
        name: 'Admin User',
        username: 'admin',
        email: 'admin@example.com',
        password: 'password',
        role: Role.ADMIN,
      };

      // Act & Assert
      await expect(createUser('org-123', input, Role.TEAM_MANAGER)).rejects.toThrow(ForbiddenError);
      await expect(createUser('org-123', input, Role.TEAM_MANAGER)).rejects.toThrow(
        'Team Managers cannot create Admin users'
      );
    });

    it('should prevent TEAM_MANAGER from creating other TEAM_MANAGER users', async () => {
      // Arrange
      const input = {
        name: 'Manager User',
        username: 'manager',
        email: 'manager@example.com',
        password: 'password',
        role: Role.TEAM_MANAGER,
      };

      // Act & Assert
      await expect(createUser('org-123', input, Role.TEAM_MANAGER)).rejects.toThrow(ForbiddenError);
      await expect(createUser('org-123', input, Role.TEAM_MANAGER)).rejects.toThrow(
        'Team Managers cannot create other Team Manager users'
      );
    });

    it('should allow TEAM_MANAGER to create MEMBER users', async () => {
      // Arrange
      const input = {
        name: 'Member User',
        username: 'member',
        email: 'member@example.com',
        password: 'password',
        role: Role.MEMBER,
      };
      (prisma.user.create as jest.Mock).mockResolvedValue(createMockUser(input));

      // Act
      await createUser('org-123', input, Role.TEAM_MANAGER);

      // Assert
      expect(prisma.user.create).toHaveBeenCalled();
    });

    it('should throw error when user limit is reached', async () => {
      // Arrange
      (prisma.user.count as jest.Mock).mockResolvedValue(15); // At max limit
      const input = {
        name: 'New User',
        username: 'newuser',
        email: 'new@example.com',
        password: 'password',
        role: Role.MEMBER,
      };

      // Act & Assert
      await expect(createUser('org-123', input, Role.ADMIN)).rejects.toThrow(
        OrganizationUserLimitReachedError
      );
    });

    it('should not check user limit for inactive users', async () => {
      // Arrange
      const input = {
        name: 'Inactive User',
        username: 'inactive',
        email: 'inactive@example.com',
        password: 'password',
        role: Role.MEMBER,
        active: false,
      };
      (prisma.user.create as jest.Mock).mockResolvedValue(createMockUser(input));

      // Act
      await createUser('org-123', input, Role.ADMIN);

      // Assert
      expect(prisma.user.count).not.toHaveBeenCalled();
      expect(prisma.user.create).toHaveBeenCalled();
    });

    it('should create guest topic access for GUEST users', async () => {
      // Arrange
      const input = {
        name: 'Guest User',
        username: 'guest',
        email: 'guest@example.com',
        password: 'password',
        role: Role.GUEST,
        visibleTopicIds: ['topic-1', 'topic-2'],
      };
      const createdUser = createMockUser(input);
      (prisma.user.create as jest.Mock).mockResolvedValue(createdUser);

      // Act
      await createUser('org-123', input, Role.ADMIN);

      // Assert
      expect(prisma.guestTopicAccess.createMany).toHaveBeenCalledWith({
        data: [
          { userId: createdUser.id, topicId: 'topic-1' },
          { userId: createdUser.id, topicId: 'topic-2' },
        ],
      });
    });

    it('should not create guest access if no topics provided', async () => {
      // Arrange
      const input = {
        name: 'Guest User',
        username: 'guest',
        email: 'guest@example.com',
        password: 'password',
        role: Role.GUEST,
      };
      (prisma.user.create as jest.Mock).mockResolvedValue(createMockUser(input));

      // Act
      await createUser('org-123', input, Role.ADMIN);

      // Assert
      expect(prisma.guestTopicAccess.createMany).not.toHaveBeenCalled();
    });
  });

  describe('updateUser', () => {
    const existingUser = createMockUser({ role: Role.MEMBER, active: true });

    beforeEach(() => {
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(existingUser);
      (prisma.organization.findUnique as jest.Mock).mockResolvedValue(
        createMockOrganization({ maxUsers: 15 })
      );
      (prisma.user.count as jest.Mock).mockResolvedValue(10);
    });

    it('should update user successfully', async () => {
      // Arrange
      const input = {
        name: 'Updated Name',
        role: Role.MEMBER,
      };
      const updatedUser = { ...existingUser, ...input };
      (prisma.user.update as jest.Mock).mockResolvedValue(updatedUser);

      // Act
      const result = await updateUser('user-123', 'org-123', input, Role.ADMIN);

      // Assert
      expect(prisma.user.update).toHaveBeenCalledWith({
        where: { id: 'user-123' },
        data: {
          name: 'Updated Name',
          role: Role.MEMBER,
        },
        select: expect.any(Object),
      });
      expect(result).toEqual(updatedUser);
    });

    it('should prevent TEAM_MANAGER from escalating to ADMIN', async () => {
      // Arrange
      const input = {
        role: Role.ADMIN,
      };

      // Act & Assert
      await expect(updateUser('user-123', 'org-123', input, Role.TEAM_MANAGER)).rejects.toThrow(
        ForbiddenError
      );
      await expect(updateUser('user-123', 'org-123', input, Role.TEAM_MANAGER)).rejects.toThrow(
        'Team Managers cannot promote users to Admin'
      );
    });

    it('should prevent TEAM_MANAGER from promoting to TEAM_MANAGER', async () => {
      // Arrange
      const input = {
        role: Role.TEAM_MANAGER,
      };

      // Act & Assert
      await expect(updateUser('user-123', 'org-123', input, Role.TEAM_MANAGER)).rejects.toThrow(
        ForbiddenError
      );
      await expect(updateUser('user-123', 'org-123', input, Role.TEAM_MANAGER)).rejects.toThrow(
        'Team Managers cannot promote users to Team Manager'
      );
    });

    it('should throw NotFoundError if user does not exist', async () => {
      // Arrange
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(null);

      // Act & Assert
      await expect(updateUser('nonexistent', 'org-123', {}, Role.ADMIN)).rejects.toThrow(
        NotFoundError
      );
    });

    it('should check user limit when activating an inactive user', async () => {
      // Arrange
      const inactiveUser = createMockUser({ active: false });
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(inactiveUser);
      (prisma.user.update as jest.Mock).mockResolvedValue({ ...inactiveUser, active: true });

      const input = {
        active: true,
      };

      // Act
      await updateUser('user-123', 'org-123', input, Role.ADMIN);

      // Assert
      expect(prisma.user.count).toHaveBeenCalledWith({
        where: {
          organizationId: 'org-123',
          active: true,
          id: { not: 'user-123' },
        },
      });
    });

    it('should throw error when activating user would exceed limit', async () => {
      // Arrange
      const inactiveUser = createMockUser({ active: false });
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(inactiveUser);
      (prisma.user.count as jest.Mock).mockResolvedValue(15); // At limit

      const input = {
        active: true,
      };

      // Act & Assert
      await expect(updateUser('user-123', 'org-123', input, Role.ADMIN)).rejects.toThrow(
        OrganizationUserLimitReachedError
      );
    });

    it('should hash password when updating', async () => {
      // Arrange
      (hashPassword as jest.Mock).mockResolvedValue('new-hashed-password');
      (prisma.user.update as jest.Mock).mockResolvedValue(existingUser);

      const input = {
        password: 'newpassword123',
      };

      // Act
      await updateUser('user-123', 'org-123', input, Role.ADMIN);

      // Assert
      expect(hashPassword).toHaveBeenCalledWith('newpassword123');
      expect(prisma.user.update).toHaveBeenCalledWith({
        where: { id: 'user-123' },
        data: {
          passwordHash: 'new-hashed-password',
        },
        select: expect.any(Object),
      });
    });

    it('should update guest topic access when provided', async () => {
      // Arrange
      const guestUser = createMockUser({ role: Role.GUEST });
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(guestUser);
      (prisma.user.update as jest.Mock).mockResolvedValue(guestUser);

      const input = {
        visibleTopicIds: ['topic-1', 'topic-2'],
      };

      // Act
      await updateUser('user-123', 'org-123', input, Role.ADMIN);

      // Assert
      expect(prisma.guestTopicAccess.deleteMany).toHaveBeenCalledWith({
        where: { userId: 'user-123' },
      });
      expect(prisma.guestTopicAccess.createMany).toHaveBeenCalledWith({
        data: [
          { userId: 'user-123', topicId: 'topic-1' },
          { userId: 'user-123', topicId: 'topic-2' },
        ],
      });
    });

    it('should clear guest topic access when empty array provided', async () => {
      // Arrange
      const guestUser = createMockUser({ role: Role.GUEST });
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(guestUser);
      (prisma.user.update as jest.Mock).mockResolvedValue(guestUser);

      const input = {
        visibleTopicIds: [],
      };

      // Act
      await updateUser('user-123', 'org-123', input, Role.ADMIN);

      // Assert
      expect(prisma.guestTopicAccess.deleteMany).toHaveBeenCalledWith({
        where: { userId: 'user-123' },
      });
      expect(prisma.guestTopicAccess.createMany).not.toHaveBeenCalled();
    });
  });

  describe('getUsers', () => {
    it('should return all users in organization', async () => {
      // Arrange
      const mockUsers = [
        {
          ...createMockUser(),
          accessibleTopics: [{ topicId: 'topic-1' }],
        },
        {
          ...createMockUser({ id: 'user-456' }),
          accessibleTopics: [],
        },
      ];
      (prisma.user.findMany as jest.Mock).mockResolvedValue(mockUsers);

      // Act
      const result = await getUsers('org-123');

      // Assert
      expect(prisma.user.findMany).toHaveBeenCalledWith({
        where: { organizationId: 'org-123' },
        select: expect.any(Object),
        orderBy: { createdAt: 'desc' },
      });

      expect(result).toHaveLength(2);
      expect(result[0].visibleTopicIds).toEqual(['topic-1']);
      expect(result[1].visibleTopicIds).toEqual([]);
    });
  });

  describe('getUser', () => {
    it('should return a single user', async () => {
      // Arrange
      const mockUser = {
        ...createMockUser(),
        accessibleTopics: [{ topicId: 'topic-1' }, { topicId: 'topic-2' }],
      };
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(mockUser);

      // Act
      const result = await getUser('user-123', 'org-123');

      // Assert
      expect(prisma.user.findFirst).toHaveBeenCalledWith({
        where: {
          id: 'user-123',
          organizationId: 'org-123',
        },
        select: expect.any(Object),
      });
      expect(result.visibleTopicIds).toEqual(['topic-1', 'topic-2']);
    });

    it('should throw NotFoundError if user does not exist', async () => {
      // Arrange
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(null);

      // Act & Assert
      await expect(getUser('nonexistent', 'org-123')).rejects.toThrow(NotFoundError);
      await expect(getUser('nonexistent', 'org-123')).rejects.toThrow('User not found');
    });
  });

  describe('deleteUser', () => {
    it('should soft delete user by deactivating', async () => {
      // Arrange
      const mockUser = createMockUser();
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(mockUser);
      (prisma.user.update as jest.Mock).mockResolvedValue({ ...mockUser, active: false });

      // Act
      const result = await deleteUser('user-123', 'org-123');

      // Assert
      expect(prisma.user.update).toHaveBeenCalledWith({
        where: { id: 'user-123' },
        data: { active: false },
      });
      expect(result).toEqual({
        success: true,
        message: 'User deactivated successfully',
      });
    });

    it('should throw NotFoundError if user does not exist', async () => {
      // Arrange
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(null);

      // Act & Assert
      await expect(deleteUser('nonexistent', 'org-123')).rejects.toThrow(NotFoundError);
    });
  });
});
