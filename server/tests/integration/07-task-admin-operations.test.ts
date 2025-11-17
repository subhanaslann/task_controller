import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
  testData,
} from '../helpers/testHelpers';

const app = createApp();

describe('7. Task Management - Admin Operations Tests', () => {
  let acmeManagerToken: string;
  let acmeMemberToken: string;
  let acmeMemberId: string;
  // @ts-expect-error - This variable will be used in future tests
  let techManagerToken: string;
  // @ts-expect-error - This variable will be used in future tests
  let adminTaskId: string;
  let acmeTopicId: string;

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
    acmeMemberId = acmeMemberRes.body.user.id;

    const techManagerRes = await request(app)
      .post('/auth/login')
      .send({ usernameOrEmail: 'sarah@techstartup.com', password: 'manager123' });
    techManagerToken = techManagerRes.body.token;

    // Get topic and task IDs
    acmeTopicId = testData.topics.acmeBackend.id;
  });

  afterEach(async () => {
    await cleanupTestDatabase();
  });

  afterAll(async () => {
    await disconnectDatabase();
  });

  describe('ADMIN_TASK_01: List All Tasks (Team Manager)', () => {
    it('should return all tasks in organization for team manager', async () => {
      const response = await request(app)
        .get('/admin/tasks')
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      // Expected status
      expect(response.status).toBe(200);

      // Returns all tasks in organization
      expect(response.body).toHaveProperty('tasks');
      expect(Array.isArray(response.body.tasks)).toBe(true);

      const { tasks } = response.body;

      // Includes tasks with all statuses (TODO, IN_PROGRESS, DONE)
      // All tasks belong to manager's organization
      tasks.forEach((task: any) => {
        expect(task.organizationId).toBe(testData.organizations.acme.id);
      });

      // No tasks from other organizations
      const hasOtherOrgTasks = tasks.some(
        (task: any) => task.organizationId !== testData.organizations.acme.id
      );
      expect(hasOtherOrgTasks).toBe(false);
    });
  });

  describe('ADMIN_TASK_02: Create Task and Assign to Other User', () => {
    it('should allow team manager to create task assigned to team member', async () => {
      const response = await request(app)
        .post('/admin/tasks')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          topicId: acmeTopicId,
          title: 'Code review required',
          note: 'Review pull request #123',
          assigneeId: acmeMemberId,
          status: 'TODO',
          priority: 'NORMAL',
          dueDate: '2025-11-20T00:00:00.000Z',
        });

      // Expected status
      expect(response.status).toBe(201);

      // Task is created successfully
      expect(response.body).toHaveProperty('task');
      const { task } = response.body;

      expect(task.id).toBeDefined();
      expect(task.title).toBe('Code review required');
      expect(task.note).toBe('Review pull request #123');

      // Task is assigned to specified user
      expect(task.assigneeId).toBe(acmeMemberId);

      // Assignee belongs to same organization
      expect(task.organizationId).toBe(testData.organizations.acme.id);

      // Manager can assign tasks to team members
      // Save for subsequent tests
      adminTaskId = task.id;
    });
  });

  describe('ADMIN_TASK_03: Cannot Assign Task to User from Different Organization', () => {
    it('should return 400 when trying to assign task to user from different org', async () => {
      // Get a user ID from Tech Startup
      const techUserRes = await request(app)
        .post('/auth/login')
        .send({ usernameOrEmail: 'sarah@techstartup.com', password: 'manager123' });
      const techUserId = techUserRes.body.user.id;

      const response = await request(app)
        .post('/admin/tasks')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          title: 'Cross-org task',
          assigneeId: techUserId,
          status: 'TODO',
        });

      // Returns 400 Bad Request
      expect(response.status).toBe(400);

      // Error indicates assignee from different organization
      expect(response.body).toHaveProperty('error');
      expect(
        response.body.error.toLowerCase().includes('organization') ||
          response.body.error.toLowerCase().includes('assignee')
      ).toBe(true);

      // Cannot assign tasks across organizations
    });
  });

  describe('ADMIN_TASK_04: Update Any Task in Organization', () => {
    it('should allow manager to update any task in organization', async () => {
      // Create a task first
      const createRes = await request(app)
        .post('/admin/tasks')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          title: 'Original task',
          assigneeId: acmeMemberId,
          status: 'TODO',
        });

      const taskId = createRes.body.task.id;

      // Update the task
      const response = await request(app)
        .patch(`/admin/tasks/${taskId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          title: 'Updated by manager',
          priority: 'HIGH',
          status: 'IN_PROGRESS',
        });

      // Expected status
      expect(response.status).toBe(200);

      // Task is updated successfully
      expect(response.body.task.title).toBe('Updated by manager');
      expect(response.body.task.priority).toBe('HIGH');
      expect(response.body.task.status).toBe('IN_PROGRESS');

      // Manager can update any task in organization
    });
  });

  describe('ADMIN_TASK_05: Delete Any Task in Organization', () => {
    it('should allow manager to delete any task in organization', async () => {
      // Create a task first
      const createRes = await request(app)
        .post('/admin/tasks')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          title: 'Task to delete',
          assigneeId: acmeMemberId,
        });

      const taskId = createRes.body.task.id;

      // Delete the task
      const response = await request(app)
        .delete(`/admin/tasks/${taskId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      // Expected status
      expect(response.status).toBe(200);

      // Task is deleted successfully
      expect(response.body).toHaveProperty('message');

      // Manager can delete any task in organization
    });
  });

  describe('ADMIN_TASK_06: Member Cannot Access Admin Task Endpoints', () => {
    it('should return 403 when member tries to access admin endpoints', async () => {
      const response = await request(app)
        .get('/admin/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      // Returns 403 Forbidden
      expect(response.status).toBe(403);

      // Members cannot access admin endpoints
      expect(response.body).toHaveProperty('error');
      expect(response.body.error.toLowerCase()).toContain('forbidden');
    });
  });
});
