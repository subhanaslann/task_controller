import {
  requireAdmin,
  requireTeamManagerOrAdmin,
  requireRole,
  isTeamManagerOrAdmin,
  isAdmin,
} from '../../../src/middleware/roles';
import { ForbiddenError } from '../../../src/utils/errors';
import { Role } from '../../../src/types';
import { createMockRequest, createMockResponse, createMockNext } from '../utils/testUtils';

describe('Roles Middleware', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('requireAdmin', () => {
    it('should allow ADMIN role to proceed', () => {
      // Arrange
      const req = createMockRequest({
        user: {
          id: 'admin-123',
          organizationId: 'org-123',
          role: Role.ADMIN,
          email: 'admin@example.com',
        },
      });
      const res = createMockResponse();
      const next = createMockNext();

      // Act
      requireAdmin(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith();
    });

    it('should deny TEAM_MANAGER role', () => {
      // Arrange
      const req = createMockRequest({
        user: {
          id: 'manager-123',
          organizationId: 'org-123',
          role: Role.TEAM_MANAGER,
          email: 'manager@example.com',
        },
      });
      const res = createMockResponse();
      const next = createMockNext();

      // Act
      requireAdmin(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(expect.any(ForbiddenError));
      expect(next.mock.calls[0][0].message).toBe('Admin access required');
    });

    it('should deny MEMBER role', () => {
      // Arrange
      const req = createMockRequest({
        user: {
          id: 'member-123',
          organizationId: 'org-123',
          role: Role.MEMBER,
          email: 'member@example.com',
        },
      });
      const res = createMockResponse();
      const next = createMockNext();

      // Act
      requireAdmin(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(expect.any(ForbiddenError));
    });

    it('should deny GUEST role', () => {
      // Arrange
      const req = createMockRequest({
        user: {
          id: 'guest-123',
          organizationId: 'org-123',
          role: Role.GUEST,
          email: 'guest@example.com',
        },
      });
      const res = createMockResponse();
      const next = createMockNext();

      // Act
      requireAdmin(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(expect.any(ForbiddenError));
    });

    it('should deny when user is not set', () => {
      // Arrange
      const req = createMockRequest({});
      const res = createMockResponse();
      const next = createMockNext();

      // Act
      requireAdmin(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(expect.any(ForbiddenError));
    });
  });

  describe('requireTeamManagerOrAdmin', () => {
    it('should allow ADMIN role to proceed', () => {
      // Arrange
      const req = createMockRequest({
        user: {
          id: 'admin-123',
          organizationId: 'org-123',
          role: Role.ADMIN,
          email: 'admin@example.com',
        },
      });
      const res = createMockResponse();
      const next = createMockNext();

      // Act
      requireTeamManagerOrAdmin(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith();
    });

    it('should allow TEAM_MANAGER role to proceed', () => {
      // Arrange
      const req = createMockRequest({
        user: {
          id: 'manager-123',
          organizationId: 'org-123',
          role: Role.TEAM_MANAGER,
          email: 'manager@example.com',
        },
      });
      const res = createMockResponse();
      const next = createMockNext();

      // Act
      requireTeamManagerOrAdmin(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith();
    });

    it('should deny MEMBER role', () => {
      // Arrange
      const req = createMockRequest({
        user: {
          id: 'member-123',
          organizationId: 'org-123',
          role: Role.MEMBER,
          email: 'member@example.com',
        },
      });
      const res = createMockResponse();
      const next = createMockNext();

      // Act
      requireTeamManagerOrAdmin(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(expect.any(ForbiddenError));
      expect(next.mock.calls[0][0].message).toBe(
        'Access forbidden: Team Manager or Admin role required'
      );
    });

    it('should deny GUEST role', () => {
      // Arrange
      const req = createMockRequest({
        user: {
          id: 'guest-123',
          organizationId: 'org-123',
          role: Role.GUEST,
          email: 'guest@example.com',
        },
      });
      const res = createMockResponse();
      const next = createMockNext();

      // Act
      requireTeamManagerOrAdmin(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(expect.any(ForbiddenError));
    });
  });

  describe('requireRole', () => {
    it('should allow user with matching role', () => {
      // Arrange
      const middleware = requireRole(Role.MEMBER, Role.TEAM_MANAGER);
      const req = createMockRequest({
        user: {
          id: 'member-123',
          organizationId: 'org-123',
          role: Role.MEMBER,
          email: 'member@example.com',
        },
      });
      const res = createMockResponse();
      const next = createMockNext();

      // Act
      middleware(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith();
    });

    it('should allow user with any of the specified roles', () => {
      // Arrange
      const middleware = requireRole(Role.MEMBER, Role.TEAM_MANAGER, Role.ADMIN);
      const req = createMockRequest({
        user: {
          id: 'manager-123',
          organizationId: 'org-123',
          role: Role.TEAM_MANAGER,
          email: 'manager@example.com',
        },
      });
      const res = createMockResponse();
      const next = createMockNext();

      // Act
      middleware(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith();
    });

    it('should deny user without matching role', () => {
      // Arrange
      const middleware = requireRole(Role.ADMIN, Role.TEAM_MANAGER);
      const req = createMockRequest({
        user: {
          id: 'member-123',
          organizationId: 'org-123',
          role: Role.MEMBER,
          email: 'member@example.com',
        },
      });
      const res = createMockResponse();
      const next = createMockNext();

      // Act
      middleware(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(expect.any(ForbiddenError));
      expect(next.mock.calls[0][0].message).toBe('Insufficient permissions');
    });

    it('should deny when user is not set', () => {
      // Arrange
      const middleware = requireRole(Role.MEMBER);
      const req = createMockRequest({});
      const res = createMockResponse();
      const next = createMockNext();

      // Act
      middleware(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(expect.any(ForbiddenError));
    });

    it('should work with single role', () => {
      // Arrange
      const middleware = requireRole(Role.GUEST);
      const req = createMockRequest({
        user: {
          id: 'guest-123',
          organizationId: 'org-123',
          role: Role.GUEST,
          email: 'guest@example.com',
        },
      });
      const res = createMockResponse();
      const next = createMockNext();

      // Act
      middleware(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith();
    });
  });

  describe('isTeamManagerOrAdmin', () => {
    it('should return true for ADMIN role', () => {
      // Arrange
      const user = {
        id: 'admin-123',
        organizationId: 'org-123',
        role: Role.ADMIN,
        email: 'admin@example.com',
      };

      // Act
      const result = isTeamManagerOrAdmin(user);

      // Assert
      expect(result).toBe(true);
    });

    it('should return true for TEAM_MANAGER role', () => {
      // Arrange
      const user = {
        id: 'manager-123',
        organizationId: 'org-123',
        role: Role.TEAM_MANAGER,
        email: 'manager@example.com',
      };

      // Act
      const result = isTeamManagerOrAdmin(user);

      // Assert
      expect(result).toBe(true);
    });

    it('should return false for MEMBER role', () => {
      // Arrange
      const user = {
        id: 'member-123',
        organizationId: 'org-123',
        role: Role.MEMBER,
        email: 'member@example.com',
      };

      // Act
      const result = isTeamManagerOrAdmin(user);

      // Assert
      expect(result).toBe(false);
    });

    it('should return false for GUEST role', () => {
      // Arrange
      const user = {
        id: 'guest-123',
        organizationId: 'org-123',
        role: Role.GUEST,
        email: 'guest@example.com',
      };

      // Act
      const result = isTeamManagerOrAdmin(user);

      // Assert
      expect(result).toBe(false);
    });
  });

  describe('isAdmin', () => {
    it('should return true for ADMIN role', () => {
      // Arrange
      const user = {
        id: 'admin-123',
        organizationId: 'org-123',
        role: Role.ADMIN,
        email: 'admin@example.com',
      };

      // Act
      const result = isAdmin(user);

      // Assert
      expect(result).toBe(true);
    });

    it('should return false for TEAM_MANAGER role', () => {
      // Arrange
      const user = {
        id: 'manager-123',
        organizationId: 'org-123',
        role: Role.TEAM_MANAGER,
        email: 'manager@example.com',
      };

      // Act
      const result = isAdmin(user);

      // Assert
      expect(result).toBe(false);
    });

    it('should return false for MEMBER role', () => {
      // Arrange
      const user = {
        id: 'member-123',
        organizationId: 'org-123',
        role: Role.MEMBER,
        email: 'member@example.com',
      };

      // Act
      const result = isAdmin(user);

      // Assert
      expect(result).toBe(false);
    });

    it('should return false for GUEST role', () => {
      // Arrange
      const user = {
        id: 'guest-123',
        organizationId: 'org-123',
        role: Role.GUEST,
        email: 'guest@example.com',
      };

      // Act
      const result = isAdmin(user);

      // Assert
      expect(result).toBe(false);
    });
  });
});
