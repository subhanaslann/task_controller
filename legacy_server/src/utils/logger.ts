import winston from 'winston';
import { config } from '../config/index';

// Custom format for development
const devFormat = winston.format.combine(
  winston.format.colorize(),
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.errors({ stack: true }),
  winston.format.printf(({ timestamp, level, message, stack, ...meta }) => {
    let log = `${timestamp} [${level}]: ${message}`;
    if (stack) {
      log += `\n${stack}`;
    }
    if (Object.keys(meta).length > 0) {
      log += `\n${JSON.stringify(meta, null, 2)}`;
    }
    return log;
  })
);

// Production format (JSON for structured logging)
const prodFormat = winston.format.combine(
  winston.format.timestamp(),
  winston.format.errors({ stack: true }),
  winston.format.json()
);

// Create logger instance
const logger = winston.createLogger({
  level: config.isDevelopment ? 'debug' : 'info',
  format: config.isDevelopment ? devFormat : prodFormat,
  defaultMeta: { service: 'mini-task-tracker-api' },
  transports: [
    // Console transport
    new winston.transports.Console({
      stderrLevels: ['error'],
    }),
    
    // File transports for production
    ...(config.isProduction ? [
      new winston.transports.File({
        filename: 'logs/error.log',
        level: 'error',
        maxsize: 5242880, // 5MB
        maxFiles: 5,
      }),
      new winston.transports.File({
        filename: 'logs/combined.log',
        maxsize: 5242880, // 5MB
        maxFiles: 5,
      }),
    ] : []),
  ],
  
  // Handle uncaught exceptions
  exceptionHandlers: [
    new winston.transports.Console(),
    ...(config.isProduction ? [
      new winston.transports.File({ filename: 'logs/exceptions.log' })
    ] : []),
  ],
  
  // Handle unhandled promise rejections
  rejectionHandlers: [
    new winston.transports.Console(),
    ...(config.isProduction ? [
      new winston.transports.File({ filename: 'logs/rejections.log' })
    ] : []),
  ],
});

// Add request ID to log context
export const addRequestId = (requestId: string) => {
  return logger.child({ requestId });
};

export { logger };
export default logger;