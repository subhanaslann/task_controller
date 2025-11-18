import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
} from '../helpers/testHelpers';

const app = createApp();

describe('3. Organization Management Tests', () => {
  let acmeManagerToken: string;
  let acmeMemberToken: string;
  let techManagerToken: string;

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

  describe('ORG_01: Get Current Organization', () => {
    it('should return authenticated user\'s organization', async () => {
      const response = await request(app)
        .get('/organization')
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      // Expected status
      expect(response.status).toBe(200);

      // Response structure
      expect(response.body).toHaveProperty('message');
      expect(response.body.message).toContain('retrieved successfully');

      expect(response.body).toHaveProperty('data');
      const { data } = response.body;

      // Returns authenticated user's organization
      expect(data.id).toBeDefined();
      expect(data.name).toBe('Acme Corporation');
      expect(data.teamName).toBe('Engineering Team');
      expect(data.slug).toBe('acme-engineering');
      expect(data.isActive).toBe(true);
      expect(data.maxUsers).toBe(15);

      // All organization fields are present
      expect(data).toHaveProperty('createdAt');
      expect(data).toHaveProperty('updatedAt');
    });
  });

  describe('ORG_02: Update Organization (Team Manager)', () => {
    it('should allow team manager to update organization', async () => {
      const response = await request(app)
        .patch('/organization')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          name: 'Acme Corporation Updated',
          teamName: 'Engineering Team v2',
          maxUsers: 20,
        });

      // Expected status
      expect(response.status).toBe(200);

      expect(response.body).toHaveProperty('message');

      // Response contains updated organization
      const { data } = response.body;
      expect(data).toBeDefined();

      // Organization name is updated
      expect(data.name).toBe('Acme Corporation Updated');

      // Team name is updated
      expect(data.teamName).toBe('Engineering Team v2');

      // maxUsers is updated to 20
      expect(data.maxUsers).toBe(20);
    });
  });

  describe('ORG_03: Update Organization (Member - Should Fail)', () => {
    it('should return 403 when member tries to update organization', async () => {
      const response = await request(app)
        .patch('/organization')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          name: 'Unauthorized Update',
        });

      // Returns 403 Forbidden
      expect(response.status).toBe(403);

      // Member cannot update organization
      expect(response.body).toHaveProperty('error');
      expect(response.body.error.message.toLowerCase()).toContain('forbidden');
    });
  });

  describe('ORG_04: Get Organization Statistics', () => {
    it('should return organization statistics', async () => {
      const response = await request(app)
        .get('/organization/stats')
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      // Expected status
      expect(response.status).toBe(200);

      // Response structure
      expect(response.body).toHaveProperty('message');
      expect(response.body.message).toContain('statistics retrieved successfully');

      expect(response.body).toHaveProperty('data');
      const { data } = response.body;

      // All counts are present and are numbers
      expect(data).toHaveProperty('userCount');
      expect(data).toHaveProperty('activeUserCount');
      expect(data).toHaveProperty('taskCount');
      expect(data).toHaveProperty('activeTaskCount');
      expect(data).toHaveProperty('completedTaskCount');
      expect(data).toHaveProperty('topicCount');
      expect(data).toHaveProperty('activeTopicCount');

      // All counts are non-negative numbers
      expect(typeof data.userCount).toBe('number');
      expect(typeof data.activeUserCount).toBe('number');
      expect(typeof data.taskCount).toBe('number');
      expect(typeof data.activeTaskCount).toBe('number');
      expect(typeof data.completedTaskCount).toBe('number');
      expect(typeof data.topicCount).toBe('number');
      expect(typeof data.activeTopicCount).toBe('number');

      expect(data.userCount).toBeGreaterThanOrEqual(0);
      expect(data.activeUserCount).toBeGreaterThanOrEqual(0);
      expect(data.taskCount).toBeGreaterThanOrEqual(0);
      expect(data.activeTaskCount).toBeGreaterThanOrEqual(0);
      expect(data.completedTaskCount).toBeGreaterThanOrEqual(0);
      expect(data.topicCount).toBeGreaterThanOrEqual(0);
      expect(data.activeTopicCount).toBeGreaterThanOrEqual(0);

      // userCount >= activeUserCount
      expect(data.userCount).toBeGreaterThanOrEqual(data.activeUserCount);

      // taskCount >= activeTaskCount + completedTaskCount
      expect(data.taskCount).toBeGreaterThanOrEqual(
        data.activeTaskCount + data.completedTaskCount
      );

      // topicCount >= activeTopicCount
      expect(data.topicCount).toBeGreaterThanOrEqual(data.activeTopicCount);
    });
  });

  describe('ORG_05: Organization Isolation - Cannot Access Other Org Stats', () => {
    it('should return statistics for own organization only', async () => {
      // Get stats for Acme
      const acmeResponse = await request(app)
        .get('/organization/stats')
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      expect(acmeResponse.status).toBe(200);
      const acmeStats = acmeResponse.body.data;

      // Get stats for Tech Startup
      const techResponse = await request(app)
        .get('/organization/stats')
        .set('Authorization', `Bearer ${techManagerToken}`);

      expect(techResponse.status).toBe(200);
      const techStats = techResponse.body.data;

      // Returns statistics for Tech Startup Inc only
      expect(techStats).toBeDefined();

      // Statistics differ from Acme Corporation (no data leakage)
      // At least one statistic should be different if orgs are properly isolated
      const statsAreDifferent =
        acmeStats.userCount !== techStats.userCount ||
        acmeStats.taskCount !== techStats.taskCount ||
        acmeStats.topicCount !== techStats.topicCount;

      expect(statsAreDifferent).toBe(true);

      // No data leakage between organizations
      // Each org should have its own counts
    });
  });
});
