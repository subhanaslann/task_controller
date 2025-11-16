import { Request, Response, NextFunction } from 'express';
import { verifyToken } from '../utils/jwt';
import { UnauthorizedError, OrganizationInactiveError, OrganizationNotFoundError, CrossOrganizationAccessError } from '../utils/errors';
import { RequestUser } from '../types';
import { prisma } from '../db/prisma';
import { Role } from '@prisma/client';

export interface AuthRequest extends Request {
  user?: RequestUser;
}

export const authenticate = async (
  req: AuthRequest,
  _res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedError('No token provided');
    }

    const token = authHeader.substring(7);
    const payload = verifyToken(token);

    // Verify organization exists and is active
    const organization = await prisma.organization.findUnique({
      where: { id: payload.organizationId },
    });

    if (!organization) {
      throw new OrganizationNotFoundError();
    }

    if (!organization.isActive) {
      throw new OrganizationInactiveError();
    }

    // Attach user info to request
    req.user = {
      id: payload.userId,
      organizationId: payload.organizationId,
      role: payload.role,
      email: payload.email,
    };

    next();
  } catch (error) {
    if (
      error instanceof UnauthorizedError ||
      error instanceof OrganizationNotFoundError ||
      error instanceof OrganizationInactiveError
    ) {
      next(error);
    } else {
      next(new UnauthorizedError('Invalid token'));
    }
  }
};

/**
 * Middleware to ensure resource belongs to user's organization
 * Use this for routes that access specific resources by ID (e.g., /tasks/:id, /topics/:id)
 *
 * @param resourceType - The type of resource being accessed ('task', 'topic', 'user')
 */
export const ensureOrganizationAccess = (resourceType: 'task' | 'topic' | 'user') => {
  return async (req: AuthRequest, _res: Response, next: NextFunction): Promise<void> => {
    try {
      if (!req.user) {
        throw new UnauthorizedError('User not authenticated');
      }

      // ADMIN role has access to all organizations
      if (req.user.role === Role.ADMIN) {
        next();
        return;
      }

      const resourceId = req.params.id;
      if (!resourceId) {
        next();
        return;
      }

      let resource: { organizationId: string } | null = null;

      // Fetch the resource to check its organizationId
      switch (resourceType) {
        case 'task':
          resource = await prisma.task.findUnique({
            where: { id: resourceId },
            select: { organizationId: true },
          });
          break;
        case 'topic':
          resource = await prisma.topic.findUnique({
            where: { id: resourceId },
            select: { organizationId: true },
          });
          break;
        case 'user':
          resource = await prisma.user.findUnique({
            where: { id: resourceId },
            select: { organizationId: true },
          });
          break;
      }

      if (!resource) {
        // Resource will be handled by the route handler (404)
        next();
        return;
      }

      // Verify resource belongs to user's organization
      if (resource.organizationId !== req.user.organizationId) {
        throw new CrossOrganizationAccessError();
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};
