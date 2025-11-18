import { Role } from '../../../src/types';

/**
 * Helper function to create a mock user object
 */
export const createMockUser = (overrides?: any) => ({
  id: 'user-123',
  organizationId: 'org-123',
  name: 'Test User',
  username: 'testuser',
  email: 'test@example.com',
  passwordHash: '$2b$10$abcdefghijklmnopqrstuvwxyz',
  role: Role.MEMBER,
  active: true,
  createdAt: new Date('2024-01-01'),
  updatedAt: new Date('2024-01-01'),
  ...overrides,
});

/**
 * Helper function to create a mock organization object
 */
export const createMockOrganization = (overrides?: any) => ({
  id: 'org-123',
  name: 'Test Company',
  teamName: 'Test Team',
  slug: 'test-company-test-team',
  isActive: true,
  maxUsers: 15,
  createdAt: new Date('2024-01-01'),
  updatedAt: new Date('2024-01-01'),
  ...overrides,
});

/**
 * Helper function to create a mock task object
 */
export const createMockTask = (overrides?: any) => ({
  id: 'task-123',
  organizationId: 'org-123',
  topicId: 'topic-123',
  title: 'Test Task',
  note: 'Test note',
  assigneeId: 'user-123',
  status: 'TODO',
  priority: 'NORMAL',
  dueDate: new Date('2024-12-31'),
  completedAt: null,
  createdAt: new Date('2024-01-01'),
  updatedAt: new Date('2024-01-01'),
  ...overrides,
});

/**
 * Helper function to create a mock topic object
 */
export const createMockTopic = (overrides?: any) => ({
  id: 'topic-123',
  organizationId: 'org-123',
  title: 'Test Topic',
  description: 'Test description',
  isActive: true,
  createdAt: new Date('2024-01-01'),
  updatedAt: new Date('2024-01-01'),
  ...overrides,
});

/**
 * Helper function to create a mock JWT payload
 */
export const createMockJwtPayload = (overrides?: any) => ({
  userId: 'user-123',
  organizationId: 'org-123',
  role: Role.MEMBER,
  email: 'test@example.com',
  ...overrides,
});

/**
 * Helper function to create a mock Express request
 */
export const createMockRequest = (overrides?: any) => {
  const req: any = {
    headers: {},
    params: {},
    query: {},
    body: {},
    user: undefined,
    get: jest.fn((headerName: string) => {
      return req.headers[headerName.toLowerCase()];
    }),
    connection: {
      remoteAddress: '127.0.0.1',
    },
    ip: '127.0.0.1',
    method: 'GET',
    url: '/',
    ...overrides,
  };
  return req;
};

/**
 * Helper function to create a mock Express response
 */
export const createMockResponse = () => {
  const eventListeners: { [key: string]: Function[] } = {};

  const res: any = {
    status: jest.fn().mockReturnThis(),
    json: jest.fn().mockReturnThis(),
    send: jest.fn().mockReturnThis(),
    statusCode: 200,
    headersSent: false,
    on: jest.fn((event: string, callback: Function) => {
      if (!eventListeners[event]) {
        eventListeners[event] = [];
      }
      eventListeners[event].push(callback);
      return res;
    }),
    getHeader: jest.fn(),
    setHeader: jest.fn(),
  };
  return res;
};

/**
 * Helper function to create a mock Express next function
 */
export const createMockNext = () => jest.fn();

/**
 * Helper to assert that an error was thrown
 */
export const expectToThrow = async (fn: () => Promise<any>, errorClass: any, message?: string) => {
  await expect(fn()).rejects.toThrow(errorClass);
  if (message) {
    await expect(fn()).rejects.toThrow(message);
  }
};
