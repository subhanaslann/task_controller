import logger from './logger';

interface RequiredEnvVars {
  [key: string]: {
    required: boolean;
    default?: string;
    validate?: (value: string) => boolean;
    description: string;
  };
}

const envVars: RequiredEnvVars = {
  DATABASE_URL: {
    required: true,
    description: 'SQLite database connection URL',
    validate: (value) => value.startsWith('file:') || value.includes('db'),
  },
  JWT_SECRET: {
    required: true,
    description: 'JWT signing secret (minimum 32 characters)',
    validate: (value) => value.length >= 32,
  },
  JWT_EXPIRES_IN: {
    required: false,
    default: '7d',
    description: 'JWT token expiration time',
  },
  PORT: {
    required: false,
    default: '8080',
    description: 'Server port number',
    validate: (value) => {
      const port = parseInt(value, 10);
      return !isNaN(port) && port > 0 && port < 65536;
    },
  },
  NODE_ENV: {
    required: false,
    default: 'development',
    description: 'Node environment (development, production, test)',
    validate: (value) => ['development', 'production', 'test'].includes(value),
  },
  MAX_ACTIVE_USERS: {
    required: false,
    default: '15',
    description: 'Maximum number of active users',
    validate: (value) => {
      const num = parseInt(value, 10);
      return !isNaN(num) && num > 0 && num <= 100;
    },
  },
};

export function validateEnvironment(): void {
  logger.info('🔍 Validating environment variables...');
  
  const errors: string[] = [];
  const warnings: string[] = [];

  // Check each environment variable
  for (const [key, config] of Object.entries(envVars)) {
    const value = process.env[key];

    // Check if required variable is missing
    if (config.required && !value) {
      errors.push(`❌ ${key} is required but not set. ${config.description}`);
      continue;
    }

    // Use default value if not set
    if (!value && config.default) {
      process.env[key] = config.default;
      logger.debug(`🔧 Using default value for ${key}: ${config.default}`);
      continue;
    }

    // Validate value if validator exists
    if (value && config.validate && !config.validate(value)) {
      errors.push(`❌ ${key} has invalid value: "${value}". ${config.description}`);
    }
  }

  // Check for security warnings in development
  if (process.env.NODE_ENV === 'development') {
    if (process.env.JWT_SECRET === 'dev-secret-key-change-in-production') {
      warnings.push('⚠️  Using default JWT secret. Change this in production!');
    }
  }

  // Check for production-specific requirements
  if (process.env.NODE_ENV === 'production') {
    if (!process.env.JWT_SECRET || process.env.JWT_SECRET.includes('dev-secret')) {
      errors.push('❌ Production requires a secure JWT_SECRET');
    }

    if (!process.env.DATABASE_URL || process.env.DATABASE_URL.includes('dev.db')) {
      warnings.push('⚠️  Consider using production database URL');
    }
  }

  // Log warnings
  if (warnings.length > 0) {
    warnings.forEach(warning => logger.warn(warning));
  }

  // Exit if there are errors
  if (errors.length > 0) {
    logger.error('❌ Environment validation failed:');
    errors.forEach(error => logger.error(error));
    logger.error('💡 Please check your .env file or environment variables');
    process.exit(1);
  }

  logger.info('✅ Environment validation passed');
}

export default validateEnvironment;