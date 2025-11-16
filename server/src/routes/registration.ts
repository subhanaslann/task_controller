import { Router, Request, Response } from 'express';
import { registerTeamManager } from '../services/registrationService';
import { validate } from '../middleware/validate';
import { registerTeamSchema } from '../schemas';
import { logger } from '../utils/logger';

const router = Router();

/**
 * POST /auth/register
 * Register a new team (organization) with a team manager
 */
router.post(
  '/register',
  validate(registerTeamSchema),
  async (req: Request, res: Response, next) => {
    try {
      const result = await registerTeamManager(req.body);

      logger.info('Team registered successfully', {
        organizationId: result.organization.id,
        organizationName: result.organization.name,
        managerId: result.user.id,
        managerEmail: result.user.email,
      });

      res.status(201).json({
        message: 'Team registered successfully',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }
);

export default router;
