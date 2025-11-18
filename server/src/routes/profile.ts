import { Router, Response, NextFunction } from 'express';
import { authenticate, AuthRequest } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { updateProfile } from '../services/userService';
import { z } from 'zod';

const router = Router();

// All profile routes require authentication
router.use(authenticate);

// Schema for profile update
const updateProfileSchema = z.object({
    body: z.object({
        name: z.string().min(1, 'Name is required').optional(),
        avatar: z.string().optional().nullable(),
        password: z.string().min(6, 'Password must be at least 6 characters').optional(),
    }),
});

/**
 * PATCH /profile - Update current user's profile
 */
router.patch(
    '/',
    validate(updateProfileSchema),
    async (req: AuthRequest, res: Response, next: NextFunction) => {
        try {
            const userId = req.user!.id;
            const organizationId = req.user!.organizationId;
            const { name, avatar, password } = req.body;

            const updatedUser = await updateProfile(userId, organizationId, {
                name,
                avatar,
                password,
            });

            res.json({ data: updatedUser });
        } catch (error) {
            next(error);
        }
    }
);

/**
 * GET /profile - Get current user's profile
 */
router.get(
    '/',
    async (req: AuthRequest, res: Response, next: NextFunction) => {
        try {
            const userId = req.user!.id;
            const organizationId = req.user!.organizationId;

            const user = await require('../services/userService').getUser(userId, organizationId);
            res.json({ data: user });
        } catch (error) {
            next(error);
        }
    }
);

export default router;
