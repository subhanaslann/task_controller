import {
  getMyActiveTasks,
  getTeamActiveTasks,
  getMyCompletedTasks,
  updateTaskStatus,
  createTask,
  createMemberTask,
  updateTask,
  updateMemberTask,
  deleteTask,
  getAllTasks,
  getTask,
} from '../../../src/services/taskService';
import prisma from '../../../src/db/connection';
import { NotFoundError, ForbiddenError, ValidationError } from '../../../src/utils/errors';
import { Role } from '../../../src/types';
import { createMockTask, createMockTopic, createMockUser } from '../utils/testUtils';

// Mock Prisma
jest.mock('../../../src/db/connection', () => ({
  __esModule: true,
  default: {
    task: {
      findMany: jest.fn(),
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
    topic: {
      findFirst: jest.fn(),
    },
    user: {
      findFirst: jest.fn(),
    },
  },
}));

describe('TaskService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getMyActiveTasks', () => {
    it('should return active tasks for a user', async () => {
      // Arrange
      const mockTasks = [
        createMockTask({ status: 'TODO' }),
        createMockTask({ status: 'IN_PROGRESS' }),
      ];
      (prisma.task.findMany as jest.Mock).mockResolvedValue(mockTasks);

      // Act
      const result = await getMyActiveTasks('user-123', 'org-123');

      // Assert
      expect(prisma.task.findMany).toHaveBeenCalledWith({
        where: {
          organizationId: 'org-123',
          assigneeId: 'user-123',
          status: { in: ['TODO', 'IN_PROGRESS'] },
        },
        select: expect.any(Object),
        orderBy: [{ priority: 'desc' }, { dueDate: 'asc' }, { createdAt: 'desc' }],
      });
      expect(result).toEqual(mockTasks);
    });

    it('should return empty array when no active tasks exist', async () => {
      // Arrange
      (prisma.task.findMany as jest.Mock).mockResolvedValue([]);

      // Act
      const result = await getMyActiveTasks('user-123', 'org-123');

      // Assert
      expect(result).toEqual([]);
    });
  });

  describe('getTeamActiveTasks', () => {
    it('should return all active tasks for non-guest users', async () => {
      // Arrange
      const mockTasks = [
        createMockTask({ status: 'TODO' }),
        createMockTask({ status: 'IN_PROGRESS' }),
      ];
      (prisma.task.findMany as jest.Mock).mockResolvedValue(mockTasks);

      // Act
      const result = await getTeamActiveTasks('org-123', Role.MEMBER);

      // Assert
      expect(prisma.task.findMany).toHaveBeenCalledWith({
        where: {
          organizationId: 'org-123',
          status: { in: ['TODO', 'IN_PROGRESS'] },
        },
        select: expect.any(Object),
        orderBy: [{ priority: 'desc' }, { dueDate: 'asc' }, { createdAt: 'desc' }],
      });
      expect(result).toEqual(mockTasks);
    });

    it('should filter sensitive fields for guest users', async () => {
      // Arrange
      const mockTasks = [
        {
          ...createMockTask(),
          note: 'Sensitive note',
          assignee: { id: 'user-1', name: 'John Doe', username: 'john' },
        },
      ];
      (prisma.task.findMany as jest.Mock).mockResolvedValue(mockTasks);

      // Act
      const result = await getTeamActiveTasks('org-123', Role.GUEST);

      // Assert
      expect(result).toEqual([
        {
          id: mockTasks[0].id,
          title: mockTasks[0].title,
          status: mockTasks[0].status,
          priority: mockTasks[0].priority,
          dueDate: mockTasks[0].dueDate,
          assignee: {
            id: 'user-1',
            name: 'John Doe',
          },
        },
      ]);
      // Ensure sensitive fields are not included
      expect(result[0]).not.toHaveProperty('note');
      expect(result[0]).not.toHaveProperty('organizationId');
    });

    it('should handle tasks without assignees for guest users', async () => {
      // Arrange
      const mockTasks = [
        {
          ...createMockTask(),
          assignee: null,
        },
      ];
      (prisma.task.findMany as jest.Mock).mockResolvedValue(mockTasks);

      // Act
      const result = await getTeamActiveTasks('org-123', Role.GUEST);

      // Assert
      expect(result[0].assignee).toBeNull();
    });
  });

  describe('getMyCompletedTasks', () => {
    it('should return completed tasks for a user', async () => {
      // Arrange
      const mockTasks = [
        createMockTask({ status: 'DONE', completedAt: new Date() }),
      ];
      (prisma.task.findMany as jest.Mock).mockResolvedValue(mockTasks);

      // Act
      const result = await getMyCompletedTasks('user-123', 'org-123');

      // Assert
      expect(prisma.task.findMany).toHaveBeenCalledWith({
        where: {
          organizationId: 'org-123',
          assigneeId: 'user-123',
          status: 'DONE',
        },
        select: expect.any(Object),
        orderBy: { completedAt: 'desc' },
      });
      expect(result).toEqual(mockTasks);
    });
  });

  describe('updateTaskStatus', () => {
    const mockTask = createMockTask({ status: 'TODO', assigneeId: 'user-123' });

    it('should update task status for task owner', async () => {
      // Arrange
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(mockTask);
      (prisma.task.update as jest.Mock).mockResolvedValue({ ...mockTask, status: 'IN_PROGRESS' });

      // Act
      const result = await updateTaskStatus('task-123', 'IN_PROGRESS', 'user-123', 'org-123', Role.MEMBER);

      // Assert
      expect(prisma.task.update).toHaveBeenCalledWith({
        where: { id: 'task-123' },
        data: { status: 'IN_PROGRESS' },
        select: expect.any(Object),
      });
    });

    it('should update task status for admin even if not owner', async () => {
      // Arrange
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(mockTask);
      (prisma.task.update as jest.Mock).mockResolvedValue({ ...mockTask, status: 'DONE' });

      // Act
      await updateTaskStatus('task-123', 'DONE', 'admin-123', 'org-123', Role.ADMIN);

      // Assert
      expect(prisma.task.update).toHaveBeenCalled();
    });

    it('should update task status for team manager even if not owner', async () => {
      // Arrange
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(mockTask);
      (prisma.task.update as jest.Mock).mockResolvedValue({ ...mockTask, status: 'DONE' });

      // Act
      await updateTaskStatus('task-123', 'DONE', 'manager-123', 'org-123', Role.TEAM_MANAGER);

      // Assert
      expect(prisma.task.update).toHaveBeenCalled();
    });

    it('should throw ForbiddenError if non-admin/manager tries to update others task', async () => {
      // Arrange
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(mockTask);

      // Act & Assert
      await expect(
        updateTaskStatus('task-123', 'DONE', 'other-user', 'org-123', Role.MEMBER)
      ).rejects.toThrow(ForbiddenError);
      await expect(
        updateTaskStatus('task-123', 'DONE', 'other-user', 'org-123', Role.MEMBER)
      ).rejects.toThrow('You can only update your own tasks');
    });

    it('should throw NotFoundError if task does not exist', async () => {
      // Arrange
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(null);

      // Act & Assert
      await expect(
        updateTaskStatus('nonexistent', 'DONE', 'user-123', 'org-123', Role.MEMBER)
      ).rejects.toThrow(NotFoundError);
    });

    it('should set completedAt when status changes to DONE', async () => {
      // Arrange
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(mockTask);
      (prisma.task.update as jest.Mock).mockResolvedValue({ ...mockTask, status: 'DONE' });

      // Act
      await updateTaskStatus('task-123', 'DONE', 'user-123', 'org-123', Role.MEMBER);

      // Assert
      expect(prisma.task.update).toHaveBeenCalledWith({
        where: { id: 'task-123' },
        data: {
          status: 'DONE',
          completedAt: expect.any(Date),
        },
        select: expect.any(Object),
      });
    });

    it('should clear completedAt when status changes from DONE', async () => {
      // Arrange
      const completedTask = createMockTask({ status: 'DONE', completedAt: new Date() });
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(completedTask);
      (prisma.task.update as jest.Mock).mockResolvedValue({ ...completedTask, status: 'TODO' });

      // Act
      await updateTaskStatus('task-123', 'TODO', 'user-123', 'org-123', Role.MEMBER);

      // Assert
      expect(prisma.task.update).toHaveBeenCalledWith({
        where: { id: 'task-123' },
        data: {
          status: 'TODO',
          completedAt: null,
        },
        select: expect.any(Object),
      });
    });
  });

  describe('createTask', () => {
    it('should create a task successfully', async () => {
      // Arrange
      const input = {
        title: 'New Task',
        note: 'Task note',
        status: 'TODO' as any,
        priority: 'HIGH' as any,
      };
      const createdTask = createMockTask(input);
      (prisma.task.create as jest.Mock).mockResolvedValue(createdTask);

      // Act
      const result = await createTask('org-123', input);

      // Assert
      expect(prisma.task.create).toHaveBeenCalledWith({
        data: {
          organizationId: 'org-123',
          topicId: undefined,
          title: input.title,
          note: input.note,
          assigneeId: undefined,
          status: input.status,
          priority: input.priority,
          dueDate: undefined,
        },
        select: expect.any(Object),
      });
      expect(result).toEqual(createdTask);
    });

    it('should validate topic exists and is active', async () => {
      // Arrange
      const mockTopic = createMockTopic();
      (prisma.topic.findFirst as jest.Mock).mockResolvedValue(mockTopic);
      (prisma.task.create as jest.Mock).mockResolvedValue(createMockTask());

      const input = {
        topicId: 'topic-123',
        title: 'Task with topic',
      };

      // Act
      await createTask('org-123', input);

      // Assert
      expect(prisma.topic.findFirst).toHaveBeenCalledWith({
        where: {
          id: 'topic-123',
          organizationId: 'org-123',
        },
      });
    });

    it('should throw ValidationError if topic not found', async () => {
      // Arrange
      (prisma.topic.findFirst as jest.Mock).mockResolvedValue(null);

      const input = {
        topicId: 'nonexistent',
        title: 'Task',
      };

      // Act & Assert
      await expect(createTask('org-123', input)).rejects.toThrow(ValidationError);
      await expect(createTask('org-123', input)).rejects.toThrow('Topic not found');
    });

    it('should throw ValidationError if topic is inactive', async () => {
      // Arrange
      const inactiveTopic = createMockTopic({ isActive: false });
      (prisma.topic.findFirst as jest.Mock).mockResolvedValue(inactiveTopic);

      const input = {
        topicId: 'topic-123',
        title: 'Task',
      };

      // Act & Assert
      await expect(createTask('org-123', input)).rejects.toThrow(ValidationError);
      await expect(createTask('org-123', input)).rejects.toThrow('Cannot create task for inactive topic');
    });

    it('should validate assignee belongs to organization', async () => {
      // Arrange
      const mockUser = createMockUser();
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(mockUser);
      (prisma.task.create as jest.Mock).mockResolvedValue(createMockTask());

      const input = {
        title: 'Task',
        assigneeId: 'user-123',
      };

      // Act
      await createTask('org-123', input);

      // Assert
      expect(prisma.user.findFirst).toHaveBeenCalledWith({
        where: {
          id: 'user-123',
          organizationId: 'org-123',
        },
      });
    });

    it('should throw ValidationError if assignee not in organization', async () => {
      // Arrange
      (prisma.user.findFirst as jest.Mock).mockResolvedValue(null);

      const input = {
        title: 'Task',
        assigneeId: 'external-user',
      };

      // Act & Assert
      await expect(createTask('org-123', input)).rejects.toThrow(ValidationError);
      await expect(createTask('org-123', input)).rejects.toThrow('Assignee not found in your organization');
    });

    it('should use default values for status and priority', async () => {
      // Arrange
      (prisma.task.create as jest.Mock).mockResolvedValue(createMockTask());

      const input = {
        title: 'Task with defaults',
      };

      // Act
      await createTask('org-123', input);

      // Assert
      expect(prisma.task.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          status: 'TODO',
          priority: 'NORMAL',
        }),
        select: expect.any(Object),
      });
    });
  });

  describe('createMemberTask', () => {
    it('should create a task for member with assigned user', async () => {
      // Arrange
      const mockTopic = createMockTopic();
      (prisma.topic.findFirst as jest.Mock).mockResolvedValue(mockTopic);
      (prisma.task.create as jest.Mock).mockResolvedValue(createMockTask());

      const input = {
        topicId: 'topic-123',
        title: 'Member Task',
        assigneeId: 'user-123',
      };

      // Act
      await createMemberTask('org-123', input);

      // Assert
      expect(prisma.task.create).toHaveBeenCalledWith({
        data: {
          organizationId: 'org-123',
          topicId: 'topic-123',
          title: 'Member Task',
          note: undefined,
          assigneeId: 'user-123',
          status: 'TODO',
          priority: 'NORMAL',
          dueDate: undefined,
        },
        select: expect.any(Object),
      });
    });

    it('should validate topic is active', async () => {
      // Arrange
      const inactiveTopic = createMockTopic({ isActive: false });
      (prisma.topic.findFirst as jest.Mock).mockResolvedValue(inactiveTopic);

      const input = {
        topicId: 'topic-123',
        title: 'Task',
        assigneeId: 'user-123',
      };

      // Act & Assert
      await expect(createMemberTask('org-123', input)).rejects.toThrow(ValidationError);
      await expect(createMemberTask('org-123', input)).rejects.toThrow('Cannot create task for inactive topic');
    });
  });

  describe('updateTask', () => {
    const mockTask = createMockTask({ status: 'TODO' });

    it('should update task successfully', async () => {
      // Arrange
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(mockTask);
      (prisma.task.update as jest.Mock).mockResolvedValue({ ...mockTask, title: 'Updated Title' });

      const input = {
        title: 'Updated Title',
        note: 'Updated note',
      };

      // Act
      const result = await updateTask('task-123', 'org-123', input);

      // Assert
      expect(prisma.task.update).toHaveBeenCalledWith({
        where: { id: 'task-123' },
        data: {
          title: 'Updated Title',
          note: 'Updated note',
        },
        select: expect.any(Object),
      });
    });

    it('should throw NotFoundError if task does not exist', async () => {
      // Arrange
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(null);

      // Act & Assert
      await expect(updateTask('nonexistent', 'org-123', { title: 'Test' })).rejects.toThrow(NotFoundError);
    });

    it('should handle status change to DONE with completedAt', async () => {
      // Arrange
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(mockTask);
      (prisma.task.update as jest.Mock).mockResolvedValue({ ...mockTask, status: 'DONE' });

      // Act
      await updateTask('task-123', 'org-123', { status: 'DONE' as any });

      // Assert
      expect(prisma.task.update).toHaveBeenCalledWith({
        where: { id: 'task-123' },
        data: {
          status: 'DONE',
          completedAt: expect.any(Date),
        },
        select: expect.any(Object),
      });
    });

    it('should clear completedAt when status changes from DONE', async () => {
      // Arrange
      const completedTask = createMockTask({ status: 'DONE', completedAt: new Date() });
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(completedTask);
      (prisma.task.update as jest.Mock).mockResolvedValue({ ...completedTask, status: 'TODO' });

      // Act
      await updateTask('task-123', 'org-123', { status: 'TODO' as any });

      // Assert
      expect(prisma.task.update).toHaveBeenCalledWith({
        where: { id: 'task-123' },
        data: {
          status: 'TODO',
          completedAt: null,
        },
        select: expect.any(Object),
      });
    });
  });

  describe('updateMemberTask', () => {
    it('should allow member to update own task', async () => {
      // Arrange
      const mockTask = createMockTask({ assigneeId: 'user-123' });
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(mockTask);
      (prisma.task.update as jest.Mock).mockResolvedValue(mockTask);

      // Act
      await updateMemberTask('task-123', 'org-123', { title: 'Updated' }, 'user-123');

      // Assert
      expect(prisma.task.update).toHaveBeenCalled();
    });

    it('should throw ForbiddenError if member tries to update others task', async () => {
      // Arrange
      const mockTask = createMockTask({ assigneeId: 'user-123' });
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(mockTask);

      // Act & Assert
      await expect(
        updateMemberTask('task-123', 'org-123', { title: 'Updated' }, 'other-user')
      ).rejects.toThrow(ForbiddenError);
      await expect(
        updateMemberTask('task-123', 'org-123', { title: 'Updated' }, 'other-user')
      ).rejects.toThrow('You can only update your own tasks');
    });

    it('should throw NotFoundError if task does not exist', async () => {
      // Arrange
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(null);

      // Act & Assert
      await expect(
        updateMemberTask('nonexistent', 'org-123', { title: 'Test' }, 'user-123')
      ).rejects.toThrow(NotFoundError);
    });
  });

  describe('deleteTask', () => {
    it('should delete task successfully', async () => {
      // Arrange
      const mockTask = createMockTask();
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(mockTask);
      (prisma.task.delete as jest.Mock).mockResolvedValue(mockTask);

      // Act
      const result = await deleteTask('task-123', 'org-123');

      // Assert
      expect(prisma.task.delete).toHaveBeenCalledWith({
        where: { id: 'task-123' },
      });
      expect(result).toEqual({ message: 'Task deleted successfully' });
    });

    it('should throw NotFoundError if task does not exist', async () => {
      // Arrange
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(null);

      // Act & Assert
      await expect(deleteTask('nonexistent', 'org-123')).rejects.toThrow(NotFoundError);
    });
  });

  describe('getAllTasks', () => {
    it('should return all tasks for organization', async () => {
      // Arrange
      const mockTasks = [
        createMockTask({ status: 'TODO' }),
        createMockTask({ status: 'DONE' }),
      ];
      (prisma.task.findMany as jest.Mock).mockResolvedValue(mockTasks);

      // Act
      const result = await getAllTasks('org-123');

      // Assert
      expect(prisma.task.findMany).toHaveBeenCalledWith({
        where: { organizationId: 'org-123' },
        select: expect.any(Object),
        orderBy: [{ status: 'asc' }, { priority: 'desc' }, { createdAt: 'desc' }],
      });
      expect(result).toEqual(mockTasks);
    });
  });

  describe('getTask', () => {
    it('should return a single task', async () => {
      // Arrange
      const mockTask = createMockTask();
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(mockTask);

      // Act
      const result = await getTask('task-123', 'org-123');

      // Assert
      expect(prisma.task.findFirst).toHaveBeenCalledWith({
        where: {
          id: 'task-123',
          organizationId: 'org-123',
        },
        select: expect.any(Object),
      });
      expect(result).toEqual(mockTask);
    });

    it('should throw NotFoundError if task does not exist', async () => {
      // Arrange
      (prisma.task.findFirst as jest.Mock).mockResolvedValue(null);

      // Act & Assert
      await expect(getTask('nonexistent', 'org-123')).rejects.toThrow(NotFoundError);
      await expect(getTask('nonexistent', 'org-123')).rejects.toThrow('Task not found');
    });
  });
});
