import { errorHandler } from '../../../src/middleware/errorHandler';
import { AppError, UnauthorizedError, NotFoundError, ValidationError } from '../../../src/utils/errors';
import { ZodError } from 'zod';
import logger from '../../../src/utils/logger';
import { createMockRequest, createMockResponse, createMockNext } from '../utils/testUtils';

// Mock logger
jest.mock('../../../src/utils/logger', () => ({
  __esModule: true,
  default: {
    error: jest.fn(),
  },
}));

describe('ErrorHandler Middleware', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should handle AppError with correct status code', () => {
    // Arrange
    const error = new UnauthorizedError('Invalid credentials');
    const req = createMockRequest({ requestId: 'req-123' });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    errorHandler(error, req, res, next);

    // Assert
    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({
      error: {
        code: 'UNAUTHORIZED',
        message: 'Invalid credentials',
      },
    });
    expect(logger.error).toHaveBeenCalled();
  });

  it('should handle NotFoundError with 404 status', () => {
    // Arrange
    const error = new NotFoundError('Resource not found');
    const req = createMockRequest({ requestId: 'req-123' });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    errorHandler(error, req, res, next);

    // Assert
    expect(res.status).toHaveBeenCalledWith(404);
    expect(res.json).toHaveBeenCalledWith({
      error: {
        code: 'NOT_FOUND',
        message: 'Resource not found',
      },
    });
  });

  it('should handle ZodError validation errors', () => {
    // Arrange
    const zodError = new ZodError([
      {
        code: 'invalid_type',
        expected: 'string',
        received: 'number',
        path: ['email'],
        message: 'Expected string, received number',
      },
    ]);
    const req = createMockRequest({ requestId: 'req-123' });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    errorHandler(zodError, req, res, next);

    // Assert
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({
      error: {
        code: 'VALIDATION_ERROR',
        message: 'email: Expected string, received number',
      },
    });
  });

  it('should handle ZodError with nested path', () => {
    // Arrange
    const zodError = new ZodError([
      {
        code: 'invalid_type',
        expected: 'string',
        received: 'undefined',
        path: ['body', 'user', 'name'],
        message: 'Required',
      },
    ]);
    const req = createMockRequest();
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    errorHandler(zodError, req, res, next);

    // Assert
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({
      error: {
        code: 'VALIDATION_ERROR',
        message: 'body.user.name: Required',
      },
    });
  });

  it('should handle ZodError without field path', () => {
    // Arrange
    const zodError = new ZodError([
      {
        code: 'custom',
        path: [],
        message: 'Validation failed',
      },
    ]);
    const req = createMockRequest();
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    errorHandler(zodError, req, res, next);

    // Assert
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Validation failed',
      },
    });
  });

  it('should handle Prisma unique constraint error (P2002)', () => {
    // Arrange
    const prismaError: any = new Error('Unique constraint failed');
    prismaError.name = 'PrismaClientKnownRequestError';
    prismaError.code = 'P2002';
    const req = createMockRequest();
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    errorHandler(prismaError, req, res, next);

    // Assert
    expect(res.status).toHaveBeenCalledWith(409);
    expect(res.json).toHaveBeenCalledWith({
      error: {
        code: 'DUPLICATE_ENTRY',
        message: 'A record with this value already exists',
      },
    });
  });

  it('should handle generic errors with 500 status', () => {
    // Arrange
    const error = new Error('Unexpected error');
    const req = createMockRequest();
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    errorHandler(error, req, res, next);

    // Assert
    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.json).toHaveBeenCalledWith({
      error: {
        code: 'INTERNAL_SERVER_ERROR',
        message: 'An unexpected error occurred',
      },
    });
  });

  it('should log error details with request info', () => {
    // Arrange
    const error = new Error('Test error');
    const req = createMockRequest({
      requestId: 'req-123',
      method: 'POST',
      originalUrl: '/api/test',
      headers: { 'user-agent': 'TestAgent/1.0' },
      ip: '127.0.0.1',
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    errorHandler(error, req, res, next);

    // Assert
    expect(logger.error).toHaveBeenCalledWith(
      '❌ Error handled:',
      expect.objectContaining({
        error: 'Test error',
        requestId: 'req-123',
        method: 'POST',
        url: '/api/test',
      })
    );
  });

  it('should use request logger if available', () => {
    // Arrange
    const mockRequestLogger = {
      error: jest.fn(),
    };
    const error = new Error('Test error');
    const req: any = createMockRequest({
      logger: mockRequestLogger,
      requestId: 'req-123',
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    errorHandler(error, req, res, next);

    // Assert
    expect(mockRequestLogger.error).toHaveBeenCalled();
    expect(logger.error).not.toHaveBeenCalled();
  });

  it('should include stack trace in error log', () => {
    // Arrange
    const error = new Error('Test error with stack');
    const req = createMockRequest();
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    errorHandler(error, req, res, next);

    // Assert
    expect(logger.error).toHaveBeenCalledWith(
      '❌ Error handled:',
      expect.objectContaining({
        stack: expect.any(String),
      })
    );
  });

  it('should handle ValidationError from custom errors', () => {
    // Arrange
    const error = new ValidationError('Invalid input data');
    const req = createMockRequest();
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    errorHandler(error, req, res, next);

    // Assert
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid input data',
      },
    });
  });
});
