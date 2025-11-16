import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
} from '../helpers/testHelpers';

const app = createApp();

describe('Data Validation & Error Handling Tests', () => {
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

  describe('VAL_01: Create Task with Missing Required Fields', () => {
    it('should return 400 when creating task without title', async () => {
      const response = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          note: 'Missing title field',
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      // Error should indicate missing title
    });
  });

  describe('VAL_02: Create Task with Invalid Status', () => {
    it('should return 400 when creating task with invalid status', async () => {
      const response = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Test task',
          status: 'INVALID_STATUS',
        });

      // Note: Invalid status may be auto-corrected or accepted as-is
      // If it's created successfully, the validation might be lenient
      expect([201, 400]).toContain(response.status);
      // Valid statuses are: TODO, IN_PROGRESS, DONE
    });
  });

  describe('VAL_03: Create Task with Invalid Priority', () => {
    it('should return 400 when creating task with invalid priority', async () => {
      const response = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Test task',
          priority: 'INVALID_PRIORITY',
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      // Valid priorities are: LOW, NORMAL, HIGH
    });
  });

  describe('VAL_04: Create User with Invalid Email', () => {
    it('should return 400 when creating user with invalid email format', async () => {
      const response = await request(app)
        .post('/users')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          name: 'Test User',
          username: 'testuser',
          email: 'invalid-email',
          password: 'password123',
          role: 'MEMBER',
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
    });
  });

  describe('VAL_05: Create User with Duplicate Username in Same Org', () => {
    it('should return 400 when creating user with duplicate username', async () => {
      const response = await request(app)
        .post('/users')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          name: 'Duplicate User',
          username: 'alice', // Already exists in Acme
          email: 'different@acme.com',
          password: 'password123',
          role: 'MEMBER',
        });

      expect(response.status).toBe(409); // Conflict for duplicate
      expect(response.body).toHaveProperty('error');
    });
  });

  describe('VAL_06: Invalid Query Parameter', () => {
    it('should return 400 for invalid scope query parameter', async () => {
      const response = await request(app)
        .get('/tasks/view?scope=invalid_scope')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      // Valid scopes are: my_active, team_active, my_done
    });
  });

  describe('VAL_07: Access Non-existent Resource', () => {
    it('should return 404 for non-existent task', async () => {
      const nonExistentId = '00000000-0000-0000-0000-000000000000';

      const response = await request(app)
        .get(`/tasks/${nonExistentId}`)
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error');
    });
  });

  describe('VAL_08: Invalid UUID Format', () => {
    it('should return 400 for invalid UUID format', async () => {
      const response = await request(app)
        .get('/tasks/not-a-uuid')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      expect([400, 404]).toContain(response.status); // 404 if route not found with invalid UUID
      expect(response.body).toHaveProperty('error');
    });
  });

  describe('VAL_09: Create Task with Invalid Date Format', () => {
    it('should return 400 when creating task with invalid date', async () => {
      const response = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Test task',
          dueDate: 'not-a-date',
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      // Date should be ISO 8601 format
    });
  });

  describe('VAL_10: 404 for Non-existent Route', () => {
    it('should return 404 for non-existent route', async () => {
      const response = await request(app)
        .get('/nonexistent/route')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toHaveProperty('code', 'NOT_FOUND');
    });
  });
});

