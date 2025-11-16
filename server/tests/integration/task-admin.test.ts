import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
  testData,
} from '../helpers/testHelpers';

const app = createApp();

describe('Task Management - Admin Operations Tests', () => {
  let acmeManagerToken: string;
  let acmeMemberToken: string;

  beforeEach(async () => {
    await setupTestDatabase();

    // Login users to get tokens
    const acmeManagerRes = await request(app)
      .post('/auth/login')
      .send({ usernameOrEmail: 'john@acme.com', password: 'manager123' });
    acmeManagerToken = acmeManagerRes.body.token;

    const acmeMemberRes = await request(app)
      .post('/auth/login')
      .send({ usernameOrEmail: 'alice@acme.com', password: 'member123' });
    acmeMemberToken = acmeMemberRes.body.token;

    // Tech manager token not needed in these tests
  });

  afterEach(async () => {
    await cleanupTestDatabase();
  });

  afterAll(async () => {
    await disconnectDatabase();
  });

  describe('ADMIN_TASK_01: List All Tasks (Team Manager)', () => {
    it('should return all tasks in organization regardless of status', async () => {
      const response = await request(app)
        .get('/admin/tasks')
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('tasks');
      expect(Array.isArray(response.body.tasks)).toBe(true);

      // Should include all tasks (TODO, IN_PROGRESS, DONE)
      const tasks = response.body.tasks;
      expect(tasks.length).toBe(3); // Acme has 3 tasks

      // All tasks should belong to Acme Corporation
      tasks.forEach((task: any) => {
        expect(task.organizationId).toBe(testData.organizations.acme.id);
      });

      // Should have tasks with different statuses
      const statuses = tasks.map((t: any) => t.status);
      expect(statuses).toContain('TODO');
      expect(statuses).toContain('IN_PROGRESS');
      expect(statuses).toContain('DONE');

      // No tasks from other organizations
      const techTasks = tasks.filter(
        (task: any) => task.organizationId === testData.organizations.tech.id
      );
      expect(techTasks.length).toBe(0);
    });
  });

  describe('ADMIN_TASK_02: Create Task and Assign to Other User', () => {
    it('should allow manager to create task and assign to any team member', async () => {
      const response = await request(app)
        .post('/admin/tasks')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          topicId: testData.topics.acmeBackend.id,
          title: 'Code review required',
          note: 'Review pull request #123',
          assigneeId: testData.users.aliceJohnson.id,
          status: 'TODO',
          priority: 'NORMAL',
          dueDate: '2025-11-20T00:00:00.000Z',
        });

      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('task');

      const { task } = response.body;
      expect(task.title).toBe('Code review required');
      expect(task.assigneeId).toBe(testData.users.aliceJohnson.id);
      expect(task.organizationId).toBe(testData.organizations.acme.id);
      expect(task).toHaveProperty('id');
    });
  });

  describe('ADMIN_TASK_03: Cannot Assign Task to User from Different Organization', () => {
    it('should return 400 when trying to assign task to user from different org', async () => {
      const response = await request(app)
        .post('/admin/tasks')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          title: 'Cross-org task',
          assigneeId: testData.users.sarahManager.id, // From Tech Startup
          status: 'TODO',
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      // Error should indicate assignee from different organization
    });
  });

  describe('ADMIN_TASK_04: Update Any Task in Organization', () => {
    it('should allow manager to update any task in their organization', async () => {
      // Get a task that belongs to another member
      const bobTaskId = testData.tasks.acmeTask2.id;

      const response = await request(app)
        .patch(`/admin/tasks/${bobTaskId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          title: 'Updated by manager',
          priority: 'HIGH',
          status: 'IN_PROGRESS',
        });

      expect(response.status).toBe(200);
      expect(response.body.task.title).toBe('Updated by manager');
      expect(response.body.task.priority).toBe('HIGH');
      expect(response.body.task.status).toBe('IN_PROGRESS');
    });
  });

  describe('ADMIN_TASK_05: Delete Any Task in Organization', () => {
    it('should allow manager to delete any task in their organization', async () => {
      // Get a task
      const taskToDelete = testData.tasks.acmeTask1.id;

      const response = await request(app)
        .delete(`/admin/tasks/${taskToDelete}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      expect(response.status).toBe(200);

      // Verify task is deleted
      const getRes = await request(app)
        .get('/admin/tasks')
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      const deletedTask = getRes.body.tasks.find((t: any) => t.id === taskToDelete);
      expect(deletedTask).toBeUndefined();
    });
  });

  describe('ADMIN_TASK_06: Member Cannot Access Admin Task Endpoints', () => {
    it('should return 403 when member tries to access admin task list', async () => {
      const response = await request(app)
        .get('/admin/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error');
    });
  });
});

