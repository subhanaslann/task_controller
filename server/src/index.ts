import { config } from './config/index';
import { createApp } from './app';
import logger from './utils/logger';
import validateEnvironment from './utils/validateEnv';
import { connectToDatabase, disconnectFromDatabase } from './db/connection';

// Validate environment variables first
validateEnvironment();

const app = createApp();
let server: any;

// Startup sequence
async function startServer() {
  try {
    // Connect to database
    await connectToDatabase();
    
    // Start HTTP server
    server = app.listen(config.port, '0.0.0.0', () => {
      logger.info('🚀 Mini Task Tracker API Server started', {
        environment: config.nodeEnv,
        port: config.port,
        urls: {
          local: `http://localhost:${config.port}`,
          health: `http://localhost:${config.port}/health`,
        },
      });
      
      // Log startup banner in development
      if (config.isDevelopment) {
        console.log(`
🚀 Mini Task Tracker API Server
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Environment: ${config.nodeEnv}
Port:        ${config.port}
URL:         http://localhost:${config.port}
Health:      http://localhost:${config.port}/health
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
`);
      }
    });
    
    // Handle server errors
    server.on('error', (error: any) => {
      if (error.code === 'EADDRINUSE') {
        logger.error(`❌ Port ${config.port} is already in use`);
        process.exit(1);
      } else {
        logger.error('❌ Server error:', error);
        process.exit(1);
      }
    });
    
  } catch (error) {
    logger.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
async function gracefulShutdown(signal: string) {
  logger.info(`🛑 ${signal} received. Starting graceful shutdown...`);
  
  const shutdownTimeout = setTimeout(() => {
    logger.error('❌ Shutdown timeout reached. Force closing.');
    process.exit(1);
  }, 30000); // 30 seconds timeout
  
  try {
    // Close HTTP server
    if (server) {
      await new Promise<void>((resolve, reject) => {
        server.close((err: any) => {
          if (err) {
            logger.error('❌ Error closing server:', err);
            reject(err);
          } else {
            logger.info('✅ HTTP server closed');
            resolve();
          }
        });
      });
    }
    
    // Disconnect from database
    await disconnectFromDatabase();
    
    clearTimeout(shutdownTimeout);
    logger.info('✅ Graceful shutdown completed');
    process.exit(0);
    
  } catch (error) {
    logger.error('❌ Error during shutdown:', error);
    clearTimeout(shutdownTimeout);
    process.exit(1);
  }
}

// Handle shutdown signals
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));

// Handle uncaught exceptions and unhandled rejections
process.on('uncaughtException', (error) => {
  logger.error('💥 Uncaught Exception:', error);
  gracefulShutdown('UNCAUGHT_EXCEPTION');
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('💥 Unhandled Rejection at:', { promise, reason });
  gracefulShutdown('UNHANDLED_REJECTION');
});

// Start the server
startServer();
