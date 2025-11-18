import { login } from '../../../src/services/authService';
import prisma from '../../../src/db/connection';
import { comparePassword } from '../../../src/utils/password';
import { generateToken } from '../../../src/utils/jwt';
import { UnauthorizedError, OrganizationInactiveError } from '../../../src/utils/errors';
import { Role } from '../../../src/types';
import { createMockUser, createMockOrganization } from '../utils/testUtils';

// Mock dependencies
jest.mock('../../../src/db/connection', () => ({
  __esModule: true,
  default: {
    user: {
      findFirst: jest.fn(),
    },
  },
}));

jest.mock('../../../src/utils/password');
jest.mock('../../../src/utils/jwt');

describe('AuthService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('login', () => {
    const mockOrganization = createMockOrganization();
    const mockAccessibleTopics = [
      { topicId: 'topic-1' },
      { topicId: 'topic-2' },
    ];

    const mockUserWithOrg = {
      ...createMockUser(),
      organization: mockOrganization,
      accessibleTopics: mockAccessibleTopics,
    };

    it('should successfully login with username', async () => {
      // Arrange
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(mockUserWithOrg);
      (comparePassword as jest.Mock).mockResolvedValue(true);
      (generateToken as jest.Mock).mockReturnValue('mock-token-123');

      // Act
      const result = await login('testuser', 'password123');

      // Assert
      expect(prisma.user.findFirst).toHaveBeenCalledWith({
        where: {
          OR: [{ username: 'testuser' }, { email: 'testuser' }],
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

      expect(comparePassword).toHaveBeenCalledWith('password123', mockUserWithOrg.passwordHash);
      expect(generateToken).toHaveBeenCalledWith({
        userId: mockUserWithOrg.id,
        organizationId: mockUserWithOrg.organizationId,
        role: mockUserWithOrg.role,
        email: mockUserWithOrg.email,
      });

      expect(result).toEqual({
        token: 'mock-token-123',
        user: {
          id: mockUserWithOrg.id,
          organizationId: mockUserWithOrg.organizationId,
          name: mockUserWithOrg.name,
          username: mockUserWithOrg.username,
          email: mockUserWithOrg.email,
          role: mockUserWithOrg.role,
          active: mockUserWithOrg.active,
          visibleTopicIds: ['topic-1', 'topic-2'],
          createdAt: mockUserWithOrg.createdAt.toISOString(),
          updatedAt: mockUserWithOrg.updatedAt.toISOString(),
        },
        organization: {
          id: mockOrganization.id,
          name: mockOrganization.name,
          teamName: mockOrganization.teamName,
          slug: mockOrganization.slug,
          isActive: mockOrganization.isActive,
          maxUsers: mockOrganization.maxUsers,
          createdAt: mockOrganization.createdAt.toISOString(),
          updatedAt: mockOrganization.updatedAt.toISOString(),
        },
      });
    });

    it('should successfully login with email', async () => {
      // Arrange
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(mockUserWithOrg);
      (comparePassword as jest.Mock).mockResolvedValue(true);
      (generateToken as jest.Mock).mockReturnValue('mock-token-456');

      // Act
      const result = await login('test@example.com', 'password123');

      // Assert
      expect(prisma.user.findFirst).toHaveBeenCalledWith({
        where: {
          OR: [{ username: 'test@example.com' }, { email: 'test@example.com' }],
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

      expect(result.token).toBe('mock-token-456');
    });

    it('should throw UnauthorizedError when user not found', async () => {
      // Arrange
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(null);

      // Act & Assert
      await expect(login('nonexistent', 'password123')).rejects.toThrow(UnauthorizedError);
      await expect(login('nonexistent', 'password123')).rejects.toThrow('Invalid credentials');
    });

    it('should throw UnauthorizedError when user is inactive', async () => {
      // Arrange
      const inactiveUser = {
        ...mockUserWithOrg,
        active: false,
      };
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(inactiveUser);

      // Act & Assert
      await expect(login('testuser', 'password123')).rejects.toThrow(UnauthorizedError);
      await expect(login('testuser', 'password123')).rejects.toThrow('Account is deactivated');
    });

    it('should throw OrganizationInactiveError when organization is inactive', async () => {
      // Arrange
      const userWithInactiveOrg = {
        ...mockUserWithOrg,
        organization: {
          ...mockOrganization,
          isActive: false,
        },
      };
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(userWithInactiveOrg);

      // Act & Assert
      await expect(login('testuser', 'password123')).rejects.toThrow(OrganizationInactiveError);
      await expect(login('testuser', 'password123')).rejects.toThrow(
        'Your organization has been deactivated. Please contact support.'
      );
    });

    it('should throw UnauthorizedError when password is invalid', async () => {
      // Arrange
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(mockUserWithOrg);
      (comparePassword as jest.Mock).mockResolvedValue(false);

      // Act & Assert
      await expect(login('testuser', 'wrongpassword')).rejects.toThrow(UnauthorizedError);
      await expect(login('testuser', 'wrongpassword')).rejects.toThrow('Invalid credentials');
    });

    it('should include empty visibleTopicIds when user has no accessible topics', async () => {
      // Arrange
      const userWithNoTopics = {
        ...mockUserWithOrg,
        accessibleTopics: [],
      };
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(userWithNoTopics);
      (comparePassword as jest.Mock).mockResolvedValue(true);
      (generateToken as jest.Mock).mockReturnValue('mock-token');

      // Act
      const result = await login('testuser', 'password123');

      // Assert
      expect(result.user.visibleTopicIds).toEqual([]);
    });

    it('should handle different user roles', async () => {
      // Test ADMIN role
      const adminUser = {
        ...mockUserWithOrg,
        role: Role.ADMIN,
      };
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(adminUser);
      (comparePassword as jest.Mock).mockResolvedValue(true);
      (generateToken as jest.Mock).mockReturnValue('admin-token');

      const adminResult = await login('admin', 'password');
      expect(adminResult.user.role).toBe(Role.ADMIN);
      expect(generateToken).toHaveBeenCalledWith(
        expect.objectContaining({ role: Role.ADMIN })
      );

      // Test TEAM_MANAGER role
      const managerUser = {
        ...mockUserWithOrg,
        role: Role.TEAM_MANAGER,
      };
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(managerUser);
      const managerResult = await login('manager', 'password');
      expect(managerResult.user.role).toBe(Role.TEAM_MANAGER);
    });
  });
});
