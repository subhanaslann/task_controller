import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { config } from './config/index';
import { errorHandler } from './middleware/errorHandler';
import { requestLogger } from './middleware/requestLogger';
import authRoutes from './routes/auth';
import registrationRoutes from './routes/registration';
import organizationRoutes from './routes/organization';
import taskRoutes from './routes/tasks';
import userRoutes from './routes/users';
import adminTaskRoutes from './routes/adminTasks';
import adminTopicRoutes from './routes/adminTopics';
import topicRoutes from './routes/topics';
import memberTaskRoutes from './routes/memberTasks';
import profileRoutes from './routes/profile';
import logger from './utils/logger';
import { checkDatabaseHealth } from './db/connection';
import { prisma } from './db/prisma';

export function createApp() {
  const app = express();

  // Security middleware
  app.use(helmet());

  // Rate limiting (disable in test and development for automated testing)
  // if (process.env.NODE_ENV !== 'test' && process.env.NODE_ENV !== 'development') {
  //   const limiter = rateLimit({
  //     windowMs: 15 * 60 * 1000, // 15 minutes
  //     max: 100, // Limit each IP to 100 requests per windowMs
  //     message: 'Too many requests from this IP, please try again later.',
  //     standardHeaders: true,
  //     legacyHeaders: false,
  //   });
  //   app.use(limiter);
  // }

  // CORS configuration
  app.use(
    cors({
      origin: config.isDevelopment
        ? ['http://10.0.2.2:8080', 'http://localhost:8080', 'http://127.0.0.1:8080']
        : [],
      credentials: true,
    })
  );

  // Body parsing middleware
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  // Request logging middleware (after body parsing)
  if (process.env.NODE_ENV !== 'test') {
    app.use(requestLogger);
  }

  // Enhanced health check endpoint
  app.get('/health', async (req, res) => {
    const requestLogger = req.logger || logger;

    try {
      const dbHealthy = await checkDatabaseHealth();
      const status = dbHealthy ? 'healthy' : 'unhealthy';
      const statusCode = dbHealthy ? 200 : 503;

      // Get organization statistics
      let orgStats = {};
      try {
        const [organizationCount, activeOrganizationCount] = await Promise.all([
          prisma.organization.count(),
          prisma.organization.count({ where: { isActive: true } }),
        ]);
        orgStats = {
          organizations: organizationCount,
          activeOrganizations: activeOrganizationCount,
        };
      } catch (err) {
        requestLogger.warn('Could not fetch organization stats', err);
      }

      const healthData = {
        status,
        timestamp: new Date().toISOString(),
        environment: config.nodeEnv,
        database: dbHealthy ? 'connected' : 'disconnected',
        uptime: process.uptime(),
        memory: {
          used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
          total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024),
        },
        ...orgStats,
      };

      if (!dbHealthy) {
        requestLogger.warn('❌ Health check failed: database unhealthy');
      }

      res.status(statusCode).json(healthData);
    } catch (error) {
      requestLogger.error('❌ Health check error:', error);
      res.status(503).json({
        status: 'error',
        timestamp: new Date().toISOString(),
        error: 'Health check failed',
      });
    }
  });

  // API routes
  app.use('/auth', authRoutes); // Login
  app.use('/auth', registrationRoutes); // Team registration
  app.use('/organization', organizationRoutes); // Organization management
  app.use('/profile', profileRoutes); // User profile management
  app.use('/tasks/view', taskRoutes); // View tasks (my_active, team_active, my_done)
  app.use('/tasks', memberTaskRoutes); // Member task CRUD (create/update/delete own tasks)
  app.use('/topics', topicRoutes); // Active topics
  app.use('/users', userRoutes); // Admin user management
  app.use('/admin/tasks', adminTaskRoutes); // Admin task management
  app.use('/admin/topics', adminTopicRoutes); // Admin topic management

  // 404 handler
  app.use((_req, res) => {
    res.status(404).json({
      error: {
        code: 'NOT_FOUND',
        message: 'Route not found',
      },
    });
  });

  // Global error handler (must be last)
  app.use(errorHandler);

  return app;
}
