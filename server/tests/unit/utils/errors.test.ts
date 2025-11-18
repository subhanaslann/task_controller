import {
  AppError,
  UnauthorizedError,
  ForbiddenError,
  NotFoundError,
  ValidationError,
  ConflictError,
  OrganizationNotFoundError,
  OrganizationInactiveError,
  OrganizationUserLimitReachedError,
  CrossOrganizationAccessError,
} from '../../../src/utils/errors';

describe('Error Classes', () => {
  describe('AppError', () => {
    it('should create an AppError with correct properties', () => {
      // Act
      const error = new AppError('TEST_CODE', 'Test error message', 400);

      // Assert
      expect(error).toBeInstanceOf(Error);
      expect(error).toBeInstanceOf(AppError);
      expect(error.code).toBe('TEST_CODE');
      expect(error.message).toBe('Test error message');
      expect(error.statusCode).toBe(400);
      expect(error.name).toBe('AppError');
    });

    it('should default to status code 400', () => {
      // Act
      const error = new AppError('CODE', 'Message');

      // Assert
      expect(error.statusCode).toBe(400);
    });
  });

  describe('UnauthorizedError', () => {
    it('should create UnauthorizedError with custom message', () => {
      // Act
      const error = new UnauthorizedError('Invalid credentials');

      // Assert
      expect(error).toBeInstanceOf(AppError);
      expect(error.code).toBe('UNAUTHORIZED');
      expect(error.message).toBe('Invalid credentials');
      expect(error.statusCode).toBe(401);
      expect(error.name).toBe('UnauthorizedError');
    });

    it('should use default message when not provided', () => {
      // Act
      const error = new UnauthorizedError();

      // Assert
      expect(error.message).toBe('Unauthorized');
    });
  });

  describe('ForbiddenError', () => {
    it('should create ForbiddenError with custom message', () => {
      // Act
      const error = new ForbiddenError('Access denied');

      // Assert
      expect(error).toBeInstanceOf(AppError);
      expect(error.code).toBe('FORBIDDEN');
      expect(error.message).toBe('Access denied');
      expect(error.statusCode).toBe(403);
      expect(error.name).toBe('ForbiddenError');
    });

    it('should use default message when not provided', () => {
      // Act
      const error = new ForbiddenError();

      // Assert
      expect(error.message).toBe('Forbidden');
    });
  });

  describe('NotFoundError', () => {
    it('should create NotFoundError with custom message', () => {
      // Act
      const error = new NotFoundError('Resource not found');

      // Assert
      expect(error).toBeInstanceOf(AppError);
      expect(error.code).toBe('NOT_FOUND');
      expect(error.message).toBe('Resource not found');
      expect(error.statusCode).toBe(404);
      expect(error.name).toBe('NotFoundError');
    });

    it('should use default message when not provided', () => {
      // Act
      const error = new NotFoundError();

      // Assert
      expect(error.message).toBe('Not found');
    });
  });

  describe('ValidationError', () => {
    it('should create ValidationError with custom message', () => {
      // Act
      const error = new ValidationError('Invalid input');

      // Assert
      expect(error).toBeInstanceOf(AppError);
      expect(error.code).toBe('VALIDATION_ERROR');
      expect(error.message).toBe('Invalid input');
      expect(error.statusCode).toBe(400);
      expect(error.name).toBe('ValidationError');
    });

    it('should use default message when not provided', () => {
      // Act
      const error = new ValidationError();

      // Assert
      expect(error.message).toBe('Validation failed');
    });
  });

  describe('ConflictError', () => {
    it('should create ConflictError with custom message', () => {
      // Act
      const error = new ConflictError('Email already exists');

      // Assert
      expect(error).toBeInstanceOf(AppError);
      expect(error.code).toBe('CONFLICT');
      expect(error.message).toBe('Email already exists');
      expect(error.statusCode).toBe(400);
      expect(error.name).toBe('ConflictError');
    });

    it('should use default message when not provided', () => {
      // Act
      const error = new ConflictError();

      // Assert
      expect(error.message).toBe('Resource conflict');
    });
  });

  describe('OrganizationNotFoundError', () => {
    it('should create OrganizationNotFoundError with custom message', () => {
      // Act
      const error = new OrganizationNotFoundError('Org does not exist');

      // Assert
      expect(error).toBeInstanceOf(AppError);
      expect(error.code).toBe('ORGANIZATION_NOT_FOUND');
      expect(error.message).toBe('Org does not exist');
      expect(error.statusCode).toBe(404);
      expect(error.name).toBe('OrganizationNotFoundError');
    });

    it('should use default message when not provided', () => {
      // Act
      const error = new OrganizationNotFoundError();

      // Assert
      expect(error.message).toBe('Organization not found');
    });
  });

  describe('OrganizationInactiveError', () => {
    it('should create OrganizationInactiveError with custom message', () => {
      // Act
      const error = new OrganizationInactiveError('Org is disabled');

      // Assert
      expect(error).toBeInstanceOf(AppError);
      expect(error.code).toBe('ORGANIZATION_INACTIVE');
      expect(error.message).toBe('Org is disabled');
      expect(error.statusCode).toBe(403);
      expect(error.name).toBe('OrganizationInactiveError');
    });

    it('should use default message when not provided', () => {
      // Act
      const error = new OrganizationInactiveError();

      // Assert
      expect(error.message).toBe('Organization is inactive');
    });
  });

  describe('OrganizationUserLimitReachedError', () => {
    it('should create error with custom max users', () => {
      // Act
      const error = new OrganizationUserLimitReachedError(20);

      // Assert
      expect(error).toBeInstanceOf(AppError);
      expect(error.code).toBe('ORGANIZATION_USER_LIMIT_REACHED');
      expect(error.message).toBe('Your organization has reached the maximum of 20 users');
      expect(error.statusCode).toBe(400);
      expect(error.name).toBe('OrganizationUserLimitReachedError');
    });

    it('should use default max users value', () => {
      // Act
      const error = new OrganizationUserLimitReachedError();

      // Assert
      expect(error.message).toBe('Your organization has reached the maximum of 15 users');
    });

    it('should handle different user limits correctly', () => {
      // Test various limits
      const limits = [5, 10, 15, 25, 50, 100];

      limits.forEach((limit) => {
        const error = new OrganizationUserLimitReachedError(limit);
        expect(error.message).toBe(`Your organization has reached the maximum of ${limit} users`);
      });
    });
  });

  describe('CrossOrganizationAccessError', () => {
    it('should create CrossOrganizationAccessError with custom message', () => {
      // Act
      const error = new CrossOrganizationAccessError('Cannot access other org resources');

      // Assert
      expect(error).toBeInstanceOf(AppError);
      expect(error.code).toBe('CROSS_ORGANIZATION_ACCESS');
      expect(error.message).toBe('Cannot access other org resources');
      expect(error.statusCode).toBe(404);
      expect(error.name).toBe('CrossOrganizationAccessError');
    });

    it('should use default message when not provided', () => {
      // Act
      const error = new CrossOrganizationAccessError();

      // Assert
      expect(error.message).toBe('You do not have access to resources from another organization');
    });
  });

  describe('Error inheritance', () => {
    it('should all be instances of Error', () => {
      const errors = [
        new AppError('CODE', 'Message'),
        new UnauthorizedError(),
        new ForbiddenError(),
        new NotFoundError(),
        new ValidationError(),
        new ConflictError(),
        new OrganizationNotFoundError(),
        new OrganizationInactiveError(),
        new OrganizationUserLimitReachedError(),
        new CrossOrganizationAccessError(),
      ];

      errors.forEach((error) => {
        expect(error).toBeInstanceOf(Error);
        expect(error).toBeInstanceOf(AppError);
      });
    });

    it('should have stack traces', () => {
      const error = new UnauthorizedError('Test');
      expect(error.stack).toBeDefined();
      expect(error.stack).toContain('UnauthorizedError');
    });
  });

  describe('Error throwing and catching', () => {
    it('should be catchable as specific error type', () => {
      try {
        throw new NotFoundError('User not found');
      } catch (error) {
        expect(error).toBeInstanceOf(NotFoundError);
        expect(error).toBeInstanceOf(AppError);
        expect((error as NotFoundError).message).toBe('User not found');
      }
    });

    it('should be catchable as AppError', () => {
      try {
        throw new ValidationError('Invalid data');
      } catch (error) {
        if (error instanceof AppError) {
          expect(error.code).toBe('VALIDATION_ERROR');
          expect(error.statusCode).toBe(400);
        } else {
          fail('Error should be instance of AppError');
        }
      }
    });

    it('should be catchable as generic Error', () => {
      try {
        throw new ForbiddenError('Access denied');
      } catch (error) {
        expect(error).toBeInstanceOf(Error);
        expect((error as Error).message).toBe('Access denied');
      }
    });
  });

  describe('Error status codes', () => {
    it('should have correct status codes', () => {
      const errorStatusMap = [
        { error: new UnauthorizedError(), expectedStatus: 401 },
        { error: new ForbiddenError(), expectedStatus: 403 },
        { error: new NotFoundError(), expectedStatus: 404 },
        { error: new ValidationError(), expectedStatus: 400 },
        { error: new ConflictError(), expectedStatus: 400 },
        { error: new OrganizationNotFoundError(), expectedStatus: 404 },
        { error: new OrganizationInactiveError(), expectedStatus: 403 },
        { error: new OrganizationUserLimitReachedError(), expectedStatus: 400 },
        { error: new CrossOrganizationAccessError(), expectedStatus: 404 },
      ];

      errorStatusMap.forEach(({ error, expectedStatus }) => {
        expect(error.statusCode).toBe(expectedStatus);
      });
    });
  });
});
