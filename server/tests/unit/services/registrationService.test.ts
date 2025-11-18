import { registerTeamManager } from '../../../src/services/registrationService';
import prisma from '../../../src/db/connection';
import { hashPassword } from '../../../src/utils/password';
import { generateToken } from '../../../src/utils/jwt';
import { ConflictError, ValidationError } from '../../../src/utils/errors';
import { Role } from '../../../src/types';
import { createMockUser, createMockOrganization } from '../utils/testUtils';

// Mock dependencies
jest.mock('../../../src/db/connection', () => ({
  __esModule: true,
  default: {
    user: {
      findFirst: jest.fn(),
    },
    organization: {
      findUnique: jest.fn(),
    },
    $transaction: jest.fn(),
  },
}));

jest.mock('../../../src/utils/password');
jest.mock('../../../src/utils/jwt');

describe('RegistrationService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('registerTeamManager', () => {
    const validInput = {
      companyName: 'Test Company',
      teamName: 'Test Team',
      managerName: 'John Doe',
      email: 'john@testcompany.com',
      password: 'SecurePassword123',
    };

    it('should register a new team manager successfully', async () => {
      // Arrange
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(null); // Email not taken
      (prisma.organization.findUnique as jest.Mock).mockResolvedValue(null); // Slug available
      (hashPassword as jest.Mock).mockResolvedValue('hashed-password');
      (generateToken as jest.Mock).mockReturnValue('jwt-token-123');

      const mockOrg = createMockOrganization({
        name: validInput.companyName,
        teamName: validInput.teamName,
        slug: 'test-company-test-team',
      });
      const mockUser = createMockUser({
        name: validInput.managerName,
        email: validInput.email,
        username: 'john',
        role: Role.TEAM_MANAGER,
        organizationId: mockOrg.id,
      });

      (prisma.$transaction as jest.Mock).mockImplementation(async (callback) => {
        return callback({
          organization: {
            create: jest.fn().mockResolvedValue(mockOrg),
          },
          user: {
            create: jest.fn().mockResolvedValue(mockUser),
          },
        });
      });

      // Act
      const result = await registerTeamManager(validInput);

      // Assert
      expect(prisma.user.findFirst).toHaveBeenCalledWith({
        where: { email: validInput.email },
      });
      expect(hashPassword).toHaveBeenCalledWith(validInput.password);
      expect(generateToken).toHaveBeenCalledWith({
        userId: mockUser.id,
        organizationId: mockOrg.id,
        role: Role.TEAM_MANAGER,
        email: mockUser.email,
      });

      expect(result).toEqual({
        organization: {
          id: mockOrg.id,
          name: mockOrg.name,
          teamName: mockOrg.teamName,
          slug: mockOrg.slug,
          isActive: mockOrg.isActive,
          maxUsers: mockOrg.maxUsers,
          createdAt: mockOrg.createdAt,
          updatedAt: mockOrg.updatedAt,
        },
        user: {
          id: mockUser.id,
          organizationId: mockUser.organizationId,
          name: mockUser.name,
          username: mockUser.username,
          email: mockUser.email,
          role: mockUser.role,
          active: mockUser.active,
          createdAt: mockUser.createdAt,
          updatedAt: mockUser.updatedAt,
        },
        token: 'jwt-token-123',
      });
    });

    it('should throw ConflictError if email is already registered', async () => {
      // Arrange
      const existingUser = createMockUser({ email: validInput.email });
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(existingUser);

      // Act & Assert
      await expect(registerTeamManager(validInput)).rejects.toThrow(ConflictError);
      await expect(registerTeamManager(validInput)).rejects.toThrow('Email is already registered');
    });

    it('should generate unique slug when slug already exists', async () => {
      // Arrange
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(null);
      (hashPassword as jest.Mock).mockResolvedValue('hashed-password');
      (generateToken as jest.Mock).mockReturnValue('jwt-token');

      // Mock slug collision: first slug exists, second slug (with -1) is available
      (prisma.organization.findUnique as jest.Mock)
        .mockResolvedValueOnce(createMockOrganization({ slug: 'test-company-test-team' }))
        .mockResolvedValueOnce(null);

      const mockOrg = createMockOrganization({ slug: 'test-company-test-team-1' });
      const mockUser = createMockUser();

      (prisma.$transaction as jest.Mock).mockImplementation(async (callback) => {
        return callback({
          organization: {
            create: jest.fn().mockResolvedValue(mockOrg),
          },
          user: {
            create: jest.fn().mockResolvedValue(mockUser),
          },
        });
      });

      // Act
      const result = await registerTeamManager(validInput);

      // Assert
      expect(prisma.organization.findUnique).toHaveBeenCalledTimes(2);
      expect(result.organization.slug).toBe('test-company-test-team-1');
    });

    it('should throw ValidationError if slug generation fails', async () => {
      // Arrange
      const invalidInput = {
        ...validInput,
        companyName: '!!!', // Will generate empty slug
        teamName: '@@@',
      };
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(null);

      // Act & Assert
      await expect(registerTeamManager(invalidInput)).rejects.toThrow(ValidationError);
      await expect(registerTeamManager(invalidInput)).rejects.toThrow(
        'Could not generate valid slug from company and team names'
      );
    });

    it('should generate username from email prefix', async () => {
      // Arrange
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(null);
      (prisma.organization.findUnique as jest.Mock).mockResolvedValue(null);
      (hashPassword as jest.Mock).mockResolvedValue('hashed-password');
      (generateToken as jest.Mock).mockReturnValue('jwt-token');

      const mockOrg = createMockOrganization();
      const mockUser = createMockUser({ username: 'john' });

      let createdUserData: any;
      (prisma.$transaction as jest.Mock).mockImplementation(async (callback) => {
        return callback({
          organization: {
            create: jest.fn().mockResolvedValue(mockOrg),
          },
          user: {
            create: jest.fn().mockImplementation((data) => {
              createdUserData = data.data;
              return Promise.resolve(mockUser);
            }),
          },
        });
      });

      // Act
      await registerTeamManager(validInput);

      // Assert
      expect(createdUserData.username).toBe('john'); // From email 'john@testcompany.com'
    });

    it('should create organization with correct default values', async () => {
      // Arrange
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(null);
      (prisma.organization.findUnique as jest.Mock).mockResolvedValue(null);
      (hashPassword as jest.Mock).mockResolvedValue('hashed-password');
      (generateToken as jest.Mock).mockReturnValue('jwt-token');

      const mockOrg = createMockOrganization();
      const mockUser = createMockUser();

      let createdOrgData: any;
      (prisma.$transaction as jest.Mock).mockImplementation(async (callback) => {
        return callback({
          organization: {
            create: jest.fn().mockImplementation((data) => {
              createdOrgData = data.data;
              return Promise.resolve(mockOrg);
            }),
          },
          user: {
            create: jest.fn().mockResolvedValue(mockUser),
          },
        });
      });

      // Act
      await registerTeamManager(validInput);

      // Assert
      expect(createdOrgData).toMatchObject({
        name: validInput.companyName,
        teamName: validInput.teamName,
        isActive: true,
        maxUsers: 15,
      });
    });

    it('should create user with TEAM_MANAGER role', async () => {
      // Arrange
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(null);
      (prisma.organization.findUnique as jest.Mock).mockResolvedValue(null);
      (hashPassword as jest.Mock).mockResolvedValue('hashed-password');
      (generateToken as jest.Mock).mockReturnValue('jwt-token');

      const mockOrg = createMockOrganization();
      const mockUser = createMockUser({ role: Role.TEAM_MANAGER });

      let createdUserData: any;
      (prisma.$transaction as jest.Mock).mockImplementation(async (callback) => {
        return callback({
          organization: {
            create: jest.fn().mockResolvedValue(mockOrg),
          },
          user: {
            create: jest.fn().mockImplementation((data) => {
              createdUserData = data.data;
              return Promise.resolve(mockUser);
            }),
          },
        });
      });

      // Act
      await registerTeamManager(validInput);

      // Assert
      expect(createdUserData).toMatchObject({
        role: Role.TEAM_MANAGER,
        active: true,
      });
    });

    it('should handle transaction rollback on error', async () => {
      // Arrange
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(null);
      (prisma.organization.findUnique as jest.Mock).mockResolvedValue(null);
      (hashPassword as jest.Mock).mockResolvedValue('hashed-password');

      (prisma.$transaction as jest.Mock).mockRejectedValue(new Error('Database error'));

      // Act & Assert
      await expect(registerTeamManager(validInput)).rejects.toThrow('Database error');
    });

    it('should generate slug from special characters correctly', async () => {
      // Arrange
      const inputWithSpecialChars = {
        ...validInput,
        companyName: 'Test & Company!',
        teamName: 'Team #1',
      };
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(null);
      (prisma.organization.findUnique as jest.Mock).mockResolvedValue(null);
      (hashPassword as jest.Mock).mockResolvedValue('hashed-password');
      (generateToken as jest.Mock).mockReturnValue('jwt-token');

      const mockOrg = createMockOrganization({ slug: 'test-company-team-1' });
      const mockUser = createMockUser();

      (prisma.$transaction as jest.Mock).mockImplementation(async (callback) => {
        return callback({
          organization: {
            create: jest.fn().mockResolvedValue(mockOrg),
          },
          user: {
            create: jest.fn().mockResolvedValue(mockUser),
          },
        });
      });

      // Act
      const result = await registerTeamManager(inputWithSpecialChars);

      // Assert
      // Slug should be lowercase, special characters removed, spaces replaced with dashes
      expect(result.organization.slug).toMatch(/^[a-z0-9-]+$/);
    });
  });
});
