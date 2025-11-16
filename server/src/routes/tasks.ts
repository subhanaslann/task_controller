import { Router, Response, NextFunction } from 'express';
import { authenticate, AuthRequest, ensureOrganizationAccess } from '../middleware/auth';
import { validate } from '../middleware/validate';
import {
  getTasksSchema,
  updateTaskStatusSchema,
} from '../schemas';
import {
  getMyActiveTasks,
  getTeamActiveTasks,
  getMyCompletedTasks,
  updateTaskStatus,
} from '../services/taskService';
import { ValidationError } from '../utils/errors';
type TaskStatus = 'TODO' | 'IN_PROGRESS' | 'DONE';

const router = Router();

// GET /tasks?scope=my_active|team_active|my_done
router.get(
  '/',
  authenticate,
  validate(getTasksSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { scope } = req.query;
      const userId = req.user!.id;
      const organizationId = req.user!.organizationId;
      const userRole = req.user!.role;

      let tasks;
      switch (scope) {
        case 'my_active':
          tasks = await getMyActiveTasks(userId, organizationId);
          break;
        case 'team_active':
          tasks = await getTeamActiveTasks(organizationId, userRole);
          break;
        case 'my_done':
          tasks = await getMyCompletedTasks(userId, organizationId);
          break;
        default:
          throw new ValidationError('Invalid scope parameter');
      }

      res.json({ tasks });
    } catch (error) {
      next(error);
    }
  }
);

// PATCH /tasks/:id/status
router.patch(
  '/:id/status',
  authenticate,
  ensureOrganizationAccess('task'),
  validate(updateTaskStatusSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const { status } = req.body;
      const userId = req.user!.id;
      const organizationId = req.user!.organizationId;
      const userRole = req.user!.role;

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

export default router;
