import { z } from 'zod';

// Auth schemas
export const loginSchema = z.object({
  body: z.object({
    usernameOrEmail: z.string().min(1, 'Username or email is required'),
    password: z.string().min(1, 'Password is required'),
  }),
});

// Registration schema
export const registerTeamSchema = z.object({
  body: z.object({
    companyName: z.string().min(2, 'Company name must be at least 2 characters').max(100, 'Company name must not exceed 100 characters'),
    teamName: z.string().min(2, 'Team name must be at least 2 characters').max(100, 'Team name must not exceed 100 characters'),
    managerName: z.string().min(2, 'Manager name must be at least 2 characters').max(100, 'Manager name must not exceed 100 characters'),
    username: z.string().min(3, 'Username must be at least 3 characters').max(50, 'Username must not exceed 50 characters'),
    email: z.string().email('Invalid email address'),
    password: z.string().min(8, 'Password must be at least 8 characters').max(100, 'Password must not exceed 100 characters'),
  }),
});

// User schemas
export const createUserSchema = z.object({
  body: z.object({
    name: z.string().min(1, 'Name is required'),
    username: z.string().min(3, 'Username must be at least 3 characters'),
    email: z.string().email('Invalid email address'),
    password: z.string().min(6, 'Password must be at least 6 characters'),
    role: z.enum(['ADMIN', 'TEAM_MANAGER', 'MEMBER', 'GUEST']),
    active: z.boolean().optional(),
    visibleTopicIds: z.array(z.string().uuid()).optional(),
  }),
});

export const updateUserSchema = z.object({
  params: z.object({
    id: z.string().uuid('Invalid user ID'),
  }),
  body: z.object({
    name: z.string().min(1).optional(),
    role: z.enum(['ADMIN', 'TEAM_MANAGER', 'MEMBER', 'GUEST']).optional(),
    active: z.boolean().optional(),
    password: z.string().min(6).optional(),
    visibleTopicIds: z.array(z.string().uuid()).optional(),
  }),
});

// Task schemas
export const getTasksSchema = z.object({
  query: z.object({
    scope: z.enum(['my_active', 'team_active', 'my_done']),
  }),
});

export const updateTaskStatusSchema = z.object({
  params: z.object({
    id: z.string().uuid('Invalid task ID'),
  }),
  body: z.object({
    status: z.enum(['TODO', 'IN_PROGRESS', 'DONE']),
  }),
});

export const createTaskSchema = z.object({
  body: z.object({
    topicId: z.string().uuid('Invalid topic ID').optional(),
    title: z.string().min(1, 'Title is required'),
    note: z.string().optional(),
    status: z.enum(['TODO', 'IN_PROGRESS', 'DONE']).optional(),
    priority: z.enum(['LOW', 'NORMAL', 'HIGH']).optional(),
    dueDate: z.string().refine((val) => !isNaN(Date.parse(val)), {
      message: 'Invalid date format',
    }).optional(),
  }),
});

export const updateTaskSchema = z.object({
  params: z.object({
    id: z.string().uuid('Invalid task ID'),
  }),
  body: z.object({
    title: z.string().min(1).optional(),
    note: z.string().optional().nullable(),
    status: z.enum(['TODO', 'IN_PROGRESS', 'DONE']).optional(),
    priority: z.enum(['LOW', 'NORMAL', 'HIGH']).optional(),
    dueDate: z.string().refine((val) => !isNaN(Date.parse(val)), {
      message: 'Invalid date format',
    }).optional().nullable(),
  }),
});

export const deleteTaskSchema = z.object({
  params: z.object({
    id: z.string().uuid('Invalid task ID'),
  }),
});

export const getTaskByIdSchema = z.object({
  params: z.object({
    id: z.string().uuid('Invalid task ID'),
  }),
});

// Topic schemas
export const createTopicSchema = z.object({
  body: z.object({
    title: z.string().min(1, 'Title is required'),
    description: z.string().optional(),
    isActive: z.boolean().optional(),
  }),
});

export const updateTopicSchema = z.object({
  params: z.object({
    id: z.string().uuid('Invalid topic ID'),
  }),
  body: z.object({
    title: z.string().min(1).optional(),
    description: z.string().optional().nullable(),
    isActive: z.boolean().optional(),
  }),
});

export const deleteTopicSchema = z.object({
  params: z.object({
    id: z.string().uuid('Invalid topic ID'),
  }),
});

// Member task creation schema (self-assign only)
export const createMemberTaskSchema = z.object({
  body: z.object({
    topicId: z.string().uuid('Invalid topic ID').optional(),
    title: z.string().min(1, 'Title is required'),
    note: z.string().optional(),
    status: z.enum(['TODO', 'IN_PROGRESS', 'DONE']).optional(),
    priority: z.enum(['LOW', 'NORMAL', 'HIGH']).optional(),
    dueDate: z.string().refine((val) => !isNaN(Date.parse(val)), {
      message: 'Invalid date format',
    }).optional(),
  }).strict(),
});
