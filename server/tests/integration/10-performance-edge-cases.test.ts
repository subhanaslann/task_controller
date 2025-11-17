import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
  testData,
} from '../helpers/testHelpers';

const app = createApp();

describe('10. Performance & Edge Cases Tests', () => {
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
  });

  afterEach(async () => {
    await cleanupTestDatabase();
  });

  afterAll(async () => {
    await disconnectDatabase();
  });

  describe('PERF_01: Large Task List Performance', () => {
    it('should respond quickly with database query optimization', async () => {
      const startTime = Date.now();

      const response = await request(app)
        .get('/admin/tasks')
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      const responseTime = Date.now() - startTime;

      expect(response.status).toBe(200);

      // Response time < 1000ms
      expect(responseTime).toBeLessThan(1000);

      // Database queries are optimized
      // Includes related data (topics, assignees) efficiently
      if (response.body.tasks.length > 0) {
        const task = response.body.tasks[0];
        if (task.assignee) {
          expect(task.assignee).toHaveProperty('name');
        }
        if (task.topic) {
          expect(task.topic).toHaveProperty('title');
        }
      }
    });
  });

  describe('PERF_02: Concurrent Requests Test', () => {
    it('should handle 10 concurrent requests without issues', async () => {
      // Send 10 concurrent requests to test race conditions
      const promises = Array(10)
        .fill(null)
        .map(() =>
          request(app)
            .get('/tasks/view?scope=my_active')
            .set('Authorization', `Bearer ${acmeMemberToken}`)
        );

      const responses = await Promise.all(promises);

      // All requests should succeed
      responses.forEach((response) => {
        expect(response.status).toBe(200);
        expect(response.body).toHaveProperty('tasks');
      });

      // No database locking issues
      // Responses are consistent
      const firstResponse = responses[0].body.tasks;
      responses.forEach((response) => {
        expect(response.body.tasks.length).toBe(firstResponse.length);
      });
    });
  });

  describe('EDGE_01: Create Task with Minimal Data', () => {
    it('should create task with only required fields and use defaults', async () => {
      const response = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Minimal task',
        });

      // Expected status
      expect(response.status).toBe(201);

      // Task is created with only title
      expect(response.body.task.title).toBe('Minimal task');

      // Optional fields have default values
      // status defaults to TODO
      expect(response.body.task.status).toBe('TODO');

      // priority defaults to NORMAL
      expect(response.body.task.priority).toBe('NORMAL');

      // Auto-assigned to creating member
      expect(response.body.task.assigneeId).toBe(testData.users.aliceJohnson.id);
    });
  });

  describe('EDGE_02: Create Task with Very Long Title', () => {
    it('should handle very long title appropriately', async () => {
      const longTitle = 'A'.repeat(500);

      const response = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: longTitle,
        });

      // Either accepts long title or returns validation error (both are valid)
      expect([200, 201, 400]).toContain(response.status);

      // No server crash or unhandled error
      expect(response.body).toBeDefined();
    });
  });

  describe('EDGE_03: Update Task with Empty String', () => {
    it('should return 400 when updating task with empty title', async () => {
      // First create a task
      const createRes = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Original title',
        });

      const taskId = createRes.body.task.id;

      // Try to update with empty title
      const response = await request(app)
        .patch(`/tasks/${taskId}`)
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: '',
        });

      // Returns 400 Bad Request
      expect(response.status).toBe(400);

      // Title cannot be empty string
      expect(response.body).toHaveProperty('error');
    });
  });

  describe('EDGE_04: Create Task without Topic', () => {
    it('should create task successfully without topic (topicId null)', async () => {
      const response = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Uncategorized task',
        });

      // Expected status
      expect(response.status).toBe(201);

      expect(response.body.task.title).toBe('Uncategorized task');

      // topicId is null or undefined
      expect([null, undefined]).toContain(response.body.task.topicId);

      // Task can exist without topic
    });
  });

  describe('EDGE_05: Task Status Transition Validation', () => {
    it('should allow flexible status transitions (e.g., IN_PROGRESS back to TODO)', async () => {
      // Create a task with IN_PROGRESS status
      const createRes = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Status transition test',
          status: 'IN_PROGRESS',
        });

      const taskId = createRes.body.task.id;

      // Transition back to TODO (should be allowed)
      const response = await request(app)
        .patch(`/tasks/${taskId}/status`)
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          status: 'TODO',
        });

      // Expected status
      expect(response.status).toBe(200);

      // Can transition from any status to TODO
      expect(response.body.task.status).toBe('TODO');

      // Status updates are flexible
    });
  });
});
