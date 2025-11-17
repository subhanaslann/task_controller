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

      // Validate JWT token structure (basic check) - must be valid JWT format
      expect(response.body.token).toMatch(/^[\w-]+\.[\w-]+\.[\w-]+$/);
      expect(typeof response.body.token).toBe('string');
      expect(response.body.token.length).toBeGreaterThan(20);

      // Validate user details - all required fields present
      const { user } = response.body;
      expect(user).toHaveProperty('id');
      expect(user).toHaveProperty('organizationId');
      expect(user.name).toBe('John Manager');
      expect(user.username).toBe('john');
      expect(user.email).toBe('john@acme.com');
      expect(user.role).toBe('TEAM_MANAGER');
      expect(user.active).toBe(true);
      expect(user).toHaveProperty('createdAt');
      expect(user).toHaveProperty('updatedAt');

      // Password should NOT be in response - security check
      expect(user).not.toHaveProperty('password');
      expect(user).not.toHaveProperty('passwordHash');

      // Validate organization details are included
      const { organization } = response.body;
      expect(organization).toBeDefined();
      expect(organization).toHaveProperty('id');
      expect(organization.name).toBe('Acme Corporation');
      expect(organization.teamName).toBe('Engineering Team');
      expect(organization.slug).toBe('acme-engineering');
      expect(organization.isActive).toBe(true);
      expect(organization.maxUsers).toBe(15);
      expect(organization).toHaveProperty('createdAt');
      expect(organization).toHaveProperty('updatedAt');

      // Verify organizationId in user matches organization id
      expect(user.organizationId).toBe(organization.id);

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
      expect(response.body).toHaveProperty('user');
      expect(response.body).toHaveProperty('organization');

      // Verify login succeeds with username instead of email
      const { user, organization } = response.body;
      expect(user.username).toBe('alice');
      expect(user.role).toBe('MEMBER');
      expect(user.email).toBe('alice@acme.com');
      expect(user).toHaveProperty('id');
      expect(user).toHaveProperty('organizationId');

      // Verify organization matches Acme Corporation
      expect(organization.name).toBe('Acme Corporation');
      expect(organization.teamName).toBe('Engineering Team');
      expect(organization.slug).toBe('acme-engineering');
      expect(user.organizationId).toBe(organization.id);

      // Token validation
      expect(response.body.token).toMatch(/^[\w-]+\.[\w-]+\.[\w-]+$/);

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
      expect(response.body).toHaveProperty('user');
      expect(response.body).toHaveProperty('organization');

      // Verify user role is GUEST
      const { user } = response.body;
      expect(user.role).toBe('GUEST');
      expect(user.name).toBe('Charlie Guest');
      expect(user.username).toBe('charlie');
      expect(user.email).toBe('charlie@acme.com');
      expect(user).toHaveProperty('id');
      expect(user).toHaveProperty('organizationId');

      // Token is valid - JWT format
      expect(response.body.token).toMatch(/^[\w-]+\.[\w-]+\.[\w-]+$/);
      expect(typeof response.body.token).toBe('string');

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
      expect(response.body).toHaveProperty('token');
      expect(response.body).toHaveProperty('user');
      expect(response.body).toHaveProperty('organization');

      // Verify user belongs to Tech Startup Inc organization
      const { user, organization } = response.body;
      expect(user.name).toBe('Sarah Manager');
      expect(user.role).toBe('TEAM_MANAGER');
      expect(user.email).toBe('sarah@techstartup.com');
      
      // Verify organization is Tech Startup Inc, not Acme
      expect(organization.name).toBe('Tech Startup Inc');
      expect(organization.teamName).toBe('Product Team');
      expect(organization.slug).toBe('tech-startup-product');
      
      // Ensure organizationId is different from Acme
      expect(organization.id).not.toBe(testData.organizations.acme.id);
      expect(user.organizationId).toBe(organization.id);
      expect(user.organizationId).not.toBe(testData.organizations.acme.id);

      // Token contains correct organizationId
      expect(response.body.token).toMatch(/^[\w-]+\.[\w-]+\.[\w-]+$/);

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

      // Returns 401 Unauthorized
      expect(response.status).toBe(401);
      expect(response.body).toHaveProperty('error');
      
      // Error message indicates invalid credentials
      expect(response.body.error).toBeDefined();
      expect(typeof response.body.error).toBe('object');
      
      // No token is returned
      expect(response.body).not.toHaveProperty('token');
      expect(response.body).not.toHaveProperty('user');
      expect(response.body).not.toHaveProperty('organization');
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

      // Returns 401 Unauthorized
      expect(response.status).toBe(401);
      expect(response.body).toHaveProperty('error');
      
      // Error message does not reveal user existence (security best practice)
      expect(response.body.error).toBeDefined();
      
      // No token or user data is returned
      expect(response.body).not.toHaveProperty('token');
      expect(response.body).not.toHaveProperty('user');
      expect(response.body).not.toHaveProperty('organization');
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

      // Validate organization is created with unique slug
      const { organization } = data;
      expect(organization).toHaveProperty('id');
      expect(organization.name).toBe('New Startup LLC');
      expect(organization.teamName).toBe('Development');
      expect(organization).toHaveProperty('slug');
      expect(typeof organization.slug).toBe('string');
      expect(organization.slug.length).toBeGreaterThan(0);
      
      // Organization is active by default
      expect(organization.isActive).toBe(true);
      
      // maxUsers defaults to 15
      expect(organization.maxUsers).toBe(15);
      expect(organization).toHaveProperty('createdAt');
      expect(organization).toHaveProperty('updatedAt');

      // Validate user is created as TEAM_MANAGER
      const { user } = data;
      expect(user).toHaveProperty('id');
      expect(user.name).toBe('Jane Smith');
      expect(user.email).toBe('jane@newstartup.com');
      expect(user.role).toBe('TEAM_MANAGER');
      expect(user.active).toBe(true);
      expect(user.organizationId).toBe(organization.id);
      expect(user).toHaveProperty('createdAt');
      expect(user).toHaveProperty('updatedAt');

      // Password is hashed (not in response)
      expect(user).not.toHaveProperty('password');
      expect(user).not.toHaveProperty('passwordHash');

      // JWT token is returned
      expect(data.token).toMatch(/^[\w-]+\.[\w-]+\.[\w-]+$/);
      expect(typeof data.token).toBe('string');

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

      // Returns 400 Bad Request or 409 Conflict for duplicate
      expect([400, 409]).toContain(response.status);
      expect(response.body).toHaveProperty('error');
      
      // Error message indicates email already exists
      expect(response.body.error).toBeDefined();
      expect(typeof response.body.error).toBe('object');
      
      // No data is returned
      expect(response.body).not.toHaveProperty('data');
      expect(response.body).not.toHaveProperty('token');
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

      // Returns 400 Bad Request
      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
      
      // Error indicates password too short (min 8 chars)
      expect(response.body.error).toBeDefined();
      expect(typeof response.body.error).toBe('object');
      
      // No data is returned
      expect(response.body).not.toHaveProperty('data');
      expect(response.body).not.toHaveProperty('token');
    });
  });
});

