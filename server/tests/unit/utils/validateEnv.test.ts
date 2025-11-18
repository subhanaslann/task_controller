import { validateEnvironment } from '../../../src/utils/validateEnv';
import logger from '../../../src/utils/logger';

// Mock logger
jest.mock('../../../src/utils/logger', () => ({
  __esModule: true,
  default: {
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
    debug: jest.fn(),
  },
}));

describe('ValidateEnv Utils', () => {
  const originalEnv = process.env;
  const originalExit = process.exit;

  beforeEach(() => {
    // Reset environment
    jest.resetModules();
    process.env = { ...originalEnv };
    process.exit = jest.fn() as any;
    jest.clearAllMocks();
  });

  afterAll(() => {
    process.env = originalEnv;
    process.exit = originalExit;
  });

  describe('validateEnvironment', () => {
    it('should pass validation with all required env vars set', () => {
      // Arrange
      process.env.DATABASE_URL = 'file:./dev.db';
      process.env.JWT_SECRET = 'a'.repeat(32);
      process.env.NODE_ENV = 'development';

      // Act
      validateEnvironment();

      // Assert
      expect(logger.info).toHaveBeenCalledWith('🔍 Validating environment variables...');
      expect(logger.info).toHaveBeenCalledWith('✅ Environment validation passed');
      expect(process.exit).not.toHaveBeenCalled();
    });

    it('should fail validation when DATABASE_URL is missing', () => {
      // Arrange
      delete process.env.DATABASE_URL;
      process.env.JWT_SECRET = 'a'.repeat(32);

      // Act
      validateEnvironment();

      // Assert
      expect(logger.error).toHaveBeenCalledWith('❌ Environment validation failed:');
      expect(logger.error).toHaveBeenCalledWith(
        expect.stringContaining('DATABASE_URL is required')
      );
      expect(process.exit).toHaveBeenCalledWith(1);
    });

    it('should fail validation when JWT_SECRET is missing', () => {
      // Arrange
      process.env.DATABASE_URL = 'file:./dev.db';
      delete process.env.JWT_SECRET;

      // Act
      validateEnvironment();

      // Assert
      expect(logger.error).toHaveBeenCalledWith(
        expect.stringContaining('JWT_SECRET is required')
      );
      expect(process.exit).toHaveBeenCalledWith(1);
    });

    it('should fail validation when JWT_SECRET is too short', () => {
      // Arrange
      process.env.DATABASE_URL = 'file:./dev.db';
      process.env.JWT_SECRET = 'short'; // Less than 32 characters

      // Act
      validateEnvironment();

      // Assert
      expect(logger.error).toHaveBeenCalledWith(
        expect.stringContaining('JWT_SECRET has invalid value')
      );
      expect(process.exit).toHaveBeenCalledWith(1);
    });

    it('should use default values for optional variables', () => {
      // Arrange
      process.env.DATABASE_URL = 'file:./dev.db';
      process.env.JWT_SECRET = 'a'.repeat(32);
      delete process.env.PORT;
      delete process.env.NODE_ENV;
      delete process.env.JWT_EXPIRES_IN;

      // Act
      validateEnvironment();

      // Assert
      expect(process.env.PORT).toBe('8080');
      expect(process.env.NODE_ENV).toBe('development');
      expect(process.env.JWT_EXPIRES_IN).toBe('7d');
      expect(logger.debug).toHaveBeenCalledWith(
        expect.stringContaining('Using default value for PORT: 8080')
      );
    });

    it('should validate DATABASE_URL format', () => {
      // Arrange
      process.env.DATABASE_URL = 'invalid-url';
      process.env.JWT_SECRET = 'a'.repeat(32);

      // Act
      validateEnvironment();

      // Assert
      expect(logger.error).toHaveBeenCalledWith(
        expect.stringContaining('DATABASE_URL has invalid value')
      );
      expect(process.exit).toHaveBeenCalledWith(1);
    });

    it('should validate PORT is a valid number', () => {
      // Arrange
      process.env.DATABASE_URL = 'file:./dev.db';
      process.env.JWT_SECRET = 'a'.repeat(32);
      process.env.PORT = 'invalid-port';

      // Act
      validateEnvironment();

      // Assert
      expect(logger.error).toHaveBeenCalledWith(
        expect.stringContaining('PORT has invalid value')
      );
      expect(process.exit).toHaveBeenCalledWith(1);
    });

    it('should validate PORT is within valid range', () => {
      // Arrange
      process.env.DATABASE_URL = 'file:./dev.db';
      process.env.JWT_SECRET = 'a'.repeat(32);
      process.env.PORT = '70000'; // Above 65535

      // Act
      validateEnvironment();

      // Assert
      expect(logger.error).toHaveBeenCalledWith(
        expect.stringContaining('PORT has invalid value')
      );
      expect(process.exit).toHaveBeenCalledWith(1);
    });

    it('should validate NODE_ENV is one of allowed values', () => {
      // Arrange
      process.env.DATABASE_URL = 'file:./dev.db';
      process.env.JWT_SECRET = 'a'.repeat(32);
      process.env.NODE_ENV = 'invalid-env';

      // Act
      validateEnvironment();

      // Assert
      expect(logger.error).toHaveBeenCalledWith(
        expect.stringContaining('NODE_ENV has invalid value')
      );
      expect(process.exit).toHaveBeenCalledWith(1);
    });

    it('should accept valid NODE_ENV values', () => {
      const validEnvs = ['development', 'production', 'test'];

      validEnvs.forEach((env) => {
        // Arrange
        jest.clearAllMocks();
        process.env.DATABASE_URL = 'file:./dev.db';
        process.env.JWT_SECRET = 'a'.repeat(32);
        process.env.NODE_ENV = env;

        // Act
        validateEnvironment();

        // Assert
        expect(process.exit).not.toHaveBeenCalled();
      });
    });

    it('should validate MAX_ACTIVE_USERS is a valid number', () => {
      // Arrange
      process.env.DATABASE_URL = 'file:./dev.db';
      process.env.JWT_SECRET = 'a'.repeat(32);
      process.env.MAX_ACTIVE_USERS = 'not-a-number';

      // Act
      validateEnvironment();

      // Assert
      expect(logger.error).toHaveBeenCalledWith(
        expect.stringContaining('MAX_ACTIVE_USERS has invalid value')
      );
      expect(process.exit).toHaveBeenCalledWith(1);
    });

    it('should validate MAX_ACTIVE_USERS is within range', () => {
      // Arrange
      process.env.DATABASE_URL = 'file:./dev.db';
      process.env.JWT_SECRET = 'a'.repeat(32);
      process.env.MAX_ACTIVE_USERS = '150'; // Above 100

      // Act
      validateEnvironment();

      // Assert
      expect(logger.error).toHaveBeenCalledWith(
        expect.stringContaining('MAX_ACTIVE_USERS has invalid value')
      );
      expect(process.exit).toHaveBeenCalledWith(1);
    });

    it('should warn about default JWT secret in development', () => {
      // Arrange
      process.env.DATABASE_URL = 'file:./dev.db';
      process.env.JWT_SECRET = 'dev-secret-key-change-in-production';
      process.env.NODE_ENV = 'development';

      // Act
      validateEnvironment();

      // Assert
      expect(logger.warn).toHaveBeenCalledWith(
        expect.stringContaining('Using default JWT secret')
      );
      expect(process.exit).not.toHaveBeenCalled();
    });

    it('should fail in production with default JWT secret', () => {
      // Arrange
      process.env.DATABASE_URL = 'file:./dev.db';
      process.env.JWT_SECRET = 'dev-secret-key-change-in-production';
      process.env.NODE_ENV = 'production';

      // Act
      validateEnvironment();

      // Assert
      expect(logger.error).toHaveBeenCalledWith(
        expect.stringContaining('Production requires a secure JWT_SECRET')
      );
      expect(process.exit).toHaveBeenCalledWith(1);
    });

    it('should fail in production with dev in JWT secret', () => {
      // Arrange
      process.env.DATABASE_URL = 'file:./dev.db';
      process.env.JWT_SECRET = 'my-dev-secret-key-with-32-characters-minimum';
      process.env.NODE_ENV = 'production';

      // Act
      validateEnvironment();

      // Assert
      expect(logger.error).toHaveBeenCalledWith(
        expect.stringContaining('Production requires a secure JWT_SECRET')
      );
      expect(process.exit).toHaveBeenCalledWith(1);
    });

    it('should warn about dev database in production', () => {
      // Arrange
      process.env.DATABASE_URL = 'file:./dev.db';
      process.env.JWT_SECRET = 'a'.repeat(32);
      process.env.NODE_ENV = 'production';

      // Act
      validateEnvironment();

      // Assert
      expect(logger.warn).toHaveBeenCalledWith(
        expect.stringContaining('Consider using production database URL')
      );
    });

    it('should handle multiple validation errors', () => {
      // Arrange
      delete process.env.DATABASE_URL;
      delete process.env.JWT_SECRET;
      process.env.PORT = 'invalid';

      // Act
      validateEnvironment();

      // Assert
      expect(logger.error).toHaveBeenCalledWith('❌ Environment validation failed:');
      const errorCalls = (logger.error as jest.Mock).mock.calls;
      expect(errorCalls.length).toBeGreaterThan(2); // Multiple errors logged
      expect(process.exit).toHaveBeenCalledWith(1);
    });

    it('should log validation success message', () => {
      // Arrange
      process.env.DATABASE_URL = 'file:./dev.db';
      process.env.JWT_SECRET = 'a'.repeat(32);
      process.env.NODE_ENV = 'test';

      // Act
      validateEnvironment();

      // Assert
      expect(logger.info).toHaveBeenCalledWith('✅ Environment validation passed');
    });

    it('should accept valid PORT numbers', () => {
      const validPorts = ['3000', '8080', '5000', '1', '65535'];

      validPorts.forEach((port) => {
        // Arrange
        jest.clearAllMocks();
        process.env.DATABASE_URL = 'file:./dev.db';
        process.env.JWT_SECRET = 'a'.repeat(32);
        process.env.PORT = port;

        // Act
        validateEnvironment();

        // Assert
        expect(process.exit).not.toHaveBeenCalled();
      });
    });
  });
});
