import {
  createTopic,
  updateTopic,
  deleteTopic,
  getTopic,
  getTopics,
  getActiveTopics,
} from '../../../src/services/topicService';
import prisma from '../../../src/db/connection';
import { NotFoundError } from '../../../src/utils/errors';
import { Role } from '../../../src/types';
import { createMockTopic, createMockTask } from '../utils/testUtils';

// Mock Prisma
jest.mock('../../../src/db/connection', () => ({
  __esModule: true,
  default: {
    topic: {
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
      findFirst: jest.fn(),
      findMany: jest.fn(),
    },
  },
}));

describe('TopicService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('createTopic', () => {
    it('should create a topic successfully', async () => {
      // Arrange
      const input = {
        title: 'New Topic',
        description: 'Topic description',
        isActive: true,
      };
      const createdTopic = createMockTopic(input);
      (prisma.topic.create as jest.Mock).mockResolvedValue(createdTopic);

      // Act
      const result = await createTopic('org-123', input);

      // Assert
      expect(prisma.topic.create).toHaveBeenCalledWith({
        data: {
          organizationId: 'org-123',
          title: input.title,
          description: input.description,
          isActive: input.isActive,
        },
      });
      expect(result).toEqual(createdTopic);
    });

    it('should default isActive to true when not provided', async () => {
      // Arrange
      const input = {
        title: 'New Topic',
        description: 'Topic description',
      };
      (prisma.topic.create as jest.Mock).mockResolvedValue(createMockTopic());

      // Act
      await createTopic('org-123', input);

      // Assert
      expect(prisma.topic.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          isActive: true,
        }),
      });
    });
  });

  describe('updateTopic', () => {
    const mockTopic = createMockTopic();

    it('should update topic successfully', async () => {
      // Arrange
      (prisma.topic.findFirst as jest.Mock).mockResolvedValue(mockTopic);
      (prisma.topic.update as jest.Mock).mockResolvedValue({
        ...mockTopic,
        title: 'Updated Title',
      });

      const input = {
        title: 'Updated Title',
      };

      // Act
      const result = await updateTopic('topic-123', 'org-123', input);

      // Assert
      expect(prisma.topic.findFirst).toHaveBeenCalledWith({
        where: {
          id: 'topic-123',
          organizationId: 'org-123',
        },
      });
      expect(prisma.topic.update).toHaveBeenCalledWith({
        where: { id: 'topic-123' },
        data: {
          title: 'Updated Title',
        },
      });
      expect(result.title).toBe('Updated Title');
    });

    it('should throw NotFoundError if topic does not exist', async () => {
      // Arrange
      (prisma.topic.findFirst as jest.Mock).mockResolvedValue(null);

      // Act & Assert
      await expect(updateTopic('nonexistent', 'org-123', { title: 'Test' })).rejects.toThrow(
        NotFoundError
      );
      await expect(updateTopic('nonexistent', 'org-123', { title: 'Test' })).rejects.toThrow(
        'Topic not found'
      );
    });

    it('should update multiple fields', async () => {
      // Arrange
      (prisma.topic.findFirst as jest.Mock).mockResolvedValue(mockTopic);
      (prisma.topic.update as jest.Mock).mockResolvedValue({
        ...mockTopic,
        title: 'New Title',
        description: 'New Description',
        isActive: false,
      });

      const input = {
        title: 'New Title',
        description: 'New Description',
        isActive: false,
      };

      // Act
      await updateTopic('topic-123', 'org-123', input);

      // Assert
      expect(prisma.topic.update).toHaveBeenCalledWith({
        where: { id: 'topic-123' },
        data: {
          title: 'New Title',
          description: 'New Description',
          isActive: false,
        },
      });
    });
  });

  describe('deleteTopic', () => {
    const mockTopic = createMockTopic();

    it('should delete topic successfully', async () => {
      // Arrange
      (prisma.topic.findFirst as jest.Mock).mockResolvedValue(mockTopic);
      (prisma.topic.delete as jest.Mock).mockResolvedValue(mockTopic);

      // Act
      const result = await deleteTopic('topic-123', 'org-123');

      // Assert
      expect(prisma.topic.findFirst).toHaveBeenCalledWith({
        where: {
          id: 'topic-123',
          organizationId: 'org-123',
        },
      });
      expect(prisma.topic.delete).toHaveBeenCalledWith({
        where: { id: 'topic-123' },
      });
      expect(result).toEqual({
        success: true,
        message: 'Topic deleted successfully',
      });
    });

    it('should throw NotFoundError if topic does not exist', async () => {
      // Arrange
      (prisma.topic.findFirst as jest.Mock).mockResolvedValue(null);

      // Act & Assert
      await expect(deleteTopic('nonexistent', 'org-123')).rejects.toThrow(NotFoundError);
    });
  });

  describe('getTopic', () => {
    it('should return topic with tasks', async () => {
      // Arrange
      const mockTopic = {
        ...createMockTopic(),
        tasks: [
          {
            ...createMockTask(),
            assignee: {
              id: 'user-1',
              name: 'John Doe',
              username: 'john',
            },
          },
        ],
      };
      (prisma.topic.findFirst as jest.Mock).mockResolvedValue(mockTopic);

      // Act
      const result = await getTopic('topic-123', 'org-123');

      // Assert
      expect(prisma.topic.findFirst).toHaveBeenCalledWith({
        where: {
          id: 'topic-123',
          organizationId: 'org-123',
        },
        include: {
          tasks: {
            where: { organizationId: 'org-123' },
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
      expect(result).toEqual(mockTopic);
    });

    it('should throw NotFoundError if topic does not exist', async () => {
      // Arrange
      (prisma.topic.findFirst as jest.Mock).mockResolvedValue(null);

      // Act & Assert
      await expect(getTopic('nonexistent', 'org-123')).rejects.toThrow(NotFoundError);
      await expect(getTopic('nonexistent', 'org-123')).rejects.toThrow('Topic not found');
    });
  });

  describe('getTopics', () => {
    it('should return all topics with task count', async () => {
      // Arrange
      const mockTopics = [
        { ...createMockTopic(), _count: { tasks: 5 } },
        { ...createMockTopic({ id: 'topic-456' }), _count: { tasks: 3 } },
      ];
      (prisma.topic.findMany as jest.Mock).mockResolvedValue(mockTopics);

      // Act
      const result = await getTopics('org-123');

      // Assert
      expect(prisma.topic.findMany).toHaveBeenCalledWith({
        where: { organizationId: 'org-123' },
        orderBy: { createdAt: 'desc' },
        include: {
          _count: {
            select: { tasks: true },
          },
        },
      });
      expect(result).toEqual(mockTopics);
    });
  });

  describe('getActiveTopics', () => {
    it('should return active topics for non-guest users', async () => {
      // Arrange
      const mockTopics = [
        {
          ...createMockTopic(),
          tasks: [createMockTask()],
        },
      ];
      (prisma.topic.findMany as jest.Mock).mockResolvedValue(mockTopics);

      // Act
      const result = await getActiveTopics('org-123', 'user-123', Role.MEMBER);

      // Assert
      expect(prisma.topic.findMany).toHaveBeenCalledWith({
        where: {
          organizationId: 'org-123',
          isActive: true,
        },
        orderBy: { createdAt: 'desc' },
        include: expect.any(Object),
      });
      expect(result).toEqual(mockTopics);
    });

    it('should filter topics for guest users based on access', async () => {
      // Arrange
      const mockTopics = [
        {
          ...createMockTopic(),
          tasks: [],
        },
      ];
      (prisma.topic.findMany as jest.Mock).mockResolvedValue(mockTopics);

      // Act
      const result = await getActiveTopics('org-123', 'guest-123', Role.GUEST);

      // Assert
      expect(prisma.topic.findMany).toHaveBeenCalledWith({
        where: {
          organizationId: 'org-123',
          isActive: true,
          guestAccess: {
            some: {
              userId: 'guest-123',
            },
          },
        },
        orderBy: { createdAt: 'desc' },
        include: expect.any(Object),
      });
    });

    it('should work without userId and role parameters', async () => {
      // Arrange
      const mockTopics = [createMockTopic()];
      (prisma.topic.findMany as jest.Mock).mockResolvedValue(mockTopics);

      // Act
      await getActiveTopics('org-123');

      // Assert
      expect(prisma.topic.findMany).toHaveBeenCalledWith({
        where: {
          organizationId: 'org-123',
          isActive: true,
        },
        orderBy: { createdAt: 'desc' },
        include: expect.any(Object),
      });
    });
  });
});
