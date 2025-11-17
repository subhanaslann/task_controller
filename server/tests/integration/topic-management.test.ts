import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
  testData,
} from '../helpers/testHelpers';

const app = createApp();

describe('Topic Management Tests', () => {
  let acmeManagerToken: string;
  let acmeMemberToken: string;
  let acmeGuestToken: string;
  let techManagerToken: string;
  let acmeTopicId: string;

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

    acmeTopicId = testData.topics.acmeBackend.id;
  });

  afterEach(async () => {
    await cleanupTestDatabase();
  });

  afterAll(async () => {
    await disconnectDatabase();
  });

  describe('TOPIC_01: Get Active Topics (Member)', () => {
    it('should return all active topics for member', async () => {
      const response = await request(app)
        .get('/topics/active')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('topics');
      
      // Returns array of active topics
      expect(Array.isArray(response.body.topics)).toBe(true);

      const topics = response.body.topics;
      
      // Topics belong to user's organization
      topics.forEach((topic: any) => {
        expect(topic).toHaveProperty('id');
        expect(topic).toHaveProperty('organizationId');
        expect(topic.organizationId).toBe(testData.organizations.acme.id);
        expect(topic).toHaveProperty('title');
        expect(topic).toHaveProperty('description');
        expect(topic.isActive).toBe(true);
        expect(topic).toHaveProperty('createdAt');
        expect(topic).toHaveProperty('updatedAt');
      });

      // Acme has 2 topics - member sees all active topics
      expect(topics.length).toBe(2);
    });
  });

  describe('TOPIC_02: Get Active Topics (Guest - Filtered)', () => {
    it('should return only topics guest has access to', async () => {
      const response = await request(app)
        .get('/topics/active')
        .set('Authorization', `Bearer ${acmeGuestToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('topics');
      expect(Array.isArray(response.body.topics)).toBe(true);

      // Returns only topics guest has access to
      const topics = response.body.topics;
      
      // Guest sees limited topics (based on GuestTopicAccess)
      expect(topics.length).toBeLessThanOrEqual(2);

      // Topics are filtered by organization and permissions
      topics.forEach((topic: any) => {
        expect(topic).toHaveProperty('id');
        expect(topic.organizationId).toBe(testData.organizations.acme.id);
        expect(topic).toHaveProperty('title');
        expect(topic).toHaveProperty('isActive');
      });

      // Verify guest has access to at least one topic
      const backendTopic = topics.find(
        (t: any) => t.id === testData.topics.acmeBackend.id
      );
      expect(backendTopic).toBeDefined();
    });
  });

  describe('TOPIC_03: List All Topics (Team Manager)', () => {
    it('should return all topics including inactive for team manager', async () => {
      const response = await request(app)
        .get('/admin/topics')
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('topics');
      expect(Array.isArray(response.body.topics)).toBe(true);

      // Returns all topics (active and inactive)
      const topics = response.body.topics;
      
      // Topics belong to manager's organization only
      topics.forEach((topic: any) => {
        expect(topic).toHaveProperty('id');
        expect(topic.organizationId).toBe(testData.organizations.acme.id);
        expect(topic).toHaveProperty('title');
        expect(topic).toHaveProperty('description');
        expect(topic).toHaveProperty('isActive');
      });

      // No topics from other organizations
      const techTopics = topics.filter(
        (topic: any) => topic.organizationId === testData.organizations.tech.id
      );
      expect(techTopics.length).toBe(0);
    });
  });

  describe('TOPIC_04: Create New Topic', () => {
    it('should create a new topic in the same organization', async () => {
      const response = await request(app)
        .post('/admin/topics')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          title: 'Testing & QA',
          description: 'Quality assurance and testing tasks',
          isActive: true,
        });

      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('topic');

      // Topic is created successfully
      const { topic } = response.body;
      expect(topic).toHaveProperty('id');
      expect(typeof topic.id).toBe('string');
      
      // Topic belongs to manager's organization
      expect(topic.organizationId).toBe(testData.organizations.acme.id);
      expect(topic.title).toBe('Testing & QA');
      expect(topic.description).toBe('Quality assurance and testing tasks');
      
      // isActive defaults to true if not specified (or as set)
      expect(topic.isActive).toBe(true);
      expect(topic).toHaveProperty('createdAt');
      expect(topic).toHaveProperty('updatedAt');
    });
  });

  describe('TOPIC_05: Get Topic by ID', () => {
    it('should return topic details for topic in same organization', async () => {
      const response = await request(app)
        .get(`/admin/topics/${acmeTopicId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('topic');
      
      // Returns topic details
      const topic = response.body.topic;
      expect(topic.id).toBe(acmeTopicId);
      expect(topic).toHaveProperty('title');
      expect(topic).toHaveProperty('description');
      expect(topic).toHaveProperty('isActive');
      
      // Topic belongs to correct organization
      expect(topic.organizationId).toBe(testData.organizations.acme.id);
    });
  });

  describe('TOPIC_06: Update Topic', () => {
    it('should update topic successfully', async () => {
      // First create a topic
      const createRes = await request(app)
        .post('/admin/topics')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          title: 'Original Title',
          description: 'Original description',
          isActive: true,
        });

      expect(createRes.status).toBe(201);
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

      // Topic is updated successfully
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('topic');
      
      // Changes are reflected in response
      expect(response.body.topic.title).toBe('Testing & Quality Assurance');
      expect(response.body.topic.description).toBe('Updated description');
      expect(response.body.topic.isActive).toBe(false);
      expect(response.body.topic.id).toBe(topicId);
    });
  });

  describe('TOPIC_07: Delete Topic', () => {
    it('should delete topic successfully', async () => {
      // First create a topic
      const createRes = await request(app)
        .post('/admin/topics')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          title: 'Delete Me',
          description: 'This topic will be deleted',
          isActive: true,
        });

      expect(createRes.status).toBe(201);
      const topicId = createRes.body.topic.id;

      // Delete the topic
      const response = await request(app)
        .delete(`/admin/topics/${topicId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      // Topic is deleted successfully
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('message');

      // Verify topic is deleted
      const getRes = await request(app)
        .get(`/admin/topics/${topicId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      expect(getRes.status).toBe(404);
      expect(getRes.body).toHaveProperty('error');
    });
  });

  describe('TOPIC_08: Cross-Organization Topic Access Prevention', () => {
    it('should return 404 when accessing topic from different organization', async () => {
      // Tech manager tries to access Acme topic
      const response = await request(app)
        .get(`/admin/topics/${acmeTopicId}`)
        .set('Authorization', `Bearer ${techManagerToken}`);

      // Returns 404 Not Found (or 403 Forbidden for cross-org access)
      expect([403, 404]).toContain(response.status);
      expect(response.body).toHaveProperty('error');
      
      // Tech Startup manager cannot access Acme topics
      expect(response.body.error).toBeDefined();
      expect(response.body).not.toHaveProperty('topic');
    });
  });

  describe('TOPIC_09: Member Cannot Manage Topics', () => {
    it('should return 403 when member tries to create topic', async () => {
      const response = await request(app)
        .post('/admin/topics')
        .set('Authorization', `Bearer ${acmeMemberToken}`)
        .send({
          title: 'Unauthorized Topic',
          description: 'Member should not be able to create this',
          isActive: true,
        });

      // Returns 403 Forbidden
      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error');
      
      // Members cannot create topics
      expect(response.body.error).toBeDefined();
      expect(response.body).not.toHaveProperty('topic');
    });
  });
});

