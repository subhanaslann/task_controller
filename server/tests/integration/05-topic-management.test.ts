import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
  testData,
} from '../helpers/testHelpers';

const app = createApp();

describe('5. Topic Management Tests', () => {
  let acmeManagerToken: string;
  let acmeMemberToken: string;
  let acmeGuestToken: string;
  let techManagerToken: string;
  let acmeTopicId: string;
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  let newTopicId: string;

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

    const acmeGuestRes = await request(app)
      .post('/auth/login')
      .send({ usernameOrEmail: 'charlie@acme.com', password: 'guest123' });
    acmeGuestToken = acmeGuestRes.body.token;

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

  describe('TOPIC_01: Get Active Topics (Member)', () => {
    it('should return active topics for member user', async () => {
      const response = await request(app)
        .get('/topics/active')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      // Expected status
      expect(response.status).toBe(200);

      // Returns array of active topics
      expect(response.body).toHaveProperty('topics');
      expect(Array.isArray(response.body.topics)).toBe(true);

      const { topics } = response.body;

      // Topics belong to user's organization
      topics.forEach((topic: any) => {
        expect(topic.organizationId).toBe(testData.organizations.acme.id);
        expect(topic.isActive).toBe(true);
      });

      // Member sees all active topics
      expect(topics.length).toBeGreaterThan(0);

      // Topics may include tasks
      // Each topic should have basic fields
      topics.forEach((topic: any) => {
        expect(topic).toHaveProperty('id');
        expect(topic).toHaveProperty('title');
      });
    });
  });

  describe('TOPIC_02: Get Active Topics (Guest - Filtered)', () => {
    it('should return only accessible topics for guest user', async () => {
      const response = await request(app)
        .get('/topics/active')
        .set('Authorization', `Bearer ${acmeGuestToken}`);

      // Expected status
      expect(response.status).toBe(200);

      // Returns array of topics
      expect(response.body).toHaveProperty('topics');
      expect(Array.isArray(response.body.topics)).toBe(true);

      const { topics } = response.body;

      // Guest sees limited topics (based on GuestTopicAccess)
      // Topics are filtered by organization and permissions
      topics.forEach((topic: any) => {
        expect(topic.organizationId).toBe(testData.organizations.acme.id);
        expect(topic.isActive).toBe(true);
      });

      // Returns only topics guest has access to
      // Guest should see fewer or equal topics compared to members
    });
  });

  describe('TOPIC_03: List All Topics (Team Manager)', () => {
    it('should return all topics for team manager', async () => {
      const response = await request(app)
        .get('/admin/topics')
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      // Expected status
      expect(response.status).toBe(200);

      // Returns all topics (active and inactive)
      expect(response.body).toHaveProperty('topics');
      expect(Array.isArray(response.body.topics)).toBe(true);

      const { topics } = response.body;

      // Topics belong to manager's organization only
      topics.forEach((topic: any) => {
        expect(topic.organizationId).toBe(testData.organizations.acme.id);
      });

      // No topics from other organizations
      const hasOtherOrgTopics = topics.some(
        (topic: any) => topic.organizationId !== testData.organizations.acme.id
      );
      expect(hasOtherOrgTopics).toBe(false);

      // Save first topic ID for subsequent tests
      if (topics.length > 0) {
        acmeTopicId = topics[0].id;
      }
    });
  });

  describe('TOPIC_04: Create New Topic', () => {
    it('should allow team manager to create new topic', async () => {
      const response = await request(app)
        .post('/admin/topics')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          title: 'Testing & QA',
          description: 'Quality assurance and testing tasks',
          isActive: true,
        });

      // Expected status
      expect(response.status).toBe(201);

      // Topic is created successfully
      expect(response.body).toHaveProperty('topic');
      const { topic } = response.body;

      expect(topic.id).toBeDefined();
      expect(topic.organizationId).toBe(testData.organizations.acme.id);
      expect(topic.title).toBe('Testing & QA');
      expect(topic.description).toBe('Quality assurance and testing tasks');
      expect(topic.isActive).toBe(true);

      // Topic belongs to manager's organization
      expect(topic.organizationId).toBe(testData.organizations.acme.id);

      // Has timestamps
      expect(topic).toHaveProperty('createdAt');
      expect(topic).toHaveProperty('updatedAt');

      // isActive defaults to true if not specified
      // Save for subsequent tests
      newTopicId = topic.id;
    });
  });

  describe('TOPIC_05: Get Topic by ID', () => {
    it('should return topic details for team manager', async () => {
      // First get a topic ID
      const listRes = await request(app)
        .get('/admin/topics')
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      const topicId = listRes.body.topics[0]?.id;

      if (!topicId) {
        // Create a topic if none exists
        const createRes = await request(app)
          .post('/admin/topics')
          .set('Authorization', `Bearer ${acmeManagerToken}`)
          .send({
            title: 'Test Topic',
            description: 'Test description',
          });
        acmeTopicId = createRes.body.topic.id;
      } else {
        acmeTopicId = topicId;
      }

      // Get topic by ID
      const response = await request(app)
        .get(`/admin/topics/${acmeTopicId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      // Expected status
      expect(response.status).toBe(200);

      // Returns topic details
      expect(response.body).toHaveProperty('topic');
      expect(response.body.topic.id).toBe(acmeTopicId);

      // Topic belongs to correct organization
      expect(response.body.topic.organizationId).toBe(testData.organizations.acme.id);
    });
  });

  describe('TOPIC_06: Update Topic', () => {
    it('should allow team manager to update topic', async () => {
      // Create a topic first
      const createRes = await request(app)
        .post('/admin/topics')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          title: 'Original Title',
          description: 'Original description',
          isActive: true,
        });

      const topicId = createRes.body.topic.id;

      // Update the topic
      const response = await request(app)
        .patch(`/admin/topics/${topicId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          title: 'Testing & Quality Assurance',
          description: 'Updated description',
          isActive: false,
        });

      // Expected status
      expect(response.status).toBe(200);

      // Topic is updated successfully
      expect(response.body.topic.title).toBe('Testing & Quality Assurance');
      expect(response.body.topic.description).toBe('Updated description');
      expect(response.body.topic.isActive).toBe(false);

      // Changes are reflected in response
    });
  });

  describe('TOPIC_07: Delete Topic', () => {
    it('should allow team manager to delete topic', async () => {
      // Create a topic first
      const createRes = await request(app)
        .post('/admin/topics')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          title: 'To Delete',
          description: 'This topic will be deleted',
        });

      const topicId = createRes.body.topic.id;

      // Delete the topic
      const response = await request(app)
        .delete(`/admin/topics/${topicId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      // Expected status
      expect(response.status).toBe(200);

      // Topic is deleted successfully
      expect(response.body).toHaveProperty('message');

      // Returns success response
      expect(response.body.message).toContain('success');
    });
  });

  describe('TOPIC_08: Cross-Organization Topic Access Prevention', () => {
    it('should return 404 when accessing topic from different organization', async () => {
      // Get an Acme topic ID
      const listRes = await request(app)
        .get('/admin/topics')
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      const acmeTopicId = listRes.body.topics[0]?.id;

      if (!acmeTopicId) {
        // Create a topic if none exists
        const createRes = await request(app)
          .post('/admin/topics')
          .set('Authorization', `Bearer ${acmeManagerToken}`)
          .send({
            title: 'Acme Topic',
            description: 'Test',
          });
        const topicId = createRes.body.topic.id;

        // Tech Startup manager tries to access Acme topic
        const response = await request(app)
          .get(`/admin/topics/${topicId}`)
          .set('Authorization', `Bearer ${techManagerToken}`);

        // Returns 404 Not Found
        expect(response.status).toBe(404);
      } else {
        // Tech Startup manager tries to access Acme topic
        const response = await request(app)
          .get(`/admin/topics/${acmeTopicId}`)
          .set('Authorization', `Bearer ${techManagerToken}`);

        // Returns 404 Not Found
        expect(response.status).toBe(404);
      }

      // Tech Startup manager cannot access Acme topics
    });
  });

  describe('TOPIC_09: Member Cannot Manage Topics', () => {
    it('should return 403 when member tries to create topic', async () => {
      const response = await request(app)
        .post('/admin/topics')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Unauthorized Topic',
        });

      // Returns 403 Forbidden
      expect(response.status).toBe(403);

      // Members cannot create topics
      expect(response.body).toHaveProperty('error');
      expect(response.body.error.toLowerCase()).toContain('forbidden');
    });
  });
});
