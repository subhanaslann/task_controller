import { Router, Response, NextFunction } from 'express';
import { authenticate, AuthRequest } from '../middleware/auth';
import { requireAdmin } from '../middleware/roles';
import { validate } from '../middleware/validate';
import { createUserSchema, updateUserSchema } from '../schemas';
import {
  createUser,
  updateUser,
  getUsers,
  getUser,
  deleteUser,
} from '../services/userService';
type Role = 'ADMIN' | 'MEMBER' | 'GUEST';

const router = Router();

// All user routes require admin authentication
router.use(authenticate, requireAdmin);

// GET /users - List all users
router.get(
  '/',
  async (_req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const users = await getUsers();
      res.json({ users });
    } catch (error) {
      next(error);
    }
  }
);

// GET /users/:id - Get user by ID
router.get(
  '/:id',
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const user = await getUser(id);
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
      const user = await createUser({
        name: req.body.name,
        username: req.body.username,
        email: req.body.email,
        password: req.body.password,
        role: req.body.role as Role,
        active: req.body.active,
        visibleTopicIds: req.body.visibleTopicIds,
      });
      res.status(201).json({ user });
    } catch (error) {
      next(error);
    }
  }
);

// PATCH /users/:id - Update user
router.patch(
  '/:id',
  validate(updateUserSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const user = await updateUser(id, {
        name: req.body.name,
        role: req.body.role as Role | undefined,
        active: req.body.active,
        password: req.body.password,
        visibleTopicIds: req.body.visibleTopicIds,
      });
      res.json({ user });
    } catch (error) {
      next(error);
    }
  }
);

// DELETE /users/:id - Delete user
router.delete(
  '/:id',
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const result = await deleteUser(id);
      res.json(result);
    } catch (error) {
      next(error);
    }
  }
);

export default router;
