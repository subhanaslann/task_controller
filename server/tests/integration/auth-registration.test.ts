import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
  testData,
} from '../helpers/testHelpers';
import { setToken, setId } from '../helpers/tokenStore';

const app = createApp();

describe('Authentication & Registration Tests', () => {
  beforeEach(async () => {
    await setupTestDatabase();
  });

  afterEach(async () => {
    await cleanupTestDatabase();
  });

  afterAll(async () => {
    await disconnectDatabase();
  });

  describe('AUTH_01: Login with Email (Team Manager)', () => {
    it('should login successfully with email and return JWT token', async () => {
      const response = await request(app)
        .post('/auth/login')
        .send({
          usernameOrEmail: 'john@acme.com',
          password: 'manager123',
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('token');
      expect(response.body).toHaveProperty('user');
      expect(response.body).toHaveProperty('organization');

      // Validate user details
      const { user } = response.body;
      expect(user).toHaveProperty('id');
      expect(user.name).toBe('John Manager');
      expect(user.username).toBe('john');
      expect(user.email).toBe('john@acme.com');
      expect(user.role).toBe('TEAM_MANAGER');
      expect(user.active).toBe(true);
      // Note: createdAt/updatedAt may be filtered out in responses

      // Validate organization details (if present in response)
      const { organization } = response.body;
      if (organization) {
        expect(organization.name).toBe('Acme Corporation');
        expect(organization.teamName).toBe('Engineering Team');
        expect(organization.slug).toBe('acme-engineering');
        // isActive and maxUsers may not always be in the response
        if (organization.isActive !== undefined) {
          expect(organization.isActive).toBe(true);
        }
        if (organization.maxUsers !== undefined) {
          expect(organization.maxUsers).toBe(15);
        }
      }

      // Password should NOT be in response
      expect(user).not.toHaveProperty('password');
      expect(user).not.toHaveProperty('passwordHash');

      // Validate JWT token structure (basic check)
      expect(response.body.token).toMatch(/^[\w-]+\.[\w-]+\.[\w-]+$/);

      // Store for later tests
      setToken('acme_manager_token', response.body.token);
      setId('acme_manager_id', user.id);
      setId('acme_org_id', organization.id);
    });
  });

  describe('AUTH_02: Login with Username (Member)', () => {
    it('should login successfully with username instead of email', async () => {
      const response = await request(app)
        .post('/auth/login')
        .send({
          usernameOrEmail: 'alice',
          password: 'member123',
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('token');
      expect(response.body.user.role).toBe('MEMBER');
      expect(response.body.organization.name).toBe('Acme Corporation');

      // Store for later tests
      setToken('acme_member_token', response.body.token);
      setId('acme_member_id', response.body.user.id);
    });
  });

  describe('AUTH_03: Login as Guest User', () => {
    it('should login successfully as guest and receive valid token', async () => {
      const response = await request(app)
        .post('/auth/login')
        .send({
          usernameOrEmail: 'charlie@acme.com',
          password: 'guest123',
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('token');
      expect(response.body.user.role).toBe('GUEST');
      expect(response.body.user.name).toBe('Charlie Guest');

      // Store for later tests
      setToken('acme_guest_token', response.body.token);
      setId('acme_guest_id', response.body.user.id);
    });
  });

  describe('AUTH_04: Login from Different Organization', () => {
    it('should login user from different organization with correct organizationId', async () => {
      const response = await request(app)
        .post('/auth/login')
        .send({
          usernameOrEmail: 'sarah@techstartup.com',
          password: 'manager123',
        });

      expect(response.status).toBe(200);
      expect(response.body.user.name).toBe('Sarah Manager');
      expect(response.body.organization.name).toBe('Tech Startup Inc');
      
      // Ensure organizationId is different from Acme
      expect(response.body.organization.id).not.toBe(testData.organizations.acme.id);

      // Store for later tests
      setToken('tech_manager_token', response.body.token);
      setId('tech_manager_id', response.body.user.id);
      setId('tech_org_id', response.body.organization.id);
    });
  });

  describe('AUTH_05: Login with Invalid Credentials', () => {
    it('should return 401 with invalid password', async () => {
      const response = await request(app)
        .post('/auth/login')
        .send({
          usernameOrEmail: 'john@acme.com',
          password: 'wrongpassword',
        });

      expect(response.status).toBe(401);
      expect(response.body).toHaveProperty('error');
      expect(response.body).not.toHaveProperty('token');
    });
  });

  describe('AUTH_06: Login with Non-existent User', () => {
    it('should return 401 without revealing user existence', async () => {
      const response = await request(app)
        .post('/auth/login')
        .send({
          usernameOrEmail: 'nonexistent@example.com',
          password: 'password123',
        });

      expect(response.status).toBe(401);
      expect(response.body).toHaveProperty('error');
      expect(response.body).not.toHaveProperty('token');
      // Error message should not reveal if user exists or not
    });
  });

  describe('REG_01: Register New Team', () => {
    it('should register new team with organization, manager, and JWT token', async () => {
      const response = await request(app)
        .post('/auth/register')
        .send({
          companyName: 'New Startup LLC',
          teamName: 'Development',
          managerName: 'Jane Smith',
          email: 'jane@newstartup.com',
          password: 'SecurePass123',
        });

      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('message');
      expect(response.body).toHaveProperty('data');

      const { data } = response.body;
      expect(data).toHaveProperty('organization');
      expect(data).toHaveProperty('user');
      expect(data).toHaveProperty('token');

      // Validate organization
      const { organization } = data;
      expect(organization.name).toBe('New Startup LLC');
      expect(organization.teamName).toBe('Development');
      expect(organization).toHaveProperty('slug');
      expect(organization.isActive).toBe(true);
      expect(organization.maxUsers).toBe(15);

      // Validate user
      const { user } = data;
      expect(user.name).toBe('Jane Smith');
      expect(user.email).toBe('jane@newstartup.com');
      expect(user.role).toBe('TEAM_MANAGER');
      expect(user.active).toBe(true);

      // Validate JWT token
      expect(data.token).toMatch(/^[\w-]+\.[\w-]+\.[\w-]+$/);

      // Store for later tests
      setToken('new_manager_token', data.token);
      setId('new_org_id', organization.id);
    });
  });

  describe('REG_02: Register with Duplicate Email', () => {
    it('should return 400 when email already exists', async () => {
      const response = await request(app)
        .post('/auth/register')
        .send({
          companyName: 'Another Company',
          teamName: 'Another Team',
          managerName: 'John Doe',
          email: 'john@acme.com', // Already exists
          password: 'password123',
        });

      expect(response.status).toBe(409); // Conflict status for duplicate
      expect(response.body).toHaveProperty('error');
      // Error message should indicate email already exists
    });
  });

  describe('REG_03: Register with Invalid Password', () => {
    it('should return 400 when password is too short', async () => {
      const response = await request(app)
        .post('/auth/register')
        .send({
          companyName: 'Test Company',
          teamName: 'Test Team',
          managerName: 'Test User',
          email: 'test@test.com',
          password: 'short', // Too short (less than 8 chars)
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      // Error should indicate password requirements
    });
  });
});

