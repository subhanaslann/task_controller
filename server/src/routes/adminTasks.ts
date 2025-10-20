import { Router, Response, NextFunction } from 'express';
import { authenticate, AuthRequest } from '../middleware/auth';
import { requireAdmin } from '../middleware/roles';
import { validate } from '../middleware/validate';
import {
  createTaskSchema,
  updateTaskSchema,
  deleteTaskSchema,
} from '../schemas';
import {
  createTask,
  updateTask,
  deleteTask,
  getAllTasks,
  getTask,
} from '../services/taskService';
type TaskStatus = 'TODO' | 'IN_PROGRESS' | 'DONE';
type Priority = 'LOW' | 'NORMAL' | 'HIGH';

const router = Router();

// All admin task routes require admin authentication
router.use(authenticate, requireAdmin);

// GET /admin/tasks - List all tasks
router.get(
  '/',
  async (_req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const tasks = await getAllTasks();
      res.json({ tasks });
    } catch (error) {
      next(error);
    }
  }
);

// GET /admin/tasks/:id - Get task by ID
router.get(
  '/:id',
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const task = await getTask(id);
      res.json({ task });
    } catch (error) {
      next(error);
    }
  }
);

// POST /admin/tasks - Create new task
router.post(
  '/',
  validate(createTaskSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const task = await createTask({
        topicId: req.body.topicId,
        title: req.body.title,
        note: req.body.note,
        assigneeId: req.body.assigneeId,
        status: req.body.status as TaskStatus | undefined,
        priority: req.body.priority as Priority | undefined,
        dueDate: req.body.dueDate ? new Date(req.body.dueDate) : undefined,
      });
      res.status(201).json({ task });
    } catch (error) {
      next(error);
    }
  }
);

// PATCH /admin/tasks/:id - Update task
router.patch(
  '/:id',
  validate(updateTaskSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const task = await updateTask(id, {
        title: req.body.title,
        note: req.body.note,
        status: req.body.status as TaskStatus | undefined,
        priority: req.body.priority as Priority | undefined,
        dueDate: req.body.dueDate ? new Date(req.body.dueDate) : undefined,
      });
      res.json({ task });
    } catch (error) {
      next(error);
    }
  }
);

// DELETE /admin/tasks/:id - Delete task
router.delete(
  '/:id',
  validate(deleteTaskSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const result = await deleteTask(id);
      res.json(result);
    } catch (error) {
      next(error);
    }
  }
);

export default router;
