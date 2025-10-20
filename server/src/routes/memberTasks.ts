import { Router, Response, NextFunction } from 'express';
import { authenticate, AuthRequest } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { createMemberTaskSchema, updateTaskSchema, updateTaskStatusSchema } from '../schemas';
import {
  createMemberTask,
  updateMemberTask,
  deleteTask,
  updateTaskStatus,
} from '../services/taskService';
import { ForbiddenError, NotFoundError } from '../utils/errors';
import prisma from '../db/connection';

type TaskStatus = 'TODO' | 'IN_PROGRESS' | 'DONE';

const router = Router();

// All member task routes require authentication
router.use(authenticate);

// POST /tasks - Create task for self (member only)
router.post(
  '/',
  validate(createMemberTaskSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.userId;
      const userRole = req.user!.role;

      // Guest users cannot create tasks
      if (userRole === 'GUEST') {
        throw new ForbiddenError('Guest users cannot create tasks');
      }

      const task = await createMemberTask({
        topicId: req.body.topicId,
        title: req.body.title,
        note: req.body.note,
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
  validate(updateTaskStatusSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const { status } = req.body;
      const userId = req.user!.userId;
      const userRole = req.user!.role;

      if (userRole === 'GUEST') {
        throw new ForbiddenError('Guest users cannot update tasks');
      }

      const task = await updateTaskStatus(
        id,
        status as TaskStatus,
        userId,
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
  validate(updateTaskSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const userId = req.user!.userId;
      const userRole = req.user!.role;

      // Admin can update any task (handled separately in admin routes)
      // Member can only update their own tasks
      if (userRole === 'GUEST') {
        throw new ForbiddenError('Guest users cannot update tasks');
      }

      const task = await updateMemberTask(id, {
        title: req.body.title,
        note: req.body.note,
        status: req.body.status,
        priority: req.body.priority,
        dueDate: req.body.dueDate ? new Date(req.body.dueDate) : undefined,
      }, userId);

      res.json({ task });
    } catch (error) {
      next(error);
    }
  }
);

// DELETE /tasks/:id - Delete own task
router.delete(
  '/:id',
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const userId = req.user!.userId;
      const userRole = req.user!.role;

      if (userRole === 'GUEST') {
        throw new ForbiddenError('Guest users cannot delete tasks');
      }

      // Verify task ownership
      const task = await prisma.task.findUnique({
        where: { id },
      });

      if (!task) {
        throw new NotFoundError('Task not found');
      }

      if (userRole !== 'ADMIN' && task.assigneeId !== userId) {
        throw new ForbiddenError('You can only delete your own tasks');
      }

      const result = await deleteTask(id);
      res.json(result);
    } catch (error) {
      next(error);
    }
  }
);

export default router;
