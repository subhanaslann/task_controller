import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
} from '../helpers/testHelpers';

const app = createApp();

describe('1. Health & Infrastructure Tests', () => {
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
    it('should return server health status with database connectivity', async () => {
      const startTime = Date.now();

      const response = await request(app).get('/health');

      const responseTime = Date.now() - startTime;

      // Expected status
      expect(response.status).toBe(200);

      // Validate response structure
      expect(response.body).toHaveProperty('status', 'healthy');
      expect(response.body).toHaveProperty('database', 'connected');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body).toHaveProperty('environment');
      expect(response.body).toHaveProperty('uptime');

      // Memory information
      expect(response.body).toHaveProperty('memory');
      expect(response.body.memory).toHaveProperty('used');
      expect(response.body.memory).toHaveProperty('total');
      expect(typeof response.body.memory.used).toBe('number');
      expect(typeof response.body.memory.total).toBe('number');

      // Organization counts
      expect(response.body).toHaveProperty('organizations');
      expect(response.body).toHaveProperty('activeOrganizations');
      expect(typeof response.body.organizations).toBe('number');
      expect(typeof response.body.activeOrganizations).toBe('number');

      // Validation rules
      // Organizations count is >= 3 (from seed data)
      expect(response.body.organizations).toBeGreaterThanOrEqual(3);

      // Response time < 500ms
      expect(responseTime).toBeLessThan(500);

      // Timestamp should be valid ISO date
      expect(() => new Date(response.body.timestamp)).not.toThrow();

      // Database should show 'connected'
      expect(response.body.database).toBe('connected');
    });
  });
});
