import {
  getOrganizationById,
  updateOrganization,
  getOrganizationStats,
  deactivateOrganization,
  activateOrganization,
} from '../../../src/services/organizationService';
import prisma from '../../../src/db/connection';
import { NotFoundError } from '../../../src/utils/errors';
import { createMockOrganization } from '../utils/testUtils';

// Mock Prisma
jest.mock('../../../src/db/connection', () => ({
  __esModule: true,
  default: {
    organization: {
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    user: {
      count: jest.fn(),
    },
    task: {
      count: jest.fn(),
    },
    topic: {
      count: jest.fn(),
    },
  },
}));

describe('OrganizationService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getOrganizationById', () => {
    it('should return organization by id', async () => {
      // Arrange
      const mockOrganization = createMockOrganization();
      (prisma.organization.findUnique as jest.Mock).mockResolvedValue(mockOrganization);

      // Act
      const result = await getOrganizationById('org-123');

      // Assert
      expect(prisma.organization.findUnique).toHaveBeenCalledWith({
        where: { id: 'org-123' },
      });
      expect(result).toEqual({
        id: mockOrganization.id,
        name: mockOrganization.name,
        teamName: mockOrganization.teamName,
        slug: mockOrganization.slug,
        isActive: mockOrganization.isActive,
        maxUsers: mockOrganization.maxUsers,
        createdAt: mockOrganization.createdAt,
        updatedAt: mockOrganization.updatedAt,
      });
    });

    it('should throw NotFoundError when organization does not exist', async () => {
      // Arrange
      (prisma.organization.findUnique as jest.Mock).mockResolvedValue(null);

      // Act & Assert
      await expect(getOrganizationById('nonexistent')).rejects.toThrow(NotFoundError);
      await expect(getOrganizationById('nonexistent')).rejects.toThrow('Organization not found');
    });
  });

  describe('updateOrganization', () => {
    it('should update organization name', async () => {
      // Arrange
      const mockOrganization = createMockOrganization();
      (prisma.organization.update as jest.Mock).mockResolvedValue({
        ...mockOrganization,
        name: 'Updated Company',
      });

      // Act
      const result = await updateOrganization('org-123', { name: 'Updated Company' });

      // Assert
      expect(prisma.organization.update).toHaveBeenCalledWith({
        where: { id: 'org-123' },
        data: {
          name: 'Updated Company',
        },
      });
      expect(result.name).toBe('Updated Company');
    });

    it('should update organization teamName', async () => {
      // Arrange
      const mockOrganization = createMockOrganization();
      (prisma.organization.update as jest.Mock).mockResolvedValue({
        ...mockOrganization,
        teamName: 'Updated Team',
      });

      // Act
      const result = await updateOrganization('org-123', { teamName: 'Updated Team' });

      // Assert
      expect(prisma.organization.update).toHaveBeenCalledWith({
        where: { id: 'org-123' },
        data: {
          teamName: 'Updated Team',
        },
      });
      expect(result.teamName).toBe('Updated Team');
    });

    it('should update organization maxUsers', async () => {
      // Arrange
      const mockOrganization = createMockOrganization();
      (prisma.organization.update as jest.Mock).mockResolvedValue({
        ...mockOrganization,
        maxUsers: 25,
      });

      // Act
      const result = await updateOrganization('org-123', { maxUsers: 25 });

      // Assert
      expect(prisma.organization.update).toHaveBeenCalledWith({
        where: { id: 'org-123' },
        data: {
          maxUsers: 25,
        },
      });
      expect(result.maxUsers).toBe(25);
    });

    it('should update multiple fields at once', async () => {
      // Arrange
      const mockOrganization = createMockOrganization();
      (prisma.organization.update as jest.Mock).mockResolvedValue({
        ...mockOrganization,
        name: 'New Company',
        teamName: 'New Team',
        maxUsers: 20,
      });

      // Act
      const result = await updateOrganization('org-123', {
        name: 'New Company',
        teamName: 'New Team',
        maxUsers: 20,
      });

      // Assert
      expect(prisma.organization.update).toHaveBeenCalledWith({
        where: { id: 'org-123' },
        data: {
          name: 'New Company',
          teamName: 'New Team',
          maxUsers: 20,
        },
      });
    });
  });

  describe('getOrganizationStats', () => {
    it('should return organization statistics', async () => {
      // Arrange
      (prisma.user.count as jest.Mock)
        .mockResolvedValueOnce(20) // userCount
        .mockResolvedValueOnce(18); // activeUserCount
      (prisma.task.count as jest.Mock)
        .mockResolvedValueOnce(100) // taskCount
        .mockResolvedValueOnce(60) // activeTaskCount
        .mockResolvedValueOnce(40); // completedTaskCount
      (prisma.topic.count as jest.Mock)
        .mockResolvedValueOnce(10) // topicCount
        .mockResolvedValueOnce(8); // activeTopicCount

      // Act
      const result = await getOrganizationStats('org-123');

      // Assert
      expect(result).toEqual({
        userCount: 20,
        activeUserCount: 18,
        taskCount: 100,
        activeTaskCount: 60,
        completedTaskCount: 40,
        topicCount: 10,
        activeTopicCount: 8,
      });

      // Verify all count calls
      expect(prisma.user.count).toHaveBeenCalledTimes(2);
      expect(prisma.task.count).toHaveBeenCalledTimes(3);
      expect(prisma.topic.count).toHaveBeenCalledTimes(2);
    });

    it('should return zero stats for empty organization', async () => {
      // Arrange
      (prisma.user.count as jest.Mock).mockResolvedValue(0);
      (prisma.task.count as jest.Mock).mockResolvedValue(0);
      (prisma.topic.count as jest.Mock).mockResolvedValue(0);

      // Act
      const result = await getOrganizationStats('org-123');

      // Assert
      expect(result).toEqual({
        userCount: 0,
        activeUserCount: 0,
        taskCount: 0,
        activeTaskCount: 0,
        completedTaskCount: 0,
        topicCount: 0,
        activeTopicCount: 0,
      });
    });
  });

  describe('deactivateOrganization', () => {
    it('should deactivate organization', async () => {
      // Arrange
      const mockOrganization = createMockOrganization({ isActive: false });
      (prisma.organization.update as jest.Mock).mockResolvedValue(mockOrganization);

      // Act
      await deactivateOrganization('org-123');

      // Assert
      expect(prisma.organization.update).toHaveBeenCalledWith({
        where: { id: 'org-123' },
        data: { isActive: false },
      });
    });
  });

  describe('activateOrganization', () => {
    it('should activate organization', async () => {
      // Arrange
      const mockOrganization = createMockOrganization({ isActive: true });
      (prisma.organization.update as jest.Mock).mockResolvedValue(mockOrganization);

      // Act
      await activateOrganization('org-123');

      // Assert
      expect(prisma.organization.update).toHaveBeenCalledWith({
        where: { id: 'org-123' },
        data: { isActive: true },
      });
    });
  });
});
