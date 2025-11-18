import {
  connectToDatabase,
  disconnectFromDatabase,
  checkDatabaseHealth,
} from '../../../src/db/connection';
import logger from '../../../src/utils/logger';
import { PrismaClient } from '@prisma/client';

// Mock logger
jest.mock('../../../src/utils/logger', () => ({
  __esModule: true,
  default: {
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
  },
}));

// Mock Prisma Client
const mockConnect = jest.fn();
const mockDisconnect = jest.fn();
const mockQueryRaw = jest.fn();

jest.mock('@prisma/client', () => ({
  PrismaClient: jest.fn().mockImplementation(() => ({
    $connect: mockConnect,
    $disconnect: mockDisconnect,
    $queryRaw: mockQueryRaw,
    $on: jest.fn(),
  })),
}));

describe('Database Connection Utils', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('connectToDatabase', () => {
    it('should connect to database successfully', async () => {
      // Arrange
      mockConnect.mockResolvedValue(undefined);
      mockQueryRaw.mockResolvedValue([{ 1: 1 }]);

      // Act
      await connectToDatabase();

      // Assert
      expect(logger.info).toHaveBeenCalledWith('🔌 Connecting to database...');
      expect(mockConnect).toHaveBeenCalled();
      expect(mockQueryRaw).toHaveBeenCalled();
      expect(logger.info).toHaveBeenCalledWith('✅ Database connected successfully');
    });

    it('should throw error if connection fails', async () => {
      // Arrange
      const connectionError = new Error('Connection refused');
      mockConnect.mockRejectedValue(connectionError);

      // Act & Assert
      await expect(connectToDatabase()).rejects.toThrow(
        'Database connection failed: Connection refused'
      );
      expect(logger.error).toHaveBeenCalledWith(
        '❌ Failed to connect to database:',
        connectionError
      );
    });

    it('should throw error if test query fails', async () => {
      // Arrange
      mockConnect.mockResolvedValue(undefined);
      const queryError = new Error('Query failed');
      mockQueryRaw.mockRejectedValue(queryError);

      // Act & Assert
      await expect(connectToDatabase()).rejects.toThrow('Database connection failed: Query failed');
      expect(logger.error).toHaveBeenCalledWith(
        '❌ Failed to connect to database:',
        queryError
      );
    });

    it('should handle unknown error types', async () => {
      // Arrange
      mockConnect.mockRejectedValue('String error');

      // Act & Assert
      await expect(connectToDatabase()).rejects.toThrow(
        'Database connection failed: Unknown error'
      );
    });

    it('should run test query after connecting', async () => {
      // Arrange
      mockConnect.mockResolvedValue(undefined);
      mockQueryRaw.mockResolvedValue([{ 1: 1 }]);

      // Act
      await connectToDatabase();

      // Assert
      expect(mockConnect).toHaveBeenCalledBefore(mockQueryRaw);
      expect(mockQueryRaw).toHaveBeenCalled();
    });
  });

  describe('disconnectFromDatabase', () => {
    it('should disconnect from database successfully', async () => {
      // Arrange
      mockDisconnect.mockResolvedValue(undefined);

      // Act
      await disconnectFromDatabase();

      // Assert
      expect(logger.info).toHaveBeenCalledWith('🔌 Disconnecting from database...');
      expect(mockDisconnect).toHaveBeenCalled();
      expect(logger.info).toHaveBeenCalledWith('✅ Database disconnected successfully');
    });

    it('should log error if disconnect fails', async () => {
      // Arrange
      const disconnectError = new Error('Disconnect failed');
      mockDisconnect.mockRejectedValue(disconnectError);

      // Act
      await disconnectFromDatabase();

      // Assert
      expect(logger.error).toHaveBeenCalledWith(
        '❌ Error disconnecting from database:',
        disconnectError
      );
    });

    it('should not throw error if disconnect fails', async () => {
      // Arrange
      mockDisconnect.mockRejectedValue(new Error('Disconnect failed'));

      // Act & Assert - Should not throw
      await expect(disconnectFromDatabase()).resolves.toBeUndefined();
    });
  });

  describe('checkDatabaseHealth', () => {
    it('should return true when database is healthy', async () => {
      // Arrange
      mockQueryRaw.mockResolvedValue([{ 1: 1 }]);

      // Act
      const result = await checkDatabaseHealth();

      // Assert
      expect(result).toBe(true);
      expect(mockQueryRaw).toHaveBeenCalled();
    });

    it('should return false when database check fails', async () => {
      // Arrange
      mockQueryRaw.mockRejectedValue(new Error('Query failed'));

      // Act
      const result = await checkDatabaseHealth();

      // Assert
      expect(result).toBe(false);
      expect(logger.error).toHaveBeenCalledWith(
        '❌ Database health check failed:',
        expect.any(Error)
      );
    });

    it('should log error when health check fails', async () => {
      // Arrange
      const healthError = new Error('Health check failed');
      mockQueryRaw.mockRejectedValue(healthError);

      // Act
      await checkDatabaseHealth();

      // Assert
      expect(logger.error).toHaveBeenCalledWith(
        '❌ Database health check failed:',
        healthError
      );
    });

    it('should not throw error when health check fails', async () => {
      // Arrange
      mockQueryRaw.mockRejectedValue(new Error('Health check failed'));

      // Act & Assert - Should not throw
      await expect(checkDatabaseHealth()).resolves.toBe(false);
    });
  });

  describe('database lifecycle', () => {
    it('should connect, check health, and disconnect', async () => {
      // Arrange
      mockConnect.mockResolvedValue(undefined);
      mockQueryRaw.mockResolvedValue([{ 1: 1 }]);
      mockDisconnect.mockResolvedValue(undefined);

      // Act
      await connectToDatabase();
      const isHealthy = await checkDatabaseHealth();
      await disconnectFromDatabase();

      // Assert
      expect(mockConnect).toHaveBeenCalled();
      expect(mockQueryRaw).toHaveBeenCalled();
      expect(mockDisconnect).toHaveBeenCalled();
      expect(isHealthy).toBe(true);
    });

    it('should handle connect, failed health check, and disconnect', async () => {
      // Arrange
      mockConnect.mockResolvedValue(undefined);
      mockQueryRaw
        .mockResolvedValueOnce([{ 1: 1 }]) // For connect test query
        .mockRejectedValueOnce(new Error('Health check failed')); // For health check
      mockDisconnect.mockResolvedValue(undefined);

      // Act
      await connectToDatabase();
      const isHealthy = await checkDatabaseHealth();
      await disconnectFromDatabase();

      // Assert
      expect(isHealthy).toBe(false);
      expect(logger.error).toHaveBeenCalledWith(
        '❌ Database health check failed:',
        expect.any(Error)
      );
    });
  });
});
