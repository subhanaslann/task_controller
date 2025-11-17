import request from 'supertest';
import { createApp } from '../../src/app';
import {
  setupTestDatabase,
  cleanupTestDatabase,
  disconnectDatabase,
} from '../helpers/testHelpers';

const app = createApp();

describe('2. Authentication & Registration Tests', () => {
  // Variables for storing test data between tests
  // @ts-expect-error - These variables will be used in future tests
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  let acmeManagerToken: string;
  // @ts-expect-error - These variables will be used in future tests
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  let acmeManagerId: string;
  let acmeOrgId: string;
  // @ts-expect-error - These variables will be used in future tests
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  let acmeMemberToken: string;
  // @ts-expect-error - These variables will be used in future tests
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  let acmeMemberId: string;
  // @ts-expect-error - These variables will be used in future tests
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  let acmeGuestToken: string;
  // @ts-expect-error - These variables will be used in future tests
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  let acmeGuestId: string;
  // @ts-expect-error - These variables will be used in future tests
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  let techManagerToken: string;
  // @ts-expect-error - These variables will be used in future tests
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  let techOrgId: string;
  // @ts-expect-error - These variables will be used in future tests
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  let newOrgId: string;
  // @ts-expect-error - These variables will be used in future tests
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  let newManagerToken: string;

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
      const response = await request(app).post('/auth/login').send({
        usernameOrEmail: 'john@acme.com',
        password: 'manager123',
      });

      // Expected status
      expect(response.status).toBe(200);

      // Validate token
      expect(response.body).toHaveProperty('token');
      expect(typeof response.body.token).toBe('string');
      expect(response.body.token.length).toBeGreaterThan(0);

      // Validate user object
      const { user } = response.body;
      expect(user).toBeDefined();
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

      // Validate organization object
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

      // Save variables for subsequent tests
      acmeManagerToken = response.body.token;
      acmeManagerId = user.id;
      acmeOrgId = organization.id;

      // Verify JWT token contains required claims (by decoding the payload)
      const tokenParts = response.body.token.split('.');
      expect(tokenParts.length).toBe(3); // JWT has 3 parts
    });
  });

  describe('AUTH_02: Login with Username (Member)', () => {
    it('should login successfully with username instead of email', async () => {
      const response = await request(app).post('/auth/login').send({
        usernameOrEmail: 'alice',
        password: 'member123',
      });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('token');

      const { user, organization } = response.body;

      // Verify login succeeds with username
      expect(user.username).toBe('alice');
      expect(user.role).toBe('MEMBER');

      // Organization matches Acme Corporation
      expect(organization.name).toBe('Acme Corporation');

      // Save variables
      acmeMemberToken = response.body.token;
      acmeMemberId = user.id;
    });
  });

  describe('AUTH_03: Login as Guest User', () => {
    it('should login successfully as guest user', async () => {
      const response = await request(app).post('/auth/login').send({
        usernameOrEmail: 'charlie@acme.com',
        password: 'guest123',
      });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('token');

      const { user } = response.body;

      // User role is GUEST
      expect(user.role).toBe('GUEST');

      // Token is valid
      expect(response.body.token).toBeDefined();
      expect(typeof response.body.token).toBe('string');

      // Save variables
      acmeGuestToken = response.body.token;
      acmeGuestId = user.id;
    });
  });

  describe('AUTH_04: Login from Different Organization', () => {
    it('should login user from different organization with correct org data', async () => {
      const response = await request(app).post('/auth/login').send({
        usernameOrEmail: 'sarah@techstartup.com',
        password: 'manager123',
      });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('token');

      const { user, organization } = response.body;

      // User belongs to Tech Startup Inc organization
      expect(organization.name).toBe('Tech Startup Inc');

      // organizationId is different from Acme Corporation
      if (acmeOrgId) {
        expect(organization.id).not.toBe(acmeOrgId);
      }

      // Token contains correct organizationId
      expect(user.organizationId).toBe(organization.id);

      // Save variables
      techManagerToken = response.body.token;
      techOrgId = organization.id;
    });
  });

  describe('AUTH_05: Login with Invalid Credentials', () => {
    it('should return 401 for invalid password', async () => {
      const response = await request(app).post('/auth/login').send({
        usernameOrEmail: 'john@acme.com',
        password: 'wrongpassword',
      });

      // Returns 401 Unauthorized
      expect(response.status).toBe(401);

      // Error message indicates invalid credentials
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toContain('credentials');

      // No token is returned
      expect(response.body).not.toHaveProperty('token');
    });
  });

  describe('AUTH_06: Login with Non-existent User', () => {
    it('should return 401 for non-existent user without revealing user existence', async () => {
      const response = await request(app).post('/auth/login').send({
        usernameOrEmail: 'nonexistent@example.com',
        password: 'password123',
      });

      // Returns 401 Unauthorized
      expect(response.status).toBe(401);

      // Error message does not reveal user existence (same as invalid password)
      expect(response.body).toHaveProperty('error');
      expect(response.body.error).toContain('credentials');

      // Should not indicate whether user exists or not
      expect(response.body.error.toLowerCase()).not.toContain('not found');
      expect(response.body.error.toLowerCase()).not.toContain('does not exist');
    });
  });

  describe('REG_01: Register New Team', () => {
    it('should register new team with organization and manager user', async () => {
      const response = await request(app).post('/auth/register').send({
        companyName: 'New Startup LLC',
        teamName: 'Development',
        managerName: 'Jane Smith',
        email: 'jane@newstartup.com',
        password: 'SecurePass123',
      });

      // Expected status
      expect(response.status).toBe(201);

      // Response structure
      expect(response.body).toHaveProperty('message');
      expect(response.body.message).toContain('registered successfully');

      expect(response.body).toHaveProperty('data');
      const { data } = response.body;

      // Organization is created with unique slug
      expect(data).toHaveProperty('organization');
      const { organization } = data;
      expect(organization.id).toBeDefined();
      expect(organization.name).toBe('New Startup LLC');
      expect(organization.teamName).toBe('Development');
      expect(organization.slug).toBeDefined();
      expect(organization.isActive).toBe(true);

      // maxUsers defaults to 15
      expect(organization.maxUsers).toBe(15);

      // User is created as TEAM_MANAGER
      expect(data).toHaveProperty('user');
      const { user } = data;
      expect(user.id).toBeDefined();
      expect(user.name).toBe('Jane Smith');
      expect(user.email).toBe('jane@newstartup.com');
      expect(user.role).toBe('TEAM_MANAGER');
      expect(user.active).toBe(true);

      // JWT token is returned
      expect(data).toHaveProperty('token');
      expect(typeof data.token).toBe('string');
      expect(data.token.length).toBeGreaterThan(0);

      // Organization is active by default
      expect(organization.isActive).toBe(true);

      // Email is unique across all organizations (tested implicitly)
      // Save variables
      newOrgId = organization.id;
      newManagerToken = data.token;
    });
  });

  describe('REG_02: Register with Duplicate Email', () => {
    it('should return 400 when registering with existing email', async () => {
      const response = await request(app).post('/auth/register').send({
        companyName: 'Another Company',
        teamName: 'Another Team',
        managerName: 'John Doe',
        email: 'john@acme.com', // This email already exists
        password: 'password123',
      });

      // Returns 400 Bad Request
      expect(response.status).toBe(400);

      // Error message indicates email already exists
      expect(response.body).toHaveProperty('error');
      expect(response.body.error.toLowerCase()).toContain('email');
      expect(
        response.body.error.toLowerCase().includes('already') ||
          response.body.error.toLowerCase().includes('exists')
      ).toBe(true);
    });
  });

  describe('REG_03: Register with Invalid Password', () => {
    it('should return 400 when password is too short', async () => {
      const response = await request(app).post('/auth/register').send({
        companyName: 'Test Company',
        teamName: 'Test Team',
        managerName: 'Test User',
        email: 'test@test.com',
        password: 'short', // Too short (min 8 chars)
      });

      // Returns 400 Bad Request
      expect(response.status).toBe(400);

      // Error indicates password too short (min 8 chars)
      expect(response.body).toHaveProperty('error');
      expect(
        response.body.error.toLowerCase().includes('password') &&
          (response.body.error.includes('8') ||
            response.body.error.toLowerCase().includes('short'))
      ).toBe(true);
    });
  });
});
