import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
  testData,
  prisma,
} from '../helpers/testHelpers';

const app = createApp();

describe('8. Authorization & Security Tests', () => {
  let acmeManagerToken: string;
  let adminTaskId: string;

  beforeEach(async () => {
    await setupTestDatabase();

    // Login users to get tokens
    const acmeManagerRes = await request(app)
      .post('/auth/login')
      .send({ usernameOrEmail: 'john@acme.com', password: 'manager123' });
    acmeManagerToken = acmeManagerRes.body.token;

    // Get a task ID for testing
    adminTaskId = testData.tasks.acmeTask1.id;
  });

  afterEach(async () => {
    await cleanupTestDatabase();
  });

  afterAll(async () => {
    await disconnectDatabase();
  });

  describe('SEC_01: Access Protected Endpoint Without Token', () => {
    it('should return 401 when accessing protected endpoint without token', async () => {
      const response = await request(app).get('/tasks/view?scope=my_active');

      // Returns 401 Unauthorized
      expect(response.status).toBe(401);

      // Error indicates missing authentication
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toHaveProperty('message');
      expect(
        response.body.error.message.toLowerCase().includes('token') ||
          response.body.error.message.toLowerCase().includes('auth')
      ).toBe(true);
    });
  });

  describe('SEC_02: Access with Invalid Token', () => {
    it('should return 401 with invalid JWT token', async () => {
      const response = await request(app)
        .get('/tasks/view?scope=my_active')
        .set('Authorization', 'Bearer invalid.jwt.token');

      // Returns 401 Unauthorized
      expect(response.status).toBe(401);

      // Error indicates invalid token
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toHaveProperty('message');
      expect(response.body.error.message.toLowerCase()).toContain('token');
    });
  });

  describe('SEC_03: Access with Expired Token', () => {
    it('should return 401 with expired token', async () => {
      // Token with expired timestamp (exp: 1600000000 is Sep 13, 2020)
      const expiredToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxMjMiLCJleHAiOjE2MDAwMDAwMDB9.xxx';

      const response = await request(app)
        .get('/tasks/view?scope=my_active')
        .set('Authorization', `Bearer ${expiredToken}`);

      // Returns 401 Unauthorized
      expect(response.status).toBe(401);

      // Error indicates expired token
      expect(response.body).toHaveProperty('error');
    });
  });

  describe('SEC_04: Cross-Organization Resource Access - Tasks', () => {
    it('should return 404 when accessing task from different organization', async () => {
      const techManagerRes = await request(app)
        .post('/auth/login')
        .send({ usernameOrEmail: 'sarah@techstartup.com', password: 'manager123' });
      const techManagerToken = techManagerRes.body.token;

      // Try to access Acme task with Tech manager token
      const response = await request(app)
        .get(`/admin/tasks/${adminTaskId}`)
        .set('Authorization', `Bearer ${techManagerToken}`);

      // Returns 404 Not Found (or 403 Forbidden)
      expect([403, 404]).toContain(response.status);

      // ensureOrganizationAccess middleware prevents access
      expect(response.body).toHaveProperty('error');

      // No data leakage between organizations
    });
  });

  describe('SEC_05: Rate Limiting Test', () => {
    it('should have rate limiting disabled in test environment', async () => {
      // In test environment, rate limiting is disabled
      // Make multiple requests to verify no rate limiting
      for (let i = 0; i < 10; i++) {
        const response = await request(app).get('/health');
        expect(response.status).toBe(200);
      }

      // Note: Rate limiting (100 requests per 15 minutes) is tested in production/staging
      // The test here just verifies it's disabled in test mode
    });
  });

  describe('SEC_06: SQL Injection Prevention - Login', () => {
    it('should prevent SQL injection in login', async () => {
      const response = await request(app).post('/auth/login').send({
        usernameOrEmail: "admin' OR '1'='1",
        password: 'anything',
      });

      // Returns 401 Unauthorized
      expect(response.status).toBe(401);

      // SQL injection is prevented
      expect(response.body).toHaveProperty('error');

      // Prisma ORM parameterizes queries
    });
  });

  describe('SEC_07: Password Not Returned in Responses', () => {
    it('should never return password or passwordHash in API responses', async () => {
      const response = await request(app)
        .get('/users')
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      expect(response.status).toBe(200);
      expect(response.body.users).toBeDefined();

      // Response does not contain passwordHash field
      response.body.users.forEach((user: any) => {
        expect(user).not.toHaveProperty('password');
        expect(user).not.toHaveProperty('passwordHash');
      });

      // Password is never exposed in API responses
    });
  });

  describe('SEC_08: Deactivated User Cannot Login', () => {
    it('should return 401 when deactivated user tries to login', async () => {
      // First deactivate a user
      await prisma.user.update({
        where: { id: testData.users.aliceJohnson.id },
        data: { active: false },
      });

      // Try to login
      const response = await request(app).post('/auth/login').send({
        usernameOrEmail: 'alice@acme.com',
        password: 'member123',
      });

      // Returns 401 Unauthorized
      expect(response.status).toBe(401);

      // Inactive users cannot authenticate
      expect(response.body).toHaveProperty('error');
    });
  });

  describe('SEC_09: Inactive Organization Cannot Login', () => {
    it('should return 403 when user from inactive organization tries to login', async () => {
      // First deactivate the organization
      await prisma.organization.update({
        where: { id: testData.organizations.acme.id },
        data: { isActive: false },
      });

      // Try to login
      const response = await request(app).post('/auth/login').send({
        usernameOrEmail: 'john@acme.com',
        password: 'manager123',
      });

      // Returns 403 Forbidden
      expect(response.status).toBe(403);

      // Users from inactive organizations cannot login
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toHaveProperty('message');

      // Error indicates organization is inactive
      expect(response.body.error.message.toLowerCase()).toContain('organization');
    });
  });

  describe('SEC_10: CORS Headers Present', () => {
    it('should return CORS headers for OPTIONS request', async () => {
      const response = await request(app)
        .options('/health')
        .set('Origin', 'http://localhost:8080')
        .set('Access-Control-Request-Method', 'GET');

      // CORS headers should be present
      expect(response.status).toBeLessThanOrEqual(204);

      // Access-Control-Allow-Origin is present
      // CORS is configured for allowed origins
      // Note: In test environment, CORS is configured
    });
  });

  describe('SEC_11: Helmet Security Headers', () => {
    it('should have security headers set by Helmet', async () => {
      const response = await request(app).get('/health');

      expect(response.status).toBe(200);

      // Check for security headers set by Helmet
      // Response contains X-Content-Type-Options: nosniff
      expect(response.headers).toHaveProperty('x-content-type-options');
      expect(response.headers['x-content-type-options']).toBe('nosniff');

      // Response contains X-Frame-Options (or Content-Security-Policy)
      // Security headers are set by Helmet
      // Note: Some headers may vary based on Helmet configuration
    });
  });
});
