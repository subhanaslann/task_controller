import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
} from '../helpers/testHelpers';

const app = createApp();

describe('Organization Management Tests', () => {
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

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('message');
      expect(response.body).toHaveProperty('data');

      // Returns authenticated user's organization
      const { data } = response.body;
      expect(data).toBeDefined();
      
      // All organization fields are present
      expect(data).toHaveProperty('id');
      expect(typeof data.id).toBe('string');
      expect(data.id.length).toBeGreaterThan(0);
      
      expect(data.name).toBe('Acme Corporation');
      expect(data.teamName).toBe('Engineering Team');
      expect(data.slug).toBe('acme-engineering');
      expect(data.isActive).toBe(true);
      expect(data.maxUsers).toBe(15);
      
      expect(data).toHaveProperty('createdAt');
      expect(data).toHaveProperty('updatedAt');
      expect(() => new Date(data.createdAt)).not.toThrow();
      expect(() => new Date(data.updatedAt)).not.toThrow();
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

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('data');

      // Organization name is updated
      const { data } = response.body;
      expect(data.name).toBe('Acme Corporation Updated');
      
      // Team name is updated
      expect(data.teamName).toBe('Engineering Team v2');
      
      // maxUsers is updated to 20
      expect(data.maxUsers).toBe(20);
      
      // Response contains updated organization with all fields
      expect(data).toHaveProperty('id');
      expect(data).toHaveProperty('slug');
      expect(data).toHaveProperty('isActive');
      expect(data).toHaveProperty('createdAt');
      expect(data).toHaveProperty('updatedAt');
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
      expect(response.body).toHaveProperty('error');
      
      // Member cannot update organization
      expect(response.body.error).toBeDefined();
      expect(typeof response.body.error).toBe('object');
      
      // No data is returned
      expect(response.body).not.toHaveProperty('data');
    });
  });

  describe('ORG_04: Get Organization Statistics', () => {
    it('should return organization statistics for authenticated user', async () => {
      const response = await request(app)
        .get('/organization/stats')
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('message');
      expect(response.body).toHaveProperty('data');

      const { data } = response.body;
      
      // All count fields are present
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
      expect(data.taskCount).toBeGreaterThanOrEqual(data.activeTaskCount + data.completedTaskCount);
      
      // topicCount >= activeTopicCount
      expect(data.topicCount).toBeGreaterThanOrEqual(data.activeTopicCount);

      // Acme Corporation should have 4 users, 2 topics, and 3 tasks
      expect(data.userCount).toBe(4);
      expect(data.topicCount).toBe(2);
      expect(data.taskCount).toBe(3);
    });
  });

  describe('ORG_05: Organization Isolation - Cannot Access Other Org Stats', () => {
    it('should return statistics for Tech Startup only, not Acme', async () => {
      const response = await request(app)
        .get('/organization/stats')
        .set('Authorization', `Bearer ${techManagerToken}`);

      expect(response.status).toBe(200);
      const { data } = response.body;

      // Returns statistics for Tech Startup Inc only
      expect(data).toHaveProperty('userCount');
      expect(data).toHaveProperty('taskCount');
      expect(data).toHaveProperty('topicCount');

      // Tech Startup should have 4 users, 2 topics, and 4 tasks
      expect(data.userCount).toBe(4);
      expect(data.topicCount).toBe(2);
      expect(data.taskCount).toBe(4);

      // Ensure no data leakage by comparing with Acme stats
      const acmeResponse = await request(app)
        .get('/organization/stats')
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      expect(acmeResponse.status).toBe(200);
      const acmeData = acmeResponse.body.data;

      // Statistics differ from Acme Corporation
      expect(acmeData.taskCount).toBe(3); // Acme has 3 tasks
      expect(data.taskCount).toBe(4); // Tech Startup has 4 tasks
      expect(data.taskCount).not.toBe(acmeData.taskCount);
      
      // No data leakage between organizations - counts are independent
      expect(data.userCount).toBe(4);
      expect(acmeData.userCount).toBe(4);
      // The fact that both have 4 users is coincidence, not data leakage
      // The important test is that each org sees only their own data
    });
  });
});

