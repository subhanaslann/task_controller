import { PrismaClient } from '@prisma/client';
import logger from '../utils/logger';

// Prisma client with enhanced error handling
const prisma = new PrismaClient({
  log: [
    {
      emit: 'event',
      level: 'query',
    },
    {
      emit: 'event',
      level: 'error',
    },
    {
      emit: 'event',
      level: 'info',
    },
    {
      emit: 'event',
      level: 'warn',
    },
  ],
});

// Handle Prisma events
prisma.$on('error', (e) => {
  logger.error('💥 Database error:', {
    timestamp: e.timestamp,
    message: e.message,
    target: e.target,
  });
});

prisma.$on('warn', (e) => {
  logger.warn('⚠️ Database warning:', {
    timestamp: e.timestamp,
    message: e.message,
    target: e.target,
  });
});

prisma.$on('info', (e) => {
  logger.info('ℹ️ Database info:', {
    timestamp: e.timestamp,
    message: e.message,
    target: e.target,
  });
});

// Log slow queries in development
if (process.env.NODE_ENV === 'development') {
  prisma.$on('query', (e) => {
    if (e.duration > 1000) { // Log queries taking more than 1 second
      logger.warn('🐌 Slow query detected:', {
        query: e.query,
        params: e.params,
        duration: `${e.duration}ms`,
        timestamp: e.timestamp,
      });
    }
  });
}

// Test database connection
export async function connectToDatabase(): Promise<void> {
  try {
    logger.info('🔌 Connecting to database...');
    
    // Test the connection
    await prisma.$connect();
    
    // Run a simple query to verify the connection
    await prisma.$queryRaw`SELECT 1`;
    
    logger.info('✅ Database connected successfully');
  } catch (error) {
    logger.error('❌ Failed to connect to database:', error);
    throw new Error(`Database connection failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

// Graceful database disconnect
export async function disconnectFromDatabase(): Promise<void> {
  try {
    logger.info('🔌 Disconnecting from database...');
    await prisma.$disconnect();
    logger.info('✅ Database disconnected successfully');
  } catch (error) {
    logger.error('❌ Error disconnecting from database:', error);
  }
}

// Health check for database
export async function checkDatabaseHealth(): Promise<boolean> {
  try {
    await prisma.$queryRaw`SELECT 1`;
    return true;
  } catch (error) {
    logger.error('❌ Database health check failed:', error);
    return false;
  }
}

export default prisma;