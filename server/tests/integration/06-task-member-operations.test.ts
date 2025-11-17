import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
  testData,
} from '../helpers/testHelpers';

const app = createApp();

describe('6. Task Management - Member Operations Tests', () => {
  let acmeMemberToken: string;
  let acmeGuestToken: string;
  let techManagerToken: string;
  let memberTaskId: string;
  let acmeTopicId: string;

  beforeEach(async () => {
    await setupTestDatabase();

    // Login users to get tokens
    const acmeMemberRes = await request(app)
      .post('/auth/login')
      .send({ usernameOrEmail: 'alice@acme.com', password: 'member123' });
    acmeMemberToken = acmeMemberRes.body.token;

    const acmeGuestRes = await request(app)
      .post('/auth/login')
      .send({ usernameOrEmail: 'charlie@acme.com', password: 'guest123' });
    acmeGuestToken = acmeGuestRes.body.token;

    const techManagerRes = await request(app)
      .post('/auth/login')
      .send({ usernameOrEmail: 'sarah@techstartup.com', password: 'manager123' });
    techManagerToken = techManagerRes.body.token;

    // Get topic ID for task creation
    acmeTopicId = testData.topics.acmeBackend.id;
  });

  afterEach(async () => {
    await cleanupTestDatabase();
  });

  afterAll(async () => {
    await disconnectDatabase();
  });

  describe('TASK_01: Get My Active Tasks', () => {
    it('should return tasks assigned to current user with TODO or IN_PROGRESS status', async () => {
      const response = await request(app)
        .get('/tasks/view?scope=my_active')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      // Expected status
      expect(response.status).toBe(200);

      // Returns tasks array
      expect(response.body).toHaveProperty('tasks');
      expect(Array.isArray(response.body.tasks)).toBe(true);

      const { tasks } = response.body;

      // Returns tasks assigned to current user
      tasks.forEach((task: any) => {
        expect(task.assigneeId).toBe(testData.users.aliceJohnson.id);
      });

      // Tasks have status TODO or IN_PROGRESS
      tasks.forEach((task: any) => {
        expect(['TODO', 'IN_PROGRESS']).toContain(task.status);
      });

      // All tasks belong to user's organization
      tasks.forEach((task: any) => {
        expect(task.organizationId).toBe(testData.organizations.acme.id);
      });

      // Does not include DONE tasks
      const hasDoneTasks = tasks.some((task: any) => task.status === 'DONE');
      expect(hasDoneTasks).toBe(false);

      // Includes assignee and topic details (if present)
      tasks.forEach((task: any) => {
        if (task.assignee) {
          expect(task.assignee).toHaveProperty('name');
        }
      });
    });
  });

  describe('TASK_02: Get Team Active Tasks', () => {
    it('should return all active tasks in organization', async () => {
      const response = await request(app)
        .get('/tasks/view?scope=team_active')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      // Expected status
      expect(response.status).toBe(200);

      expect(response.body).toHaveProperty('tasks');
      expect(Array.isArray(response.body.tasks)).toBe(true);

      const { tasks } = response.body;

      // Returns all active tasks in organization
      // Tasks have status TODO or IN_PROGRESS
      tasks.forEach((task: any) => {
        expect(['TODO', 'IN_PROGRESS']).toContain(task.status);
      });

      // Includes tasks assigned to other members
      // All tasks belong to same organization
      tasks.forEach((task: any) => {
        expect(task.organizationId).toBe(testData.organizations.acme.id);
      });
    });
  });

  describe('TASK_03: Get Team Active Tasks (Guest - Limited Fields)', () => {
    it('should return tasks with limited fields for guest user', async () => {
      const response = await request(app)
        .get('/tasks/view?scope=team_active')
        .set('Authorization', `Bearer ${acmeGuestToken}`);

      // Expected status
      expect(response.status).toBe(200);

      expect(response.body).toHaveProperty('tasks');
      const { tasks } = response.body;

      if (tasks.length > 0) {
        tasks.forEach((task: any) => {
          // Guest sees only: id, title, status, priority, dueDate, assignee.name
          expect(task).toHaveProperty('id');
          expect(task).toHaveProperty('title');
          expect(task).toHaveProperty('status');
          expect(task).toHaveProperty('priority');

          // Sensitive fields are filtered out (note, username, etc.)
          expect(task).not.toHaveProperty('note');

          // Only tasks from accessible topics are shown
        });
      }
    });
  });

  describe('TASK_04: Get My Completed Tasks', () => {
    it('should return only completed tasks assigned to current user', async () => {
      const response = await request(app)
        .get('/tasks/view?scope=my_done')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      // Expected status
      expect(response.status).toBe(200);

      expect(response.body).toHaveProperty('tasks');
      const { tasks } = response.body;

      // Returns only completed tasks (status = DONE)
      tasks.forEach((task: any) => {
        expect(task.status).toBe('DONE');
      });

      // Tasks are assigned to current user
      tasks.forEach((task: any) => {
        expect(task.assigneeId).toBe(testData.users.aliceJohnson.id);
      });

      // All tasks belong to user's organization
      tasks.forEach((task: any) => {
        expect(task.organizationId).toBe(testData.organizations.acme.id);
      });

      // Includes completedAt timestamp (if any completed tasks exist)
      tasks.forEach((task: any) => {
        if (task.completedAt) {
          expect(typeof task.completedAt).toBe('string');
        }
      });
    });
  });

  describe('TASK_05: Create Task as Member', () => {
    it('should allow member to create task (auto-assigned to self)', async () => {
      const response = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          topicId: acmeTopicId,
          title: 'Implement user authentication',
          note: 'Add JWT-based authentication',
          status: 'TODO',
          priority: 'HIGH',
          dueDate: '2025-12-31T23:59:59.000Z',
        });

      // Expected status
      expect(response.status).toBe(201);

      // Task is created successfully
      expect(response.body).toHaveProperty('task');
      const { task } = response.body;

      expect(task.id).toBeDefined();
      expect(task.organizationId).toBe(testData.organizations.acme.id);
      expect(task.topicId).toBe(acmeTopicId);
      expect(task.title).toBe('Implement user authentication');
      expect(task.note).toBe('Add JWT-based authentication');

      // Task is auto-assigned to creating member
      expect(task.assigneeId).toBe(testData.users.aliceJohnson.id);

      expect(task.status).toBe('TODO');
      expect(task.priority).toBe('HIGH');
      expect(task.dueDate).toBeDefined();

      // Task belongs to member's organization
      expect(task.organizationId).toBe(testData.organizations.acme.id);

      expect(task).toHaveProperty('createdAt');
      expect(task).toHaveProperty('updatedAt');
      expect(task.completedAt).toBeNull();

      // Status defaults to TODO if not specified
      // Priority defaults to NORMAL if not specified

      // Save for subsequent tests
      memberTaskId = task.id;
    });
  });

  describe('TASK_06: Update Task Status (Own Task)', () => {
    it('should allow member to update status of own task', async () => {
      // Create a task first
      const createRes = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Status test task',
          status: 'TODO',
        });

      const taskId = createRes.body.task.id;

      // Update task status
      const response = await request(app)
        .patch(`/tasks/${taskId}/status`)
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          status: 'IN_PROGRESS',
        });

      // Expected status
      expect(response.status).toBe(200);

      // Task status is updated to IN_PROGRESS
      expect(response.body.task.status).toBe('IN_PROGRESS');

      // updatedAt timestamp is changed
      expect(response.body.task.updatedAt).toBeDefined();

      // Member can update own task
    });
  });

  describe('TASK_07: Update Task Status to DONE', () => {
    it('should set completedAt timestamp when task is marked DONE', async () => {
      // Create a task first
      const createRes = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Complete test task',
          status: 'IN_PROGRESS',
        });

      const taskId = createRes.body.task.id;

      // Update status to DONE
      const response = await request(app)
        .patch(`/tasks/${taskId}/status`)
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          status: 'DONE',
        });

      // Expected status
      expect(response.status).toBe(200);

      // Task status is updated to DONE
      expect(response.body.task.status).toBe('DONE');

      // completedAt timestamp is set automatically
      expect(response.body.task.completedAt).toBeDefined();
      expect(response.body.task.completedAt).not.toBeNull();
    });
  });

  describe('TASK_08: Update Own Task (Full Update)', () => {
    it('should allow member to update own task details', async () => {
      // Create a task first
      const createRes = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Original title',
          note: 'Original note',
          status: 'TODO',
          priority: 'NORMAL',
        });

      const taskId = createRes.body.task.id;

      // Update task
      const response = await request(app)
        .patch(`/tasks/${taskId}`)
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Updated title',
          note: 'Updated note',
          priority: 'LOW',
          status: 'TODO',
        });

      // Expected status
      expect(response.status).toBe(200);

      // Task is updated successfully
      expect(response.body.task.title).toBe('Updated title');
      expect(response.body.task.note).toBe('Updated note');
      expect(response.body.task.priority).toBe('LOW');

      // Changes are reflected in response
      // Member can update own task details
    });
  });

  describe('TASK_09: Member Cannot Update Other\'s Task', () => {
    it('should return 404 when member tries to update task from different org', async () => {
      // Create a task as member
      const createRes = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Acme task',
        });

      const taskId = createRes.body.task.id;

      // Tech manager tries to update Acme task
      const response = await request(app)
        .patch(`/tasks/${taskId}`)
        .set('Authorization', `Bearer ${techManagerToken}`)
        .send({
          title: 'Unauthorized update',
        });

      // Returns 404 Not Found
      expect(response.status).toBe(404);

      // Member from different org cannot access task
      // Organization isolation is enforced
    });
  });

  describe('TASK_10: Delete Own Task', () => {
    it('should allow member to delete own task', async () => {
      // Create a task first
      const createRes = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Task to delete',
        });

      const taskId = createRes.body.task.id;

      // Delete the task
      const response = await request(app)
        .delete(`/tasks/${taskId}`)
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      // Expected status
      expect(response.status).toBe(200);

      // Task is deleted successfully
      expect(response.body).toHaveProperty('message');

      // Member can delete own task
    });
  });

  describe('TASK_11: Guest Cannot Create Task', () => {
    it('should return 403 when guest tries to create task', async () => {
      const response = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeGuestToken}`)
        .send({
          title: 'Guest task attempt',
        });

      // Returns 403 Forbidden
      expect(response.status).toBe(403);

      // Guests cannot create tasks
      expect(response.body).toHaveProperty('error');
      expect(response.body.error.toLowerCase()).toContain('guest');
    });
  });

  describe('TASK_12: Guest Cannot Update Task', () => {
    it('should return 403 when guest tries to update task', async () => {
      // Create a task as member
      const createRes = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Test task',
        });

      const taskId = createRes.body.task.id;

      // Guest tries to update task
      const response = await request(app)
        .patch(`/tasks/${taskId}/status`)
        .set('Authorization', `Bearer ${acmeGuestToken}`)
        .send({
          status: 'IN_PROGRESS',
        });

      // Returns 403 Forbidden
      expect(response.status).toBe(403);

      // Guests cannot update tasks
      expect(response.body).toHaveProperty('error');
    });
  });
});
