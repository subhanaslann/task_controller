// =====================================================
// Role Enum (for SQLite compatibility)
// =====================================================

export enum Role {
  ADMIN = 'ADMIN',           // System-wide admin (for platform management)
  TEAM_MANAGER = 'TEAM_MANAGER', // Organization owner/manager (can manage their org users)
  MEMBER = 'MEMBER',         // Regular team member
  GUEST = 'GUEST'            // Limited access user
}

// =====================================================
// Authentication & Authorization Types
// =====================================================

export interface JwtPayload {
  userId: string;
  organizationId: string;
  role: Role;
  email: string;
}

export interface RequestUser {
  id: string;
  organizationId: string;
  role: Role;
  email: string;
}

// =====================================================
// Registration Types
// =====================================================

export interface RegisterTeamDto {
  companyName: string;
  teamName: string;
  managerName: string;
  username?: string;
  email: string;
  password: string;
}

export interface RegisterTeamResponse {
  organization: OrganizationResponse;
  user: UserResponse;
  token: string;
}

// =====================================================
// Organization Types
// =====================================================

export interface OrganizationResponse {
  id: string;
  name: string;
  teamName: string;
  slug: string;
  isActive: boolean;
  maxUsers: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface UpdateOrganizationDto {
  name?: string;
  teamName?: string;
  maxUsers?: number;
}

export interface OrganizationStatsResponse {
  userCount: number;
  activeUserCount: number;
  taskCount: number;
  activeTaskCount: number;
  completedTaskCount: number;
  topicCount: number;
  activeTopicCount: number;
}

// =====================================================
// User Types
// =====================================================

export interface UserResponse {
  id: string;
  organizationId: string;
  name: string;
  username: string;
  email: string;
  role: Role;
  active: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateUserDto {
  name: string;
  username: string;
  email: string;
  password: string;
  role: Role;
}

export interface UpdateUserDto {
  name?: string;
  username?: string;
  email?: string;
  password?: string;
  role?: Role;
  active?: boolean;
}

// =====================================================
// Task Types
// =====================================================

export interface TaskResponse {
  id: string;
  organizationId: string;
  topicId: string | null;
  title: string;
  note: string | null;
  assigneeId: string | null;
  status: string;
  priority: string;
  dueDate: Date | null;
  createdAt: Date;
  updatedAt: Date;
  completedAt: Date | null;
  topic?: TopicResponse | null;
  assignee?: UserResponse | null;
}

export interface CreateTaskDto {
  topicId?: string;
  title: string;
  note?: string;
  assigneeId?: string;
  status?: string;
  priority?: string;
  dueDate?: Date;
}

export interface UpdateTaskDto {
  topicId?: string;
  title?: string;
  note?: string;
  assigneeId?: string;
  status?: string;
  priority?: string;
  dueDate?: Date;
}

// =====================================================
// Topic Types
// =====================================================

export interface TopicResponse {
  id: string;
  organizationId: string;
  title: string;
  description: string | null;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateTopicDto {
  title: string;
  description?: string;
  isActive?: boolean;
}

export interface UpdateTopicDto {
  title?: string;
  description?: string;
  isActive?: boolean;
}

// =====================================================
// Express Request Extension
// =====================================================

declare global {
  namespace Express {
    interface Request {
      user?: RequestUser;
    }
  }
}

export {};
