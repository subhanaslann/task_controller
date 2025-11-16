import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
} from '../helpers/testHelpers';

const app = createApp();

describe('Authentication Integration Tests', () => {
  beforeEach(async () => {
    await setupTestDatabase();
  });

  afterEach(async () => {
    await cleanupTestDatabase();
  });

  afterAll(async () => {
    await disconnectDatabase();
  });

  describe('POST /auth/login', () => {
    it('should login successfully with valid credentials', async () => {
      const response = await request(app)
        .post('/auth/login')
        .send({ usernameOrEmail: 'john', password: 'manager123' });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('token');
      expect(response.body.user.role).toBe('TEAM_MANAGER');
      expect(response.body.user.username).toBe('john');
      expect(response.body.user).not.toHaveProperty('password');
    });

    it('should login with email instead of username', async () => {
      const response = await request(app)
        .post('/auth/login')
        .send({ usernameOrEmail: 'alice@acme.com', password: 'member123' });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('token');
      expect(response.body.user.username).toBe('alice');
    });

    it('should fail login with invalid credentials', async () => {
      const response = await request(app)
        .post('/auth/login')
        .send({ usernameOrEmail: 'john', password: 'wrongpassword' });

      expect(response.status).toBe(401);
      expect(response.body.error.code).toBe('UNAUTHORIZED');
    });

    it('should fail login with nonexistent user', async () => {
      const response = await request(app)
        .post('/auth/login')
        .send({ usernameOrEmail: 'nonexistent', password: 'test123' });

      expect(response.status).toBe(401);
      expect(response.body.error.code).toBe('UNAUTHORIZED');
    });

    it('should fail login with missing password', async () => {
      const response = await request(app)
        .post('/auth/login')
        .send({ usernameOrEmail: 'john' });

      expect(response.status).toBe(400);
      expect(response.body.error.code).toBe('VALIDATION_ERROR');
    });

    it('should fail login with missing username/email', async () => {
      const response = await request(app)
        .post('/auth/login')
        .send({ password: 'test123' });

      expect(response.status).toBe(400);
      expect(response.body.error.code).toBe('VALIDATION_ERROR');
    });
  });

  describe('GET /tasks?scope=team_active as GUEST', () => {
    it('should return trimmed fields for guest users', async () => {
      // 1. Login as guest
      const loginResponse = await request(app)
        .post('/auth/login')
        .send({ usernameOrEmail: 'charlie', password: 'guest123' });

      const token = loginResponse.body.token;

      // 2. Fetch team active tasks
      const response = await request(app)
        .get('/tasks/view?scope=team_active')
        .set('Authorization', `Bearer ${token}`);

      expect(response.status).toBe(200);

      // 3. Verify sensitive fields are omitted
      const tasks = response.body.tasks;
      expect(tasks.length).toBeGreaterThan(0);

      tasks.forEach((task: any) => {
        expect(task).toHaveProperty('id');
        expect(task).toHaveProperty('title');
        expect(task).toHaveProperty('status');
        expect(task).toHaveProperty('priority');
        expect(task).not.toHaveProperty('desc'); // Should be omitted for guest

        if (task.assignee) {
          expect(task.assignee).toHaveProperty('name');
          expect(task.assignee).not.toHaveProperty('username'); // Should be omitted
          expect(task.assignee).not.toHaveProperty('email');
        }
      });
    });

    it('should return full fields for member users', async () => {
      // 1. Login as member
      const loginResponse = await request(app)
        .post('/auth/login')
        .send({ usernameOrEmail: 'alice', password: 'member123' });

      const token = loginResponse.body.token;

      // 2. Fetch team active tasks
      const response = await request(app)
        .get('/tasks/view?scope=team_active')
        .set('Authorization', `Bearer ${token}`);

      expect(response.status).toBe(200);

      // 3. Verify all fields are present for member
      const tasks = response.body.tasks;
      expect(tasks.length).toBeGreaterThan(0);

      tasks.forEach((task: any) => {
        expect(task).toHaveProperty('id');
        expect(task).toHaveProperty('title');
        expect(task).toHaveProperty('note'); // Should be included for member
        expect(task).toHaveProperty('status');
        expect(task).toHaveProperty('priority');
      });
    });
  });

  describe('PATCH /tasks/:id/status ownership validation', () => {
    it('should forbid status change for non-assignee non-admin', async () => {
      // 1. Login as alice
      const aliceLogin = await request(app)
        .post('/auth/login')
        .send({ usernameOrEmail: 'alice', password: 'member123' });

      const token = aliceLogin.body.token;

      // 2. Get bob's task
      const tasksResponse = await request(app)
        .get('/tasks/view?scope=team_active')
        .set('Authorization', `Bearer ${token}`);

      // Find a task assigned to bob (not alice)
      const bobTask = tasksResponse.body.tasks.find(
        (t: any) => t.assignee && t.assignee.username === 'bob'
      );

      expect(bobTask).toBeDefined();

      // 3. Try to update bob's task - should fail
      const response = await request(app)
        .patch(`/tasks/${bobTask.id}/status`)
        .set('Authorization', `Bearer ${token}`)
        .send({ status: 'DONE' });

      expect(response.status).toBe(403);
      expect(response.body.error.code).toBe('FORBIDDEN');
    });

    it('should allow status change for task assignee', async () => {
      // 1. Login as alice
      const aliceLogin = await request(app)
        .post('/auth/login')
        .send({ usernameOrEmail: 'alice', password: 'member123' });

      const token = aliceLogin.body.token;

      // 2. Get alice's task
      const tasksResponse = await request(app)
        .get('/tasks/view?scope=my_active')
        .set('Authorization', `Bearer ${token}`);

      const aliceTask = tasksResponse.body.tasks[0];
      expect(aliceTask).toBeDefined();

      // 3. Update her own task - should succeed
      const response = await request(app)
        .patch(`/tasks/${aliceTask.id}/status`)
        .set('Authorization', `Bearer ${token}`)
        .send({ status: 'DONE' });

      expect(response.status).toBe(200);
      expect(response.body.task.status).toBe('DONE');
    });

    it('should allow admin to update any task status', async () => {
      // 1. Login as team manager (acts as admin for their org)
      const adminLogin = await request(app)
        .post('/auth/login')
        .send({ usernameOrEmail: 'john', password: 'manager123' });

      const token = adminLogin.body.token;

      // 2. Get any task
      const tasksResponse = await request(app)
        .get('/tasks/view?scope=team_active')
        .set('Authorization', `Bearer ${token}`);

      const anyTask = tasksResponse.body.tasks[0];
      expect(anyTask).toBeDefined();

      // 3. Update any task - should succeed
      const response = await request(app)
        .patch(`/tasks/${anyTask.id}/status`)
        .set('Authorization', `Bearer ${token}`)
        .send({ status: 'IN_PROGRESS' });

      expect(response.status).toBe(200);
      expect(response.body.task.status).toBe('IN_PROGRESS');
    });

    it('should reject invalid status transition', async () => {
      const aliceLogin = await request(app)
        .post('/auth/login')
        .send({ usernameOrEmail: 'alice', password: 'member123' });

      const token = aliceLogin.body.token;

      const tasksResponse = await request(app)
        .get('/tasks/view?scope=my_active')
        .set('Authorization', `Bearer ${token}`);

      // If alice has no tasks, skip this test scenario
      if (!tasksResponse.body.tasks || tasksResponse.body.tasks.length === 0) {
        expect(tasksResponse.body.tasks).toBeDefined();
        return; // Skip the rest if no tasks
      }

      const aliceTask = tasksResponse.body.tasks[0];

      const response = await request(app)
        .patch(`/tasks/${aliceTask.id}/status`)
        .set('Authorization', `Bearer ${token}`)
        .send({ status: 'INVALID_STATUS' });

      expect(response.status).toBe(400);
      expect(response.body.error.code).toBe('VALIDATION_ERROR');
    });
  });
});
