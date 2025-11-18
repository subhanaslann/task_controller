import { requestLogger } from '../../../src/middleware/requestLogger';
import logger, { addRequestId } from '../../../src/utils/logger';
import { createMockRequest, createMockResponse, createMockNext } from '../utils/testUtils';

// Mock logger
jest.mock('../../../src/utils/logger', () => ({
  __esModule: true,
  default: {
    info: jest.fn(),
    error: jest.fn(),
  },
  addRequestId: jest.fn(),
}));

// Mock uuid
jest.mock('uuid', () => ({
  v4: jest.fn(() => 'mock-request-id-123'),
}));

describe('RequestLogger Middleware', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    (addRequestId as jest.Mock).mockReturnValue({
      info: jest.fn(),
      error: jest.fn(),
    });
  });

  it('should generate and attach request ID', () => {
    // Arrange
    const req = createMockRequest({
      method: 'GET',
      originalUrl: '/api/tasks',
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    requestLogger(req as any, res as any, next);

    // Assert
    expect(req.requestId).toBe('mock-request-id-123');
    expect(next).toHaveBeenCalled();
  });

  it('should attach request-specific logger', () => {
    // Arrange
    const req = createMockRequest();
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    requestLogger(req as any, res as any, next);

    // Assert
    expect(addRequestId).toHaveBeenCalledWith('mock-request-id-123');
    expect(req.logger).toBeDefined();
  });

  it('should record start time', () => {
    // Arrange
    const now = Date.now();
    const req = createMockRequest();
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    requestLogger(req as any, res as any, next);

    // Assert
    expect(req.startTime).toBeGreaterThanOrEqual(now);
    expect(req.startTime).toBeLessThanOrEqual(Date.now());
  });

  it('should log request start with details', () => {
    // Arrange
    const mockLogger = {
      info: jest.fn(),
      error: jest.fn(),
    };
    (addRequestId as jest.Mock).mockReturnValue(mockLogger);

    const req = createMockRequest({
      method: 'POST',
      originalUrl: '/api/tasks',
      headers: { 'user-agent': 'TestAgent/1.0' },
      ip: '127.0.0.1',
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    requestLogger(req as any, res as any, next);

    // Assert
    expect(mockLogger.info).toHaveBeenCalledWith(
      '📥 Request started',
      expect.objectContaining({
        method: 'POST',
        url: '/api/tasks',
        ip: '127.0.0.1',
        userAgent: 'TestAgent/1.0',
        requestId: 'mock-request-id-123',
      })
    );
  });

  it('should log response completion when res.json is called', () => {
    // Arrange
    const mockLogger = {
      info: jest.fn(),
      error: jest.fn(),
    };
    (addRequestId as jest.Mock).mockReturnValue(mockLogger);

    const req = createMockRequest({
      method: 'GET',
      originalUrl: '/api/tasks',
    });
    const res = createMockResponse();
    const next = createMockNext();

    requestLogger(req as any, res as any, next);

    // Act
    res.json({ data: 'test' });

    // Assert
    expect(mockLogger.info).toHaveBeenCalledWith(
      '📤 Request completed',
      expect.objectContaining({
        method: 'GET',
        url: '/api/tasks',
        statusCode: 200,
        requestId: 'mock-request-id-123',
      })
    );
  });

  it('should calculate request duration', () => {
    // Arrange
    const mockLogger = {
      info: jest.fn(),
      error: jest.fn(),
    };
    (addRequestId as jest.Mock).mockReturnValue(mockLogger);

    const req = createMockRequest();
    const res = createMockResponse();
    const next = createMockNext();

    requestLogger(req as any, res as any, next);

    // Simulate some delay
    const startTime = req.startTime;
    req.startTime = startTime - 100; // Mock 100ms delay

    // Act
    res.json({ data: 'test' });

    // Assert
    const completionCall = mockLogger.info.mock.calls.find(
      (call) => call[0] === '📤 Request completed'
    );
    expect(completionCall[1].duration).toMatch(/\d+ms/);
  });

  it('should include response size in log', () => {
    // Arrange
    const mockLogger = {
      info: jest.fn(),
      error: jest.fn(),
    };
    (addRequestId as jest.Mock).mockReturnValue(mockLogger);

    const req = createMockRequest();
    const res = createMockResponse();
    const next = createMockNext();

    requestLogger(req as any, res as any, next);

    // Act
    const responseData = { tasks: [{ id: 1 }, { id: 2 }] };
    res.json(responseData);

    // Assert
    const completionCall = mockLogger.info.mock.calls.find(
      (call) => call[0] === '📤 Request completed'
    );
    expect(completionCall[1].responseSize).toBe(JSON.stringify(responseData).length);
  });

  it('should handle missing user-agent header', () => {
    // Arrange
    const mockLogger = {
      info: jest.fn(),
      error: jest.fn(),
    };
    (addRequestId as jest.Mock).mockReturnValue(mockLogger);

    const req = createMockRequest({
      headers: {},
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    requestLogger(req as any, res as any, next);

    // Assert
    expect(mockLogger.info).toHaveBeenCalledWith(
      '📥 Request started',
      expect.objectContaining({
        userAgent: 'unknown',
      })
    );
  });

  it('should handle missing IP address', () => {
    // Arrange
    const mockLogger = {
      info: jest.fn(),
      error: jest.fn(),
    };
    (addRequestId as jest.Mock).mockReturnValue(mockLogger);

    const req: any = createMockRequest({});
    delete req.ip;
    req.connection = {};

    const res = createMockResponse();
    const next = createMockNext();

    // Act
    requestLogger(req, res as any, next);

    // Assert
    expect(mockLogger.info).toHaveBeenCalledWith(
      '📥 Request started',
      expect.objectContaining({
        ip: 'unknown',
      })
    );
  });

  it('should log with different status codes', () => {
    // Arrange
    const mockLogger = {
      info: jest.fn(),
      error: jest.fn(),
    };
    (addRequestId as jest.Mock).mockReturnValue(mockLogger);

    const req = createMockRequest();
    const res = createMockResponse();
    res.statusCode = 404;
    const next = createMockNext();

    requestLogger(req as any, res as any, next);

    // Act
    res.json({ error: 'Not found' });

    // Assert
    const completionCall = mockLogger.info.mock.calls.find(
      (call) => call[0] === '📤 Request completed'
    );
    expect(completionCall[1].statusCode).toBe(404);
  });

  it('should use originalUrl if available, otherwise url', () => {
    // Arrange
    const mockLogger = {
      info: jest.fn(),
      error: jest.fn(),
    };
    (addRequestId as jest.Mock).mockReturnValue(mockLogger);

    const req = createMockRequest({
      url: '/tasks',
      originalUrl: '/api/tasks',
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    requestLogger(req as any, res as any, next);

    // Assert
    expect(mockLogger.info).toHaveBeenCalledWith(
      '📥 Request started',
      expect.objectContaining({
        url: '/api/tasks',
      })
    );
  });

  it('should fall back to url if originalUrl is not set', () => {
    // Arrange
    const mockLogger = {
      info: jest.fn(),
      error: jest.fn(),
    };
    (addRequestId as jest.Mock).mockReturnValue(mockLogger);

    const req: any = createMockRequest({
      url: '/tasks',
    });
    delete req.originalUrl;

    const res = createMockResponse();
    const next = createMockNext();

    // Act
    requestLogger(req, res as any, next);

    // Assert
    expect(mockLogger.info).toHaveBeenCalledWith(
      '📥 Request started',
      expect.objectContaining({
        url: '/tasks',
      })
    );
  });
});
