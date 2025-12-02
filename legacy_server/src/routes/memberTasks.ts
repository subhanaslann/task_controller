import { Router, Response, NextFunction } from 'express';
import { authenticate, AuthRequest, ensureOrganizationAccess } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { createMemberTaskSchema, updateTaskSchema, updateTaskStatusSchema, getTaskByIdSchema } from '../schemas';
import {
  createMemberTask,
  updateMemberTask,
  deleteTask,
  updateTaskStatus,
} from '../services/taskService';
import { ForbiddenError, NotFoundError } from '../utils/errors';
import prisma from '../db/connection';
import { Role } from '../types';

type TaskStatus = 'TODO' | 'IN_PROGRESS' | 'DONE';

const router = Router();

// All member task routes require authentication
router.use(authenticate);

// GET /tasks/:id - Get task by ID (members can view their own tasks)
router.get(
  '/:id',
  validate(getTaskByIdSchema),
  ensureOrganizationAccess('task'),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const userId = req.user!.id;
      const organizationId = req.user!.organizationId;
      const userRole = req.user!.role;

      // Get task from the same organization
      const task = await prisma.task.findFirst({
        where: {
          id,
          organizationId,
        },
        include: {
          topic: {
            select: {
              id: true,
              title: true,
            },
          },
          assignee: {
            select: {
              id: true,
              name: true,
              username: true,
            },
          },
        },
      });

      if (!task) {
        throw new NotFoundError('Task not found');
      }

      // Members can only view their own tasks
      if (userRole === Role.MEMBER && task.assigneeId !== userId) {
        throw new NotFoundError('Task not found');
      }

      // Guest users have limited field access
      if (userRole === Role.GUEST) {
        const limitedTask = {
          id: task.id,
          title: task.title,
          status: task.status,
          priority: task.priority,
          dueDate: task.dueDate,
          assignee: task.assignee ? {
            id: task.assignee.id,
            name: task.assignee.name,
          } : null,
        };
        res.json({ task: limitedTask });
      } else {
        res.json({ task });
      }
    } catch (error) {
      next(error);
    }
  }
);

// POST /tasks - Create task for self (member only)
router.post(
  '/',
  validate(createMemberTaskSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.id;
      const organizationId = req.user!.organizationId;
      const userRole = req.user!.role;

      // Guest users cannot create tasks
      if (userRole === Role.GUEST) {
        throw new ForbiddenError('Guest users cannot create tasks');
      }

      const task = await createMemberTask(organizationId, {
        topicId: req.body.topicId,
        title: req.body.title,
        note: req.body.note,
        status: req.body.status,
        priority: req.body.priority,
        dueDate: req.body.dueDate ? new Date(req.body.dueDate) : undefined,
        assigneeId: userId, // Always assign to self
      });

      res.status(201).json({ task });
    } catch (error) {
      next(error);
    }
  }
);

// PATCH /tasks/:id/status - Update task status (quick update for My Active)
router.patch(
  '/:id/status',
  ensureOrganizationAccess('task'),
  validate(updateTaskStatusSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const { status } = req.body;
      const userId = req.user!.id;
      const organizationId = req.user!.organizationId;
      const userRole = req.user!.role;

      if (userRole === Role.GUEST) {
        throw new ForbiddenError('Guest users cannot update tasks');
      }

      const task = await updateTaskStatus(
        id,
        status as TaskStatus,
        userId,
        organizationId,
        userRole
      );

      res.json({ task });
    } catch (error) {
      next(error);
    }
  }
);

// PATCH /tasks/:id - Update own task (full update)
router.patch(
  '/:id',
  ensureOrganizationAccess('task'),
  validate(updateTaskSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const userId = req.user!.id;
      const organizationId = req.user!.organizationId;
      const userRole = req.user!.role;

      // Admin can update any task (handled separately in admin routes)
      // Member can only update their own tasks
      if (userRole === Role.GUEST) {
        throw new ForbiddenError('Guest users cannot update tasks');
      }

      const task = await updateMemberTask(
        id,
        organizationId,
        {
          title: req.body.title,
          note: req.body.note,
          status: req.body.status,
          priority: req.body.priority,
          dueDate: req.body.dueDate ? new Date(req.body.dueDate) : undefined,
        },
        userId
      );

      res.json({ task });
    } catch (error) {
      next(error);
    }
  }
);

// DELETE /tasks/:id - Delete own task
router.delete(
  '/:id',
  ensureOrganizationAccess('task'),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const userId = req.user!.id;
      const organizationId = req.user!.organizationId;
      const userRole = req.user!.role;

      if (userRole === Role.GUEST) {
        throw new ForbiddenError('Guest users cannot delete tasks');
      }

      // Verify task ownership
      const task = await prisma.task.findFirst({
        where: {
          id,
          organizationId,
        },
      });

      if (!task) {
        throw new NotFoundError('Task not found');
      }

      if (userRole !== Role.ADMIN && userRole !== Role.TEAM_MANAGER && task.assigneeId !== userId) {
        throw new ForbiddenError('You can only delete your own tasks');
      }

      const result = await deleteTask(id, organizationId);
      res.json(result);
    } catch (error) {
      next(error);
    }
  }
);

export default router;
