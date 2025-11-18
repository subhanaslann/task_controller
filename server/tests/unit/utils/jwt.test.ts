import { generateToken, verifyToken } from '../../../src/utils/jwt';
import { Role } from '../../../src/types';
import jwt from 'jsonwebtoken';

// We'll use the actual jwt library but with test config
jest.mock('../../../src/config', () => ({
  config: {
    jwt: {
      secret: 'test-secret-key-for-testing-purposes-only',
      expiresIn: '1h',
    },
  },
}));

describe('JWT Utils', () => {
  describe('generateToken', () => {
    it('should generate a valid JWT token', () => {
      // Arrange
      const payload = {
        userId: 'user-123',
        organizationId: 'org-123',
        role: Role.MEMBER,
        email: 'test@example.com',
      };

      // Act
      const token = generateToken(payload);

      // Assert
      expect(token).toBeDefined();
      expect(typeof token).toBe('string');
      expect(token.split('.')).toHaveLength(3); // JWT has 3 parts
    });

    it('should generate token with correct payload', () => {
      // Arrange
      const payload = {
        userId: 'user-456',
        organizationId: 'org-456',
        role: Role.ADMIN,
        email: 'admin@example.com',
      };

      // Act
      const token = generateToken(payload);
      const decoded = jwt.decode(token) as any;

      // Assert
      expect(decoded.userId).toBe('user-456');
      expect(decoded.organizationId).toBe('org-456');
      expect(decoded.role).toBe(Role.ADMIN);
      expect(decoded.email).toBe('admin@example.com');
    });

    it('should include expiration time in token', () => {
      // Arrange
      const payload = {
        userId: 'user-123',
        organizationId: 'org-123',
        role: Role.MEMBER,
        email: 'test@example.com',
      };

      // Act
      const token = generateToken(payload);
      const decoded = jwt.decode(token) as any;

      // Assert
      expect(decoded.exp).toBeDefined();
      expect(decoded.iat).toBeDefined();
      expect(decoded.exp).toBeGreaterThan(decoded.iat);
    });

    it('should generate different tokens for different payloads', () => {
      // Arrange
      const payload1 = {
        userId: 'user-1',
        organizationId: 'org-1',
        role: Role.MEMBER,
        email: 'user1@example.com',
      };
      const payload2 = {
        userId: 'user-2',
        organizationId: 'org-2',
        role: Role.ADMIN,
        email: 'user2@example.com',
      };

      // Act
      const token1 = generateToken(payload1);
      const token2 = generateToken(payload2);

      // Assert
      expect(token1).not.toBe(token2);
    });

    it('should handle all role types', () => {
      // Test each role
      const roles = [Role.ADMIN, Role.TEAM_MANAGER, Role.MEMBER, Role.GUEST];

      roles.forEach((role) => {
        const payload = {
          userId: 'user-123',
          organizationId: 'org-123',
          role,
          email: 'test@example.com',
        };

        const token = generateToken(payload);
        const decoded = jwt.decode(token) as any;

        expect(decoded.role).toBe(role);
      });
    });
  });

  describe('verifyToken', () => {
    it('should verify and return payload from valid token', () => {
      // Arrange
      const payload = {
        userId: 'user-123',
        organizationId: 'org-123',
        role: Role.MEMBER,
        email: 'test@example.com',
      };
      const token = generateToken(payload);

      // Act
      const result = verifyToken(token);

      // Assert
      expect(result.userId).toBe('user-123');
      expect(result.organizationId).toBe('org-123');
      expect(result.role).toBe(Role.MEMBER);
      expect(result.email).toBe('test@example.com');
    });

    it('should throw error for invalid token', () => {
      // Arrange
      const invalidToken = 'invalid.token.here';

      // Act & Assert
      expect(() => verifyToken(invalidToken)).toThrow();
    });

    it('should throw error for token without organizationId', () => {
      // Arrange
      // Manually create a token without organizationId
      const payload = {
        userId: 'user-123',
        role: Role.MEMBER,
        email: 'test@example.com',
        // organizationId is missing
      };
      const token = jwt.sign(payload, 'test-secret-key-for-testing-purposes-only', {
        expiresIn: '1h',
      });

      // Act & Assert
      expect(() => verifyToken(token)).toThrow('Invalid token: missing organizationId');
    });

    it('should throw error for expired token', () => {
      // Arrange
      const payload = {
        userId: 'user-123',
        organizationId: 'org-123',
        role: Role.MEMBER,
        email: 'test@example.com',
      };
      // Create token that expires immediately
      const expiredToken = jwt.sign(payload, 'test-secret-key-for-testing-purposes-only', {
        expiresIn: '-1s', // Expired 1 second ago
      });

      // Act & Assert
      expect(() => verifyToken(expiredToken)).toThrow();
    });

    it('should throw error for token signed with different secret', () => {
      // Arrange
      const payload = {
        userId: 'user-123',
        organizationId: 'org-123',
        role: Role.MEMBER,
        email: 'test@example.com',
      };
      const token = jwt.sign(payload, 'different-secret-key', { expiresIn: '1h' });

      // Act & Assert
      expect(() => verifyToken(token)).toThrow();
    });

    it('should verify token with all role types', () => {
      // Test each role
      const roles = [Role.ADMIN, Role.TEAM_MANAGER, Role.MEMBER, Role.GUEST];

      roles.forEach((role) => {
        const payload = {
          userId: 'user-123',
          organizationId: 'org-123',
          role,
          email: 'test@example.com',
        };

        const token = generateToken(payload);
        const result = verifyToken(token);

        expect(result.role).toBe(role);
      });
    });

    it('should preserve all payload fields', () => {
      // Arrange
      const payload = {
        userId: 'user-special-123',
        organizationId: 'org-special-456',
        role: Role.TEAM_MANAGER,
        email: 'manager@special.com',
      };
      const token = generateToken(payload);

      // Act
      const result = verifyToken(token);

      // Assert
      expect(result).toMatchObject(payload);
    });

    it('should throw error for malformed token', () => {
      // Arrange
      const malformedTokens = [
        '',
        'abc',
        'a.b',
        'a.b.c.d.e',
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.invalid',
      ];

      // Act & Assert
      malformedTokens.forEach((token) => {
        expect(() => verifyToken(token)).toThrow();
      });
    });
  });

  describe('round trip', () => {
    it('should generate and verify token successfully', () => {
      // Arrange
      const payload = {
        userId: 'user-round-trip',
        organizationId: 'org-round-trip',
        role: Role.ADMIN,
        email: 'roundtrip@example.com',
      };

      // Act
      const token = generateToken(payload);
      const verified = verifyToken(token);

      // Assert
      expect(verified.userId).toBe(payload.userId);
      expect(verified.organizationId).toBe(payload.organizationId);
      expect(verified.role).toBe(payload.role);
      expect(verified.email).toBe(payload.email);
    });
  });
});
