import { z } from 'zod';

// Enums
export const RoleEnum = z.enum(['TEAM_MANAGER', 'MEMBER', 'GUEST']);
export const TaskStatusEnum = z.enum(['TODO', 'IN_PROGRESS', 'DONE']);
export const PriorityEnum = z.enum(['LOW', 'NORMAL', 'HIGH']);

export type Role = z.infer<typeof RoleEnum>;
export type TaskStatus = z.infer<typeof TaskStatusEnum>;
export type Priority = z.infer<typeof PriorityEnum>;

// Auth schemas
export const loginSchema = z.object({
  usernameOrEmail: z.string().min(1, 'Username or email is required'),
  password: z.string().min(1, 'Password is required'),
});

export const registerTeamSchema = z.object({
  companyName: z.string().min(2).max(100),
  teamName: z.string().min(2).max(100),
  managerName: z.string().min(2).max(100),
  username: z.string().min(3).max(50),
  email: z.string().email(),
  password: z.string().min(8).max(100),
});

// User schemas
export const createUserSchema = z.object({
  name: z.string().min(1),
  username: z.string().min(3),
  email: z.string().email(),
  password: z.string().min(6),
  role: RoleEnum,
  active: z.boolean().optional(),
  visibleTopicIds: z.array(z.string()).optional(),
});

export const updateUserSchema = z.object({
  userId: z.string().min(1),
  name: z.string().min(1).optional(),
  role: RoleEnum.optional(),
  active: z.boolean().optional(),
  password: z.string().min(6).optional(),
  visibleTopicIds: z.array(z.string()).optional(),
});

export const updateProfileSchema = z.object({
  name: z.string().min(1).optional(),
  avatar: z.string().optional(),
  password: z.string().min(6).optional(),
});

// Task schemas
export const createTaskSchema = z.object({
  topicId: z.string().optional(),
  title: z.string().min(1),
  note: z.string().optional(),
  assigneeId: z.string().optional(),
  status: TaskStatusEnum.optional(),
  priority: PriorityEnum.optional(),
  dueDate: z.string().datetime().optional().nullable(),
});

export const createMemberTaskSchema = z.object({
  topicId: z.string().optional(),
  title: z.string().min(1),
  note: z.string().optional(),
  status: TaskStatusEnum.optional(),
  priority: PriorityEnum.optional(),
  dueDate: z.string().datetime().optional().nullable(),
});

export const updateTaskSchema = z.object({
  taskId: z.string().min(1),
  title: z.string().min(1).optional(),
  note: z.string().optional().nullable(),
  assigneeId: z.string().optional().nullable(),
  status: TaskStatusEnum.optional(),
  priority: PriorityEnum.optional(),
  dueDate: z.string().datetime().optional().nullable(),
});

export const updateTaskStatusSchema = z.object({
  taskId: z.string().min(1),
  status: TaskStatusEnum,
});

export const deleteTaskSchema = z.object({
  taskId: z.string().min(1),
});

// Topic schemas
export const createTopicSchema = z.object({
  title: z.string().min(1),
  description: z.string().optional(),
  isActive: z.boolean().optional(),
});

export const updateTopicSchema = z.object({
  topicId: z.string().min(1),
  title: z.string().min(1).optional(),
  description: z.string().optional().nullable(),
  isActive: z.boolean().optional(),
});

export const deleteTopicSchema = z.object({
  topicId: z.string().min(1),
});

// Organization schemas
export const updateOrganizationSchema = z.object({
  name: z.string().min(1).optional(),
  teamName: z.string().min(1).optional(),
  maxUsers: z.number().int().min(1).optional(),
});

export const orgIdSchema = z.object({
  organizationId: z.string().min(1),
});
