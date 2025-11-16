import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
} from '../helpers/testHelpers';

const app = createApp();

describe('Health & Infrastructure Tests', () => {
  beforeEach(async () => {
    await setupTestDatabase();
  });

  afterEach(async () => {
    await cleanupTestDatabase();
  });

  afterAll(async () => {
    await disconnectDatabase();
  });

  describe('HEALTH_01: Health Check Endpoint', () => {
    it('should return healthy status with database connected and organization count', async () => {
      const startTime = Date.now();
      const response = await request(app).get('/health');
      const responseTime = Date.now() - startTime;

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('status', 'healthy');
      expect(response.body).toHaveProperty('database', 'connected');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body).toHaveProperty('environment', 'test');
      expect(response.body).toHaveProperty('uptime');
      expect(response.body).toHaveProperty('memory');
      expect(response.body.memory).toHaveProperty('used');
      expect(response.body.memory).toHaveProperty('total');
      expect(response.body).toHaveProperty('organizations');
      expect(response.body).toHaveProperty('activeOrganizations');

      // Validate organization counts
      expect(response.body.organizations).toBeGreaterThanOrEqual(3);
      expect(response.body.activeOrganizations).toBeGreaterThanOrEqual(3);

      // Validate response time
      expect(responseTime).toBeLessThan(500);

      // Validate timestamp is valid ISO date
      expect(() => new Date(response.body.timestamp)).not.toThrow();
    });
  });
});

