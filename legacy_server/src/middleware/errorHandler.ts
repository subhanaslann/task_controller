import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/errors';
import { ZodError } from 'zod';
import logger from '../utils/logger';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void => {
  // Use request logger if available, otherwise use default logger
  const requestLogger = req.logger || logger;

  requestLogger.error('❌ Error handled:', {
    error: err.message,
    stack: err.stack,
    requestId: req.requestId,
    method: req.method,
    url: req.originalUrl || req.url,
    userAgent: req.get ? req.get('User-Agent') : undefined,
    ip: req.ip,
  });

  // Handle Zod validation errors
  if (err instanceof ZodError) {
    // Extract first error with field path
    const firstError = err.errors[0];
    const field = firstError?.path?.join('.') || '';
    const message = firstError?.message || 'Validation failed';
    const errorMessage = field ? `${field}: ${message}` : message;
    res.status(400).json({
      error: {
        code: 'VALIDATION_ERROR',
        message: errorMessage,
      },
    });
    return;
  }

  // Handle custom app errors
  if (err instanceof AppError) {
    res.status(err.statusCode).json({
      error: {
        code: err.code,
        message: err.message,
      },
    });
    return;
  }

  // Handle Prisma errors
  if (err.name === 'PrismaClientKnownRequestError') {
    const prismaError = err as any;
    if (prismaError.code === 'P2002') {
      res.status(409).json({
        error: {
          code: 'DUPLICATE_ENTRY',
          message: 'A record with this value already exists',
        },
      });
      return;
    }
  }

  // Default server error
  res.status(500).json({
    error: {
      code: 'INTERNAL_SERVER_ERROR',
      message: 'An unexpected error occurred',
    },
  });
};
