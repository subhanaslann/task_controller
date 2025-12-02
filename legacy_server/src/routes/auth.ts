import { Router, Request, Response, NextFunction } from 'express';
import { login } from '../services/authService';
import { validate } from '../middleware/validate';
import { loginSchema } from '../schemas';

const router = Router();

router.post(
  '/login',
  validate(loginSchema),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { usernameOrEmail, password } = req.body;
      const result = await login(usernameOrEmail, password);
      res.json(result);
    } catch (error) {
      next(error);
    }
  }
);

export default router;
