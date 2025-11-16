import { Router, Response, NextFunction } from 'express';
import { authenticate, AuthRequest, ensureOrganizationAccess } from '../middleware/auth';
import { requireTeamManagerOrAdmin } from '../middleware/roles';
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

// All admin task routes require team manager or admin authentication
router.use(authenticate, requireTeamManagerOrAdmin);

// GET /admin/tasks - List all tasks
router.get(
  '/',
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const tasks = await getAllTasks(req.user!.organizationId);
      res.json({ tasks });
    } catch (error) {
      next(error);
    }
  }
);

// GET /admin/tasks/:id - Get task by ID
router.get(
  '/:id',
  ensureOrganizationAccess('task'),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const task = await getTask(id, req.user!.organizationId);
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
      const task = await createTask(req.user!.organizationId, {
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
  ensureOrganizationAccess('task'),
  validate(updateTaskSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const task = await updateTask(id, req.user!.organizationId, {
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
  ensureOrganizationAccess('task'),
  validate(deleteTaskSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const result = await deleteTask(id, req.user!.organizationId);
      res.json(result);
    } catch (error) {
      next(error);
    }
  }
);

export default router;
