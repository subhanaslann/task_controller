import { Router, Response, NextFunction } from 'express';
import { authenticate, AuthRequest, ensureOrganizationAccess } from '../middleware/auth';
import { requireTeamManagerOrAdmin } from '../middleware/roles';
import { validate } from '../middleware/validate';
import { createUserSchema, updateUserSchema } from '../schemas';
import {
  createUser,
  updateUser,
  getUsers,
  getUser,
  deleteUser,
} from '../services/userService';
import { Role } from '../types';

const router = Router();

// All user routes require team manager or admin authentication
router.use(authenticate, requireTeamManagerOrAdmin);

// GET /users - List all users
router.get(
  '/',
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const users = await getUsers(req.user!.organizationId);
      res.json({ users });
    } catch (error) {
      next(error);
    }
  }
);

// GET /users/:id - Get user by ID
router.get(
  '/:id',
  ensureOrganizationAccess('user'),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const user = await getUser(id, req.user!.organizationId);
      res.json({ user });
    } catch (error) {
      next(error);
    }
  }
);

// POST /users - Create new user
router.post(
  '/',
  validate(createUserSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const user = await createUser(
        req.user!.organizationId,
        {
          name: req.body.name,
          username: req.body.username,
          email: req.body.email,
          password: req.body.password,
          role: req.body.role as Role,
          active: req.body.active,
          visibleTopicIds: req.body.visibleTopicIds,
        },
        req.user!.role
      );
      res.status(201).json({ user });
    } catch (error) {
      next(error);
    }
  }
);

// PATCH /users/:id - Update user
router.patch(
  '/:id',
  ensureOrganizationAccess('user'),
  validate(updateUserSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const user = await updateUser(
        id,
        req.user!.organizationId,
        {
          name: req.body.name,
          role: req.body.role as Role | undefined,
          active: req.body.active,
          password: req.body.password,
          visibleTopicIds: req.body.visibleTopicIds,
        },
        req.user!.role
      );
      res.json({ user });
    } catch (error) {
      next(error);
    }
  }
);

// DELETE /users/:id - Delete user
router.delete(
  '/:id',
  ensureOrganizationAccess('user'),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const result = await deleteUser(id, req.user!.organizationId);
      res.json(result);
    } catch (error) {
      next(error);
    }
  }
);

export default router;
