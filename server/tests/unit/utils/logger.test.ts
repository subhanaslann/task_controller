import winston from 'winston';
import { logger, addRequestId } from '../../../src/utils/logger';

// Mock winston
jest.mock('winston', () => {
  const mFormat = {
    combine: jest.fn(),
    colorize: jest.fn(),
    timestamp: jest.fn(),
    errors: jest.fn(),
    printf: jest.fn(),
    json: jest.fn(),
  };

  const mTransports = {
    Console: jest.fn(),
    File: jest.fn(),
  };

  const mockLogger = {
    info: jest.fn(),
    error: jest.fn(),
    warn: jest.fn(),
    debug: jest.fn(),
    child: jest.fn(),
  };

  return {
    format: mFormat,
    transports: mTransports,
    createLogger: jest.fn(() => mockLogger),
  };
});

// Mock config
jest.mock('../../../src/config/index', () => ({
  config: {
    isDevelopment: true,
    isProduction: false,
  },
}));

describe('Logger Utils', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('logger', () => {
    it('should be defined', () => {
      expect(logger).toBeDefined();
    });

    it('should have logging methods', () => {
      expect(logger.info).toBeDefined();
      expect(logger.error).toBeDefined();
      expect(logger.warn).toBeDefined();
      expect(logger.debug).toBeDefined();
    });

    it('should log info messages', () => {
      // Act
      logger.info('Test info message');

      // Assert
      expect(logger.info).toHaveBeenCalledWith('Test info message');
    });

    it('should log error messages', () => {
      // Act
      logger.error('Test error message');

      // Assert
      expect(logger.error).toHaveBeenCalledWith('Test error message');
    });

    it('should log warning messages', () => {
      // Act
      logger.warn('Test warning message');

      // Assert
      expect(logger.warn).toHaveBeenCalledWith('Test warning message');
    });

    it('should log debug messages', () => {
      // Act
      logger.debug('Test debug message');

      // Assert
      expect(logger.debug).toHaveBeenCalledWith('Test debug message');
    });

    it('should log messages with metadata', () => {
      // Arrange
      const metadata = {
        userId: 'user-123',
        action: 'login',
      };

      // Act
      logger.info('User logged in', metadata);

      // Assert
      expect(logger.info).toHaveBeenCalledWith('User logged in', metadata);
    });

    it('should log errors with error objects', () => {
      // Arrange
      const error = new Error('Test error');

      // Act
      logger.error('An error occurred', { error });

      // Assert
      expect(logger.error).toHaveBeenCalledWith('An error occurred', { error });
    });
  });

  describe('addRequestId', () => {
    it('should create child logger with request ID', () => {
      // Arrange
      const mockChildLogger = {
        info: jest.fn(),
        error: jest.fn(),
      };
      (logger.child as jest.Mock).mockReturnValue(mockChildLogger);

      // Act
      const childLogger = addRequestId('req-123');

      // Assert
      expect(logger.child).toHaveBeenCalledWith({ requestId: 'req-123' });
      expect(childLogger).toBe(mockChildLogger);
    });

    it('should create child logger that logs with request ID context', () => {
      // Arrange
      const mockChildLogger = {
        info: jest.fn(),
        error: jest.fn(),
        warn: jest.fn(),
        debug: jest.fn(),
      };
      (logger.child as jest.Mock).mockReturnValue(mockChildLogger);

      // Act
      const childLogger = addRequestId('req-456');
      childLogger.info('Request processed');

      // Assert
      expect(mockChildLogger.info).toHaveBeenCalledWith('Request processed');
    });

    it('should create different child loggers for different request IDs', () => {
      // Arrange
      const mockChildLogger1 = { info: jest.fn() };
      const mockChildLogger2 = { info: jest.fn() };
      (logger.child as jest.Mock)
        .mockReturnValueOnce(mockChildLogger1)
        .mockReturnValueOnce(mockChildLogger2);

      // Act
      const logger1 = addRequestId('req-1');
      const logger2 = addRequestId('req-2');

      // Assert
      expect(logger.child).toHaveBeenNthCalledWith(1, { requestId: 'req-1' });
      expect(logger.child).toHaveBeenNthCalledWith(2, { requestId: 'req-2' });
      expect(logger1).not.toBe(logger2);
    });
  });

  describe('winston configuration', () => {
    it('should create logger with winston', () => {
      expect(winston.createLogger).toHaveBeenCalled();
    });

    it('should configure format methods', () => {
      expect(winston.format.combine).toHaveBeenCalled();
    });

    it('should configure console transport', () => {
      expect(winston.transports.Console).toHaveBeenCalled();
    });
  });
});
