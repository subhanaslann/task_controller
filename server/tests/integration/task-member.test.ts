import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
  testData,
} from '../helpers/testHelpers';

const app = createApp();

describe('Task Management - Member Operations Tests', () => {
  let acmeMemberToken: string;
  let acmeGuestToken: string;
  let techManagerToken: string;

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

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('tasks');
      expect(Array.isArray(response.body.tasks)).toBe(true);

      // All tasks should be assigned to Alice and have active status
      response.body.tasks.forEach((task: any) => {
        expect(task.assigneeId).toBe(testData.users.aliceJohnson.id);
        expect(['TODO', 'IN_PROGRESS']).toContain(task.status);
        expect(task.status).not.toBe('DONE');
        expect(task.organizationId).toBe(testData.organizations.acme.id);
      });
    });
  });

  describe('TASK_02: Get Team Active Tasks', () => {
    it('should return all active tasks in organization', async () => {
      const response = await request(app)
        .get('/tasks/view?scope=team_active')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('tasks');

      // Should include tasks assigned to other members
      const tasks = response.body.tasks;
      expect(tasks.length).toBeGreaterThan(0);

      tasks.forEach((task: any) => {
        expect(['TODO', 'IN_PROGRESS']).toContain(task.status);
        expect(task.organizationId).toBe(testData.organizations.acme.id);
      });
    });
  });

  describe('TASK_03: Get Team Active Tasks (Guest - Limited Fields)', () => {
    it('should return tasks with limited fields for guest users', async () => {
      const response = await request(app)
        .get('/tasks/view?scope=team_active')
        .set('Authorization', `Bearer ${acmeGuestToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('tasks');

      const tasks = response.body.tasks;
      expect(tasks.length).toBeGreaterThan(0);

      tasks.forEach((task: any) => {
        // Guest should see limited fields
        expect(task).toHaveProperty('id');
        expect(task).toHaveProperty('title');
        expect(task).toHaveProperty('status');
        expect(task).toHaveProperty('priority');
        expect(task).toHaveProperty('dueDate');

        // Sensitive fields should be filtered out
        expect(task).not.toHaveProperty('note');

        // If assignee present, should have limited info
        if (task.assignee) {
          expect(task.assignee).toHaveProperty('name');
          expect(task.assignee).not.toHaveProperty('username');
          expect(task.assignee).not.toHaveProperty('email');
        }
      });
    });
  });

  describe('TASK_04: Get My Completed Tasks', () => {
    it('should return only completed tasks assigned to current user', async () => {
      const response = await request(app)
        .get('/tasks/view?scope=my_done')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('tasks');

      response.body.tasks.forEach((task: any) => {
        expect(task.assigneeId).toBe(testData.users.aliceJohnson.id);
        expect(task.status).toBe('DONE');
        expect(task).toHaveProperty('completedAt');
        expect(task.organizationId).toBe(testData.organizations.acme.id);
      });
    });
  });

  describe('TASK_05: Create Task as Member', () => {
    it('should create task and auto-assign to creating member', async () => {
      const response = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          topicId: testData.topics.acmeBackend.id,
          title: 'Implement user authentication',
          note: 'Add JWT-based authentication',
          status: 'TODO',
          priority: 'HIGH',
          dueDate: '2025-12-31T23:59:59.000Z',
        });

      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('task');

      const { task } = response.body;
      expect(task.title).toBe('Implement user authentication');
      expect(task.note).toBe('Add JWT-based authentication');
      expect(task.assigneeId).toBe(testData.users.aliceJohnson.id);
      expect(task.status).toBe('TODO');
      expect(task.priority).toBe('HIGH');
      expect(task.organizationId).toBe(testData.organizations.acme.id);
      expect(task.topicId).toBe(testData.topics.acmeBackend.id);
      expect(task).toHaveProperty('id');
      expect(task).toHaveProperty('createdAt');
      expect(task).toHaveProperty('updatedAt');
      expect(task.completedAt).toBeNull();
    });
  });

  describe('TASK_06: Update Task Status (Own Task)', () => {
    it('should allow member to update status of own task', async () => {
      // First create a task
      const createRes = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Test task for status update',
          status: 'TODO',
        });

      const taskId = createRes.body.task.id;

      // Update status
      const response = await request(app)
        .patch(`/tasks/${taskId}/status`)
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          status: 'IN_PROGRESS',
        });

      expect(response.status).toBe(200);
      expect(response.body.task.status).toBe('IN_PROGRESS');
      expect(response.body.task).toHaveProperty('updatedAt');
    });
  });

  describe('TASK_07: Update Task Status to DONE', () => {
    it('should set completedAt timestamp when status changed to DONE', async () => {
      // First create a task
      const createRes = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Task to complete',
          status: 'TODO',
        });

      const taskId = createRes.body.task.id;

      // Update to DONE
      const response = await request(app)
        .patch(`/tasks/${taskId}/status`)
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          status: 'DONE',
        });

      expect(response.status).toBe(200);
      expect(response.body.task.status).toBe('DONE');
      expect(response.body.task.completedAt).not.toBeNull();
      expect(() => new Date(response.body.task.completedAt)).not.toThrow();
    });
  });

  describe('TASK_08: Update Own Task (Full Update)', () => {
    it('should allow member to update own task details', async () => {
      // First create a task
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
          status: 'IN_PROGRESS',
        });

      expect(response.status).toBe(200);
      expect(response.body.task.title).toBe('Updated title');
      expect(response.body.task.note).toBe('Updated note');
      expect(response.body.task.priority).toBe('LOW');
      expect(response.body.task.status).toBe('IN_PROGRESS');
    });
  });

  describe('TASK_09: Member Cannot Update Other\'s Task', () => {
    it('should return 404 when member from different org tries to update task', async () => {
      // Alice's task
      const aliceTaskId = testData.tasks.acmeTask1.id;

      // Tech manager tries to update it
      const response = await request(app)
        .patch(`/tasks/${aliceTaskId}`)
        .set('Authorization', `Bearer ${techManagerToken}`)
        .send({
          title: 'Unauthorized update',
        });

      expect(response.status).toBe(403); // Forbidden for cross-org access
      expect(response.body).toHaveProperty('error');
    });
  });

  describe('TASK_10: Delete Own Task', () => {
    it('should allow member to delete own task', async () => {
      // First create a task
      const createRes = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Task to delete',
        });

      const taskId = createRes.body.task.id;

      // Delete task
      const response = await request(app)
        .delete(`/tasks/${taskId}`)
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      expect(response.status).toBe(200);

      // Verify task is deleted
      const getRes = await request(app)
        .get('/tasks/view?scope=my_active')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      const deletedTask = getRes.body.tasks.find((t: any) => t.id === taskId);
      expect(deletedTask).toBeUndefined();
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

      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error');
    });
  });

  describe('TASK_12: Guest Cannot Update Task', () => {
    it('should return 403 when guest tries to update task status', async () => {
      const response = await request(app)
        .patch(`/tasks/${testData.tasks.acmeTask1.id}/status`)
        .set('Authorization', `Bearer ${acmeGuestToken}`)
        .send({
          status: 'IN_PROGRESS',
        });

      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error');
    });
  });
});

