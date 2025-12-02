import { Router, Response, NextFunction } from 'express';
import { authenticate, AuthRequest } from '../middleware/auth';
import { getActiveTopics } from '../services/topicService';

const router = Router();

// GET /topics/active - Get all active topics with tasks
router.get(
  '/active',
  authenticate,
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const organizationId = req.user!.organizationId;
      const userId = req.user!.id;
      const userRole = req.user!.role;
      const topics = await getActiveTopics(organizationId, userId, userRole);
      res.json({ topics });
    } catch (error) {
      next(error);
    }
  }
);

export default router;
