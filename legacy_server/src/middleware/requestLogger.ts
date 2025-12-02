import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';
import logger, { addRequestId } from '../utils/logger';

// Extend Request interface to include requestId
declare global {
  namespace Express {
    interface Request {
      requestId: string;
      logger: typeof logger;
      startTime: number;
    }
  }
}

// Request logging middleware
export const requestLogger = (req: Request, res: Response, next: NextFunction) => {
  // Generate unique request ID
  const requestId = uuidv4();
  req.requestId = requestId;
  req.startTime = Date.now();

  // Create request-specific logger
  req.logger = addRequestId(requestId);

  // Extract client info
  const ip = req.ip || req.connection.remoteAddress || 'unknown';
  const userAgent = req.get('User-Agent') || 'unknown';
  const method = req.method;
  const url = req.originalUrl || req.url;
  
  // Log request start
  req.logger.info('📥 Request started', {
    method,
    url,
    ip,
    userAgent,
    requestId,
  });

  // Override res.json to log response
  const originalJson = res.json;
  res.json = function (data: any) {
    const duration = Date.now() - req.startTime;
    const statusCode = res.statusCode;
    
    // Log response
    req.logger.info('📤 Request completed', {
      method,
      url,
      statusCode,
      duration: `${duration}ms`,
      requestId,
      responseSize: JSON.stringify(data).length,
    });
    
    return originalJson.call(this, data);
  };

  // Log response when it finishes
  res.on('finish', () => {
    const duration = Date.now() - req.startTime;
    const statusCode = res.statusCode;
    
    // Only log if we haven't already logged from res.json override
    if (!res.headersSent || res.getHeader('content-type') !== 'application/json; charset=utf-8') {
      req.logger.info('📤 Request completed', {
        method,
        url,
        statusCode,
        duration: `${duration}ms`,
        requestId,
      });
    }
  });

  // Handle errors that occur during request processing
  const onError = (error: Error) => {
    const duration = Date.now() - req.startTime;
    
    req.logger.error('❌ Request failed', {
      method,
      url,
      statusCode: res.statusCode,
      duration: `${duration}ms`,
      requestId,
      error: error.message,
      stack: error.stack,
    });
  };

  // Listen for response errors
  res.on('error', onError);

  next();
};

export default requestLogger;