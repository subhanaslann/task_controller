import { Router, Response } from 'express';
import { AuthRequest, authenticate } from '../middleware/auth';
import { requireTeamManagerOrAdmin, requireAdmin } from '../middleware/roles';
import {
  getOrganizationById,
  updateOrganization,
  getOrganizationStats,
  deactivateOrganization,
  activateOrganization,
} from '../services/organizationService';
import { logger } from '../utils/logger';

const router = Router();

// All routes require authentication
router.use(authenticate);

/**
 * GET /organization
 * Get current user's organization details
 */
router.get('/', async (req: AuthRequest, res: Response, next) => {
  try {
    const organization = await getOrganizationById(req.user!.organizationId);

    res.json({
      message: 'Organization retrieved successfully',
      data: organization,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * PATCH /organization
 * Update organization details (TEAM_MANAGER or ADMIN only)
 */
router.patch('/', requireTeamManagerOrAdmin, async (req: AuthRequest, res: Response, next) => {
  try {
    const organization = await updateOrganization(req.user!.organizationId, req.body);

    logger.info('Organization updated', {
      organizationId: organization.id,
      updatedBy: req.user!.id,
    });

    res.json({
      message: 'Organization updated successfully',
      data: organization,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /organization/stats
 * Get organization usage statistics
 */
router.get('/stats', async (req: AuthRequest, res: Response, next) => {
  try {
    const stats = await getOrganizationStats(req.user!.organizationId);

    res.json({
      message: 'Organization statistics retrieved successfully',
      data: stats,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /organization/:id/deactivate
 * Deactivate an organization (ADMIN only)
 */
router.post('/:id/deactivate', requireAdmin, async (req: AuthRequest, res: Response, next) => {
  try {
    await deactivateOrganization(req.params.id);

    logger.warn('Organization deactivated', {
      organizationId: req.params.id,
      deactivatedBy: req.user!.id,
    });

    res.json({
      message: 'Organization deactivated successfully',
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /organization/:id/activate
 * Activate an organization (ADMIN only)
 */
router.post('/:id/activate', requireAdmin, async (req: AuthRequest, res: Response, next) => {
  try {
    await activateOrganization(req.params.id);

    logger.info('Organization activated', {
      organizationId: req.params.id,
      activatedBy: req.user!.id,
    });

    res.json({
      message: 'Organization activated successfully',
    });
  } catch (error) {
    next(error);
  }
});

export default router;
