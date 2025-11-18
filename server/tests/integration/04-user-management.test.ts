import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
  testData,
} from '../helpers/testHelpers';

const app = createApp();

describe('4. User Management Tests', () => {
  let acmeManagerToken: string;
  let acmeMemberToken: string;
  let acmeMemberId: string;
  let techManagerToken: string;
  // @ts-expect-error - This variable will be used in future tests
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  let newUserId: string;

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
    acmeMemberId = acmeMemberRes.body.user.id;

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
    it('should return all users in organization for team manager', async () => {
      const response = await request(app)
        .get('/users')
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      // Expected status
      expect(response.status).toBe(200);

      // Returns array of users
      expect(response.body).toHaveProperty('users');
      expect(Array.isArray(response.body.users)).toBe(true);

      const { users } = response.body;

      // All users belong to same organization (Acme)
      users.forEach((user: any) => {
        expect(user.organizationId).toBe(testData.organizations.acme.id);
      });

      // User count matches organization (4 for Acme)
      expect(users.length).toBe(4);

      // No users from other organizations
      const hasOtherOrgUsers = users.some(
        (user: any) => user.organizationId !== testData.organizations.acme.id
      );
      expect(hasOtherOrgUsers).toBe(false);
    });
  });

  describe('USER_02: List Users (Member - Should Fail)', () => {
    it('should return 403 when member tries to list users', async () => {
      const response = await request(app)
        .get('/users')
        .set('Authorization', `Bearer ${acmeMemberToken}`);

      // Returns 403 Forbidden
      expect(response.status).toBe(403);

      // Members cannot list users
      expect(response.body).toHaveProperty('error');
      expect(response.body.error.message.toLowerCase()).toContain('forbidden');
    });
  });

  describe('USER_03: Create New User (Team Manager)', () => {
    it('should allow team manager to create new user', async () => {
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

      // Expected status
      expect(response.status).toBe(201);

      // User is created successfully
      expect(response.body).toHaveProperty('user');
      const { user } = response.body;

      expect(user.id).toBeDefined();
      expect(user.name).toBe('New Member');
      expect(user.username).toBe('newmember');
      expect(user.email).toBe('newmember@acme.com');
      expect(user.role).toBe('MEMBER');
      expect(user.active).toBe(true);

      // User belongs to same organization as manager
      expect(user.organizationId).toBe(testData.organizations.acme.id);

      // Password is hashed (not in response)
      expect(user).not.toHaveProperty('password');
      expect(user).not.toHaveProperty('passwordHash');

      // Username is unique within organization
      // Save for subsequent tests
      newUserId = user.id;
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

      // Team Manager cannot create ADMIN users
      expect(response.body).toHaveProperty('error');
      expect(response.body.error.message.toLowerCase()).toContain('admin');
    });
  });

  describe('USER_05: Team Manager Cannot Create Other Team Managers', () => {
    it('should return 403 when team manager tries to create another team manager', async () => {
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

      // Team Manager cannot create other TEAM_MANAGER users
      expect(response.body).toHaveProperty('error');
      expect(response.body.error.message.toLowerCase()).toContain('team manager');
    });
  });

  describe('USER_06: Update User (Deactivate)', () => {
    it('should allow team manager to deactivate user', async () => {
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

      const userId = createRes.body.user.id;

      // Deactivate the user
      const response = await request(app)
        .patch(`/users/${userId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          active: false,
        });

      // Expected status
      expect(response.status).toBe(200);

      // User is deactivated
      expect(response.body.user.active).toBe(false);

      // User still exists (soft delete)
      expect(response.body.user.id).toBe(userId);
    });
  });

  describe('USER_07: Update User Role', () => {
    it('should allow team manager to update user role', async () => {
      // First create a user
      const createRes = await request(app)
        .post('/users')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          name: 'Role Test User',
          username: 'roletest',
          email: 'roletest@acme.com',
          password: 'password123',
          role: 'MEMBER',
        });

      const userId = createRes.body.user.id;

      // Update role to GUEST
      const response = await request(app)
        .patch(`/users/${userId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          role: 'GUEST',
        });

      // Expected status
      expect(response.status).toBe(200);

      // User role is updated to GUEST
      expect(response.body.user.role).toBe('GUEST');

      // User remains in same organization
      expect(response.body.user.organizationId).toBe(testData.organizations.acme.id);
    });
  });

  describe('USER_08: Get User by ID', () => {
    it('should return user details for team manager', async () => {
      // Create a user first
      const createRes = await request(app)
        .post('/users')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          name: 'Get Test User',
          username: 'gettest',
          email: 'gettest@acme.com',
          password: 'password123',
          role: 'MEMBER',
        });

      const userId = createRes.body.user.id;

      // Get user by ID
      const response = await request(app)
        .get(`/users/${userId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      // Expected status
      expect(response.status).toBe(200);

      // Returns user details
      expect(response.body).toHaveProperty('user');
      expect(response.body.user.id).toBe(userId);

      // User belongs to correct organization
      expect(response.body.user.organizationId).toBe(testData.organizations.acme.id);
    });
  });

  describe('USER_09: Cross-Organization Access Prevention', () => {
    it('should return 403 when accessing user from different organization', async () => {
      // Tech Startup manager tries to access Acme member
      const response = await request(app)
        .get(`/users/${acmeMemberId}`)
        .set('Authorization', `Bearer ${techManagerToken}`);

      // Returns 403 Forbidden
      expect(response.status).toBe(403);

      // Tech Startup manager cannot access Acme users
      expect(response.body).toHaveProperty('error');

      // Organization isolation is enforced
    });
  });

  describe('USER_10: Delete User', () => {
    it('should allow team manager to delete user', async () => {
      // Create a user first
      const createRes = await request(app)
        .post('/users')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          name: 'Delete Test User',
          username: 'deletetest',
          email: 'deletetest@acme.com',
          password: 'password123',
          role: 'MEMBER',
        });

      const userId = createRes.body.user.id;

      // Delete the user
      const response = await request(app)
        .delete(`/users/${userId}`)
        .set('Authorization', `Bearer ${acmeManagerToken}`);

      // Expected status
      expect(response.status).toBe(200);

      // User is deleted successfully
      expect(response.body).toHaveProperty('message');

      // Returns success response
      expect(response.body.message).toContain('success');
    });
  });

  describe('USER_11: Enforce User Limit (15 max)', () => {
    it('should return 400 when organization user limit is reached', async () => {
      // Create users until we reach the limit (15 total)
      // Acme already has 4 users, so we can add 11 more
      const usersToCreate = 11;

      for (let i = 0; i < usersToCreate; i++) {
        const createRes = await request(app)
          .post('/users')
          .set('Authorization', `Bearer ${acmeManagerToken}`)
          .send({
            name: `Limit Test User ${i}`,
            username: `limituser${i}`,
            email: `limituser${i}@acme.com`,
            password: 'password123',
            role: 'MEMBER',
          });

        // First 11 should succeed
        expect(createRes.status).toBe(201);
      }

      // Now we should have 15 users (4 original + 11 new)
      // Trying to create one more should fail
      const response = await request(app)
        .post('/users')
        .set('Authorization', `Bearer ${acmeManagerToken}`)
        .send({
          name: 'One Too Many',
          username: 'toolate',
          email: 'toolate@acme.com',
          password: 'password123',
          role: 'MEMBER',
        });

      // Returns 400 when user limit reached
      expect(response.status).toBe(400);

      // Error message indicates limit exceeded
      expect(response.body).toHaveProperty('error');
      expect(
        response.body.error.message.toLowerCase().includes('limit') ||
          response.body.error.message.toLowerCase().includes('maximum') ||
          response.body.error.message.includes('15')
      ).toBe(true);

      // Limit is enforced per organization (15 users)
    });
  });
});
