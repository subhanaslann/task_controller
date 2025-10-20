import { Router, Response, NextFunction } from 'express';
import { authenticate, AuthRequest } from '../middleware/auth';
import { requireAdmin } from '../middleware/roles';
import { validate } from '../middleware/validate';
import {
  createTopicSchema,
  updateTopicSchema,
  deleteTopicSchema,
} from '../schemas';
import {
  createTopic,
  updateTopic,
  deleteTopic,
  getTopic,
  getTopics,
} from '../services/topicService';

const router = Router();

// All admin topic routes require admin authentication
router.use(authenticate, requireAdmin);

// GET /admin/topics - List all topics
router.get(
  '/',
  async (_req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const topics = await getTopics();
      res.json({ topics });
    } catch (error) {
      next(error);
    }
  }
);

// GET /admin/topics/:id - Get topic by ID
router.get(
  '/:id',
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const topic = await getTopic(id);
      res.json({ topic });
    } catch (error) {
      next(error);
    }
  }
);

// POST /admin/topics - Create new topic
router.post(
  '/',
  validate(createTopicSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const topic = await createTopic({
        title: req.body.title,
        description: req.body.description,
        isActive: req.body.isActive,
      });
      res.status(201).json({ topic });
    } catch (error) {
      next(error);
    }
  }
);

// PATCH /admin/topics/:id - Update topic
router.patch(
  '/:id',
  validate(updateTopicSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const topic = await updateTopic(id, {
        title: req.body.title,
        description: req.body.description,
        isActive: req.body.isActive,
      });
      res.json({ topic });
    } catch (error) {
      next(error);
    }
  }
);

// DELETE /admin/topics/:id - Delete topic
router.delete(
  '/:id',
  validate(deleteTopicSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const result = await deleteTopic(id);
      res.json(result);
    } catch (error) {
      next(error);
    }
  }
);

export default router;
