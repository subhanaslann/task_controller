import { Response, NextFunction } from 'express';
import { AuthRequest } from './auth';
import { ForbiddenError } from '../utils/errors';
import { Role } from '../types';
import { RequestUser } from '../types';

/**
 * Check if user has ADMIN role (system-wide admin)
 */
export const requireAdmin = (
  req: AuthRequest,
  _res: Response,
  next: NextFunction
): void => {
  if (!req.user || req.user.role !== Role.ADMIN) {
    return next(new ForbiddenError('Admin access required'));
  }
  next();
};

/**
 * Check if user has TEAM_MANAGER or ADMIN role
 * TEAM_MANAGER has admin privileges within their organization
 */
export const requireTeamManagerOrAdmin = (
  req: AuthRequest,
  _res: Response,
  next: NextFunction
): void => {
  if (!req.user || (req.user.role !== Role.TEAM_MANAGER && req.user.role !== Role.ADMIN)) {
    return next(new ForbiddenError('Team Manager or Admin access required'));
  }
  next();
};

/**
 * Require one or more roles
 */
export const requireRole = (...roles: Role[]) => {
  return (req: AuthRequest, _res: Response, next: NextFunction): void => {
    if (!req.user || !roles.includes(req.user.role)) {
      return next(new ForbiddenError('Insufficient permissions'));
    }
    next();
  };
};

/**
 * Helper function to check if user is team manager or admin
 */
export const isTeamManagerOrAdmin = (user: RequestUser): boolean => {
  return user.role === Role.TEAM_MANAGER || user.role === Role.ADMIN;
};

/**
 * Helper function to check if user is admin
 */
export const isAdmin = (user: RequestUser): boolean => {
  return user.role === Role.ADMIN;
};
