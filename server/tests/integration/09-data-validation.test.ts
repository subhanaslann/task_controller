import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
} from '../helpers/testHelpers';

const app = createApp();

describe('9. Data Validation & Error Handling Tests', () => {
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
    it('should return 400 when title is missing', async () => {
      const response = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          note: 'Missing title field',
        });

      // Returns 400 Bad Request
      expect(response.status).toBe(400);

      // Error message indicates missing title
      expect(response.body).toHaveProperty('error');
      expect(response.body.error.toLowerCase()).toContain('title');

      // Zod validation is working
    });
  });

  describe('VAL_02: Create Task with Invalid Status', () => {
    it('should return 400 when status is invalid', async () => {
      const response = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Test task',
          status: 'INVALID_STATUS',
        });

      // Returns 400 Bad Request
      expect(response.status).toBe(400);

      // Error indicates invalid status value
      expect(response.body).toHaveProperty('error');
      expect(
        response.body.error.includes('TODO') ||
          response.body.error.includes('IN_PROGRESS') ||
          response.body.error.includes('DONE') ||
          response.body.error.toLowerCase().includes('status')
      ).toBe(true);

      // Valid statuses are: TODO, IN_PROGRESS, DONE
    });
  });

  describe('VAL_03: Create Task with Invalid Priority', () => {
    it('should return 400 when priority is invalid', async () => {
      const response = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Test task',
          priority: 'INVALID_PRIORITY',
        });

      // Returns 400 Bad Request
      expect(response.status).toBe(400);

      // Error indicates invalid priority value
      expect(response.body).toHaveProperty('error');
      expect(
        response.body.error.includes('LOW') ||
          response.body.error.includes('NORMAL') ||
          response.body.error.includes('HIGH') ||
          response.body.error.toLowerCase().includes('priority')
      ).toBe(true);

      // Valid priorities are: LOW, NORMAL, HIGH
    });
  });

  describe('VAL_04: Create User with Invalid Email', () => {
    it('should return 400 when email format is invalid', async () => {
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

      // Returns 400 Bad Request
      expect(response.status).toBe(400);

      // Error indicates invalid email format
      expect(response.body).toHaveProperty('error');
      expect(response.body.error.toLowerCase()).toContain('email');
    });
  });

  describe('VAL_05: Create User with Duplicate Username in Same Org', () => {
    it('should return 400 when username already exists in organization', async () => {
      const response = await request(app)
        .post('/users')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          name: 'Duplicate User',
          username: 'alice', // Already exists
          email: 'different@acme.com',
          password: 'password123',
          role: 'MEMBER',
        });

      // Returns 400 Bad Request
      expect(response.status).toBe(400);

      // Error indicates username already exists in organization
      expect(response.body).toHaveProperty('error');
      expect(
        response.body.error.toLowerCase().includes('username') ||
          response.body.error.toLowerCase().includes('already') ||
          response.body.error.toLowerCase().includes('exists') ||
          response.body.error.toLowerCase().includes('unique')
      ).toBe(true);
    });
  });

  describe('VAL_06: Invalid Query Parameter', () => {
    it('should return 400 for invalid scope parameter', async () => {
      const response = await request(app)
        .get('/tasks/view?scope=invalid_scope')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      // Returns 400 Bad Request
      expect(response.status).toBe(400);

      // Error indicates invalid scope parameter
      expect(response.body).toHaveProperty('error');
      expect(
        response.body.error.toLowerCase().includes('scope') ||
          response.body.error.includes('my_active') ||
          response.body.error.includes('team_active') ||
          response.body.error.includes('my_done')
      ).toBe(true);

      // Valid scopes are: my_active, team_active, my_done
    });
  });

  describe('VAL_07: Access Non-existent Resource', () => {
    it('should return 404 for non-existent task ID', async () => {
      const response = await request(app)
        .get('/tasks/00000000-0000-0000-0000-000000000000')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      // Returns 404 Not Found
      expect(response.status).toBe(404);

      // Error message is clear and informative
      expect(response.body).toHaveProperty('error');
      expect(
        response.body.error.toLowerCase().includes('not found') ||
          response.body.error.toLowerCase().includes('task')
      ).toBe(true);
    });
  });

  describe('VAL_08: Invalid UUID Format', () => {
    it('should return 400 for invalid UUID format', async () => {
      const response = await request(app)
        .get('/tasks/not-a-uuid')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      // Returns 400 Bad Request
      expect(response.status).toBe(400);

      // Error indicates invalid UUID format
      expect(response.body).toHaveProperty('error');
      expect(
        response.body.error.toLowerCase().includes('uuid') ||
          response.body.error.toLowerCase().includes('invalid') ||
          response.body.error.toLowerCase().includes('id')
      ).toBe(true);
    });
  });

  describe('VAL_09: Create Task with Invalid Date Format', () => {
    it('should return 400 when date format is invalid', async () => {
      const response = await request(app)
        .post('/tasks')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Test task',
          dueDate: 'not-a-date',
        });

      // Returns 400 Bad Request
      expect(response.status).toBe(400);

      // Error indicates invalid date format
      expect(response.body).toHaveProperty('error');
      expect(
        response.body.error.toLowerCase().includes('date') ||
          response.body.error.toLowerCase().includes('invalid')
      ).toBe(true);

      // Date should be ISO 8601 format
    });
  });

  describe('VAL_10: 404 for Non-existent Route', () => {
    it('should return 404 for non-existent route', async () => {
      const response = await request(app)
        .get('/nonexistent/route')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      // Returns 404 Not Found
      expect(response.status).toBe(404);

      // Error message indicates route not found
      expect(response.body).toHaveProperty('error');
    });
  });
});
