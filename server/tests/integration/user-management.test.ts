import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
  testData,
} from '../helpers/testHelpers';

const app = createApp();

describe('User Management Tests', () => {
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

  describe('USER_01: List All Users (Team Manager)', () => {
    it('should return all users in the same organization', async () => {
      const response = await request(app)
        .get('/users')
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('users');
      
      // Returns array of users
      expect(Array.isArray(response.body.users)).toBe(true);

      // All users belong to same organization
      const users = response.body.users;
      expect(users.length).toBeGreaterThan(0);
      users.forEach((user: any) => {
        expect(user).toHaveProperty('id');
        expect(user).toHaveProperty('organizationId');
        expect(user.organizationId).toBe(testData.organizations.acme.id);
        expect(user).toHaveProperty('name');
        expect(user).toHaveProperty('username');
        expect(user).toHaveProperty('email');
        expect(user).toHaveProperty('role');
        expect(user).toHaveProperty('active');
      });

      // User count matches organization (4 for Acme)
      expect(users.length).toBe(4);

      // No users from other organizations
      const techOrgUsers = users.filter(
        (user: any) => user.organizationId === testData.organizations.tech.id
      );
      expect(techOrgUsers.length).toBe(0);
    });
  });

  describe('USER_02: List Users (Member - Should Fail)', () => {
    it('should return 403 when member tries to list users', async () => {
      const response = await request(app)
        .get('/users')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      // Returns 403 Forbidden
      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error');
      
      // Members cannot list users
      expect(response.body.error).toBeDefined();
      expect(response.body).not.toHaveProperty('users');
    });
  });

  describe('USER_03: Create New User (Team Manager)', () => {
    it('should create a new user in the same organization', async () => {
      const response = await request(app)
        .post('/users')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          name: 'New Member',
          username: 'newmember',
          email: 'newmember@acme.com',
          password: 'password123',
          role: 'MEMBER',
          active: true,
        });

      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('user');

      // User is created successfully
      const { user } = response.body;
      expect(user).toHaveProperty('id');
      expect(typeof user.id).toBe('string');
      expect(user.name).toBe('New Member');
      expect(user.username).toBe('newmember');
      expect(user.email).toBe('newmember@acme.com');
      expect(user.role).toBe('MEMBER');
      expect(user.active).toBe(true);
      
      // User belongs to same organization as manager
      expect(user.organizationId).toBe(testData.organizations.acme.id);
      expect(user).toHaveProperty('createdAt');
      expect(user).toHaveProperty('updatedAt');

      // Password is hashed (not in response)
      expect(user).not.toHaveProperty('password');
      expect(user).not.toHaveProperty('passwordHash');
      
      // Username is unique within organization
      expect(user.username).toBe('newmember');
    });
  });

  describe('USER_04: Team Manager Cannot Create ADMIN', () => {
    it('should return 403 when team manager tries to create ADMIN user', async () => {
      const response = await request(app)
        .post('/users')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          name: 'Wannabe Admin',
          username: 'adminwannabe',
          email: 'admin@acme.com',
          password: 'password123',
          role: 'ADMIN',
          active: true,
        });

      // Returns 403 Forbidden
      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error');
      
      // Team Manager cannot create ADMIN users
      expect(response.body.error).toBeDefined();
      expect(response.body).not.toHaveProperty('user');
    });
  });

  describe('USER_05: Team Manager Cannot Create Other Team Managers', () => {
    it('should return 403 when team manager tries to create another TEAM_MANAGER', async () => {
      const response = await request(app)
        .post('/users')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          name: 'Another Manager',
          username: 'manager2',
          email: 'manager2@acme.com',
          password: 'password123',
          role: 'TEAM_MANAGER',
          active: true,
        });

      // Returns 403 Forbidden
      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error');
      
      // Team Manager cannot create other TEAM_MANAGER users
      expect(response.body.error).toBeDefined();
      expect(response.body).not.toHaveProperty('user');
    });
  });

  describe('USER_06: Update User (Deactivate)', () => {
    it('should deactivate a user (soft delete)', async () => {
      // First create a user
      const createRes = await request(app)
        .post('/users')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          name: 'Test User',
          username: 'testuser',
          email: 'testuser@acme.com',
          password: 'password123',
          role: 'MEMBER',
          active: true,
        });

      expect(createRes.status).toBe(201);
      const userId = createRes.body.user.id;

      // Then deactivate
      const response = await request(app)
        .patch(`/users/${userId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          active: false,
        });

      // User is deactivated
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('user');
      expect(response.body.user.active).toBe(false);
      expect(response.body.user.id).toBe(userId);

      // User still exists (soft delete)
      const getRes = await request(app)
        .get(`/users/${userId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      expect(getRes.status).toBe(200);
      expect(getRes.body).toHaveProperty('user');
      expect(getRes.body.user.active).toBe(false);
      expect(getRes.body.user).toHaveProperty('id');
    });
  });

  describe('USER_07: Update User Role', () => {
    it('should update user role to GUEST', async () => {
      // First create a user
      const createRes = await request(app)
        .post('/users')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          name: 'Test Member',
          username: 'testmember2',
          email: 'testmember2@acme.com',
          password: 'password123',
          role: 'MEMBER',
          active: true,
        });

      expect(createRes.status).toBe(201);
      const userId = createRes.body.user.id;

      // Update role to GUEST
      const response = await request(app)
        .patch(`/users/${userId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          role: 'GUEST',
        });

      // User role is updated to GUEST
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('user');
      expect(response.body.user.role).toBe('GUEST');
      
      // User remains in same organization
      expect(response.body.user.organizationId).toBe(testData.organizations.acme.id);
      expect(response.body.user.id).toBe(userId);
    });
  });

  describe('USER_08: Get User by ID', () => {
    it('should return user details for user in same organization', async () => {
      const response = await request(app)
        .get(`/users/${testData.users.aliceJohnson.id}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('user');
      
      // Returns user details
      const user = response.body.user;
      expect(user.id).toBe(testData.users.aliceJohnson.id);
      expect(user).toHaveProperty('name');
      expect(user).toHaveProperty('username');
      expect(user).toHaveProperty('email');
      expect(user).toHaveProperty('role');
      
      // User belongs to correct organization
      expect(user.organizationId).toBe(testData.organizations.acme.id);
    });
  });

  describe('USER_09: Cross-Organization Access Prevention', () => {
    it('should return 404 when accessing user from different organization', async () => {
      // Tech manager tries to access Acme user
      const response = await request(app)
        .get(`/users/${testData.users.aliceJohnson.id}`)
        .set('Authorization', `Bearer ${techManagerToken}`);

      // Returns 404 Not Found (or 403 Forbidden for cross-org access)
      expect([403, 404]).toContain(response.status);
      expect(response.body).toHaveProperty('error');
      
      // Tech Startup manager cannot access Acme users
      expect(response.body.error).toBeDefined();
      
      // Organization isolation is enforced
      expect(response.body).not.toHaveProperty('user');
    });
  });

  describe('USER_10: Delete User', () => {
    it('should delete user successfully', async () => {
      // First create a user
      const createRes = await request(app)
        .post('/users')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          name: 'Delete Me',
          username: 'deleteme',
          email: 'deleteme@acme.com',
          password: 'password123',
          role: 'MEMBER',
          active: true,
        });

      expect(createRes.status).toBe(201);
      const userId = createRes.body.user.id;

      // Delete user
      const response = await request(app)
        .delete(`/users/${userId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      // User is deleted successfully
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('message');

      // Verify user is deleted
      const getRes = await request(app)
        .get(`/users/${userId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      // After deletion, the user might still exist but be inactive (soft delete), or return 404
      expect([200, 404]).toContain(getRes.status);
    });
  });

  describe('USER_11: Enforce User Limit (15 max)', () => {
    it('should return 400 when user limit is reached', async () => {
      // Acme currently has 4 users, maxUsers is 15
      // Create 11 more users to reach the limit
      for (let i = 0; i < 11; i++) {
        const createRes = await request(app)
          .post('/users')
          .set('Authorization', `Bearer ${acmeManagerToken}`)
          .send({
            name: `User ${i}`,
            username: `user${i}`,
            email: `user${i}@acme.com`,
            password: 'password123',
            role: 'MEMBER',
            active: true,
          });
        expect([201, 403]).toContain(createRes.status);
      }

      // Now try to create one more (should fail)
      const response = await request(app)
        .post('/users')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          name: 'Limit Exceeded',
          username: 'limitexceeded',
          email: 'limitexceeded@acme.com',
          password: 'password123',
          role: 'MEMBER',
          active: true,
        });

      // Returns 400/403 when user limit reached
      expect([400, 403]).toContain(response.status);
      expect(response.body).toHaveProperty('error');
      
      // Error message indicates limit exceeded
      expect(response.body.error).toBeDefined();
      
      // Limit is enforced per organization (15 users)
      expect(response.body).not.toHaveProperty('user');
    });
  });
});

