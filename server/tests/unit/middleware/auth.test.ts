import { authenticate, ensureOrganizationAccess } from '../../../src/middleware/auth';
import { verifyToken } from '../../../src/utils/jwt';
import {
  UnauthorizedError,
  OrganizationInactiveError,
  OrganizationNotFoundError,
  CrossOrganizationAccessError,
} from '../../../src/utils/errors';
import prisma from '../../../src/db/connection';
import { Role } from '../../../src/types';
import {
  createMockRequest,
  createMockResponse,
  createMockNext,
  createMockJwtPayload,
  createMockOrganization,
} from '../utils/testUtils';

// Mock dependencies
jest.mock('../../../src/utils/jwt');
jest.mock('../../../src/db/connection', () => ({
  __esModule: true,
  default: {
    organization: {
      findUnique: jest.fn(),
    },
    task: {
      findUnique: jest.fn(),
    },
    topic: {
      findUnique: jest.fn(),
    },
    user: {
      findUnique: jest.fn(),
    },
  },
}));

describe('Auth Middleware', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('authenticate', () => {
    it('should authenticate valid token successfully', async () => {
      // Arrange
      const mockPayload = createMockJwtPayload();
      const mockOrganization = createMockOrganization({ isActive: true });
      const req = createMockRequest({
        headers: { authorization: 'Bearer valid-token' },
      });
      const res = createMockResponse();
      const next = createMockNext();

      (verifyToken as jest.Mock).mockReturnValue(mockPayload);
      (prisma.organization.findUnique as jest.Mock).mockResolvedValue(mockOrganization);

      // Act
      await authenticate(req, res, next);

      // Assert
      expect(verifyToken).toHaveBeenCalledWith('valid-token');
      expect(prisma.organization.findUnique).toHaveBeenCalledWith({
        where: { id: mockPayload.organizationId },
      });
      expect(req.user).toEqual({
        id: mockPayload.userId,
        organizationId: mockPayload.organizationId,
        role: mockPayload.role,
        email: mockPayload.email,
      });
      expect(next).toHaveBeenCalledWith();
    });

    it('should throw UnauthorizedError when no token provided', async () => {
      // Arrange
      const req = createMockRequest({ headers: {} });
      const res = createMockResponse();
      const next = createMockNext();

      // Act
      await authenticate(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(expect.any(UnauthorizedError));
      expect(next.mock.calls[0][0].message).toBe('No token provided');
    });

    it('should throw UnauthorizedError when token does not start with Bearer', async () => {
      // Arrange
      const req = createMockRequest({
        headers: { authorization: 'InvalidFormat token' },
      });
      const res = createMockResponse();
      const next = createMockNext();

      // Act
      await authenticate(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(expect.any(UnauthorizedError));
      expect(next.mock.calls[0][0].message).toBe('No token provided');
    });

    it('should throw OrganizationNotFoundError when organization does not exist', async () => {
      // Arrange
      const mockPayload = createMockJwtPayload();
      const req = createMockRequest({
        headers: { authorization: 'Bearer valid-token' },
      });
      const res = createMockResponse();
      const next = createMockNext();

      (verifyToken as jest.Mock).mockReturnValue(mockPayload);
      (prisma.organization.findUnique as jest.Mock).mockResolvedValue(null);

      // Act
      await authenticate(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(expect.any(OrganizationNotFoundError));
    });

    it('should throw OrganizationInactiveError when organization is inactive', async () => {
      // Arrange
      const mockPayload = createMockJwtPayload();
      const mockOrganization = createMockOrganization({ isActive: false });
      const req = createMockRequest({
        headers: { authorization: 'Bearer valid-token' },
      });
      const res = createMockResponse();
      const next = createMockNext();

      (verifyToken as jest.Mock).mockReturnValue(mockPayload);
      (prisma.organization.findUnique as jest.Mock).mockResolvedValue(mockOrganization);

      // Act
      await authenticate(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(expect.any(OrganizationInactiveError));
    });

    it('should throw UnauthorizedError when token is invalid', async () => {
      // Arrange
      const req = createMockRequest({
        headers: { authorization: 'Bearer invalid-token' },
      });
      const res = createMockResponse();
      const next = createMockNext();

      (verifyToken as jest.Mock).mockImplementation(() => {
        throw new Error('Invalid token');
      });

      // Act
      await authenticate(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(expect.any(UnauthorizedError));
      expect(next.mock.calls[0][0].message).toBe('Invalid token');
    });
  });

  describe('ensureOrganizationAccess', () => {
    describe('task resource', () => {
      it('should allow access to task in same organization', async () => {
        // Arrange
        const middleware = ensureOrganizationAccess('task');
        const req = createMockRequest({
          user: {
            id: 'user-123',
            organizationId: 'org-123',
            role: Role.MEMBER,
            email: 'test@example.com',
          },
          params: { id: 'task-123' },
        });
        const res = createMockResponse();
        const next = createMockNext();

        (prisma.task.findUnique as jest.Mock).mockResolvedValue({
          id: 'task-123',
          organizationId: 'org-123',
        });

        // Act
        await middleware(req, res, next);

        // Assert
        expect(prisma.task.findUnique).toHaveBeenCalledWith({
          where: { id: 'task-123' },
          select: { organizationId: true },
        });
        expect(next).toHaveBeenCalledWith();
      });

      it('should throw CrossOrganizationAccessError for task in different organization', async () => {
        // Arrange
        const middleware = ensureOrganizationAccess('task');
        const req = createMockRequest({
          user: {
            id: 'user-123',
            organizationId: 'org-123',
            role: Role.MEMBER,
            email: 'test@example.com',
          },
          params: { id: 'task-123' },
        });
        const res = createMockResponse();
        const next = createMockNext();

        (prisma.task.findUnique as jest.Mock).mockResolvedValue({
          id: 'task-123',
          organizationId: 'org-456', // Different organization
        });

        // Act
        await middleware(req, res, next);

        // Assert
        expect(next).toHaveBeenCalledWith(expect.any(CrossOrganizationAccessError));
      });

      it('should allow ADMIN to access resources from any organization', async () => {
        // Arrange
        const middleware = ensureOrganizationAccess('task');
        const req = createMockRequest({
          user: {
            id: 'admin-123',
            organizationId: 'org-123',
            role: Role.ADMIN,
            email: 'admin@example.com',
          },
          params: { id: 'task-123' },
        });
        const res = createMockResponse();
        const next = createMockNext();

        // Act
        await middleware(req, res, next);

        // Assert
        expect(prisma.task.findUnique).not.toHaveBeenCalled();
        expect(next).toHaveBeenCalledWith();
      });

      it('should continue when resource not found (let route handler deal with 404)', async () => {
        // Arrange
        const middleware = ensureOrganizationAccess('task');
        const req = createMockRequest({
          user: {
            id: 'user-123',
            organizationId: 'org-123',
            role: Role.MEMBER,
            email: 'test@example.com',
          },
          params: { id: 'nonexistent' },
        });
        const res = createMockResponse();
        const next = createMockNext();

        (prisma.task.findUnique as jest.Mock).mockResolvedValue(null);

        // Act
        await middleware(req, res, next);

        // Assert
        expect(next).toHaveBeenCalledWith();
      });

      it('should continue when no resource id in params', async () => {
        // Arrange
        const middleware = ensureOrganizationAccess('task');
        const req = createMockRequest({
          user: {
            id: 'user-123',
            organizationId: 'org-123',
            role: Role.MEMBER,
            email: 'test@example.com',
          },
          params: {},
        });
        const res = createMockResponse();
        const next = createMockNext();

        // Act
        await middleware(req, res, next);

        // Assert
        expect(prisma.task.findUnique).not.toHaveBeenCalled();
        expect(next).toHaveBeenCalledWith();
      });

      it('should throw UnauthorizedError when user not authenticated', async () => {
        // Arrange
        const middleware = ensureOrganizationAccess('task');
        const req = createMockRequest({ params: { id: 'task-123' } });
        const res = createMockResponse();
        const next = createMockNext();

        // Act
        await middleware(req, res, next);

        // Assert
        expect(next).toHaveBeenCalledWith(expect.any(UnauthorizedError));
        expect(next.mock.calls[0][0].message).toBe('User not authenticated');
      });
    });

    describe('topic resource', () => {
      it('should allow access to topic in same organization', async () => {
        // Arrange
        const middleware = ensureOrganizationAccess('topic');
        const req = createMockRequest({
          user: {
            id: 'user-123',
            organizationId: 'org-123',
            role: Role.MEMBER,
            email: 'test@example.com',
          },
          params: { id: 'topic-123' },
        });
        const res = createMockResponse();
        const next = createMockNext();

        (prisma.topic.findUnique as jest.Mock).mockResolvedValue({
          id: 'topic-123',
          organizationId: 'org-123',
        });

        // Act
        await middleware(req, res, next);

        // Assert
        expect(prisma.topic.findUnique).toHaveBeenCalledWith({
          where: { id: 'topic-123' },
          select: { organizationId: true },
        });
        expect(next).toHaveBeenCalledWith();
      });

      it('should throw CrossOrganizationAccessError for topic in different organization', async () => {
        // Arrange
        const middleware = ensureOrganizationAccess('topic');
        const req = createMockRequest({
          user: {
            id: 'user-123',
            organizationId: 'org-123',
            role: Role.MEMBER,
            email: 'test@example.com',
          },
          params: { id: 'topic-123' },
        });
        const res = createMockResponse();
        const next = createMockNext();

        (prisma.topic.findUnique as jest.Mock).mockResolvedValue({
          id: 'topic-123',
          organizationId: 'org-456',
        });

        // Act
        await middleware(req, res, next);

        // Assert
        expect(next).toHaveBeenCalledWith(expect.any(CrossOrganizationAccessError));
      });
    });

    describe('user resource', () => {
      it('should allow access to user in same organization', async () => {
        // Arrange
        const middleware = ensureOrganizationAccess('user');
        const req = createMockRequest({
          user: {
            id: 'user-123',
            organizationId: 'org-123',
            role: Role.TEAM_MANAGER,
            email: 'manager@example.com',
          },
          params: { id: 'user-456' },
        });
        const res = createMockResponse();
        const next = createMockNext();

        (prisma.user.findUnique as jest.Mock).mockResolvedValue({
          id: 'user-456',
          organizationId: 'org-123',
        });

        // Act
        await middleware(req, res, next);

        // Assert
        expect(prisma.user.findUnique).toHaveBeenCalledWith({
          where: { id: 'user-456' },
          select: { organizationId: true },
        });
        expect(next).toHaveBeenCalledWith();
      });

      it('should throw CrossOrganizationAccessError for user in different organization', async () => {
        // Arrange
        const middleware = ensureOrganizationAccess('user');
        const req = createMockRequest({
          user: {
            id: 'user-123',
            organizationId: 'org-123',
            role: Role.TEAM_MANAGER,
            email: 'manager@example.com',
          },
          params: { id: 'user-456' },
        });
        const res = createMockResponse();
        const next = createMockNext();

        (prisma.user.findUnique as jest.Mock).mockResolvedValue({
          id: 'user-456',
          organizationId: 'org-456',
        });

        // Act
        await middleware(req, res, next);

        // Assert
        expect(next).toHaveBeenCalledWith(expect.any(CrossOrganizationAccessError));
      });
    });
  });
});
