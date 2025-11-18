import { hashPassword, comparePassword } from '../../../src/utils/password';
import bcrypt from 'bcrypt';

describe('Password Utils', () => {
  describe('hashPassword', () => {
    it('should hash a password successfully', async () => {
      // Arrange
      const password = 'SecurePassword123!';

      // Act
      const hash = await hashPassword(password);

      // Assert
      expect(hash).toBeDefined();
      expect(typeof hash).toBe('string');
      expect(hash).not.toBe(password);
      expect(hash.length).toBeGreaterThan(password.length);
    });

    it('should generate different hashes for same password', async () => {
      // Arrange
      const password = 'SamePassword123';

      // Act
      const hash1 = await hashPassword(password);
      const hash2 = await hashPassword(password);

      // Assert
      // Due to salt, same password should generate different hashes
      expect(hash1).not.toBe(hash2);
    });

    it('should hash different passwords differently', async () => {
      // Arrange
      const password1 = 'Password1';
      const password2 = 'Password2';

      // Act
      const hash1 = await hashPassword(password1);
      const hash2 = await hashPassword(password2);

      // Assert
      expect(hash1).not.toBe(hash2);
    });

    it('should produce bcrypt compatible hash', async () => {
      // Arrange
      const password = 'TestPassword123';

      // Act
      const hash = await hashPassword(password);

      // Assert
      // Bcrypt hashes start with $2b$ and have specific format
      expect(hash).toMatch(/^\$2b\$/);
      expect(hash.split('$')).toHaveLength(4);
    });

    it('should handle empty password', async () => {
      // Arrange
      const password = '';

      // Act
      const hash = await hashPassword(password);

      // Assert
      expect(hash).toBeDefined();
      expect(hash.length).toBeGreaterThan(0);
    });

    it('should handle long passwords', async () => {
      // Arrange
      const password = 'A'.repeat(100);

      // Act
      const hash = await hashPassword(password);

      // Assert
      expect(hash).toBeDefined();
    });

    it('should handle special characters in password', async () => {
      // Arrange
      const password = '!@#$%^&*()_+-=[]{}|;:,.<>?';

      // Act
      const hash = await hashPassword(password);

      // Assert
      expect(hash).toBeDefined();
      // Should still be able to verify it
      const isValid = await bcrypt.compare(password, hash);
      expect(isValid).toBe(true);
    });

    it('should handle unicode characters in password', async () => {
      // Arrange
      const password = 'Пароль密码🔐';

      // Act
      const hash = await hashPassword(password);

      // Assert
      expect(hash).toBeDefined();
      const isValid = await bcrypt.compare(password, hash);
      expect(isValid).toBe(true);
    });
  });

  describe('comparePassword', () => {
    it('should return true for correct password', async () => {
      // Arrange
      const password = 'CorrectPassword123';
      const hash = await hashPassword(password);

      // Act
      const result = await comparePassword(password, hash);

      // Assert
      expect(result).toBe(true);
    });

    it('should return false for incorrect password', async () => {
      // Arrange
      const correctPassword = 'CorrectPassword';
      const wrongPassword = 'WrongPassword';
      const hash = await hashPassword(correctPassword);

      // Act
      const result = await comparePassword(wrongPassword, hash);

      // Assert
      expect(result).toBe(false);
    });

    it('should be case sensitive', async () => {
      // Arrange
      const password = 'CaseSensitive';
      const hash = await hashPassword(password);

      // Act
      const resultLower = await comparePassword('casesensitive', hash);
      const resultUpper = await comparePassword('CASESENSITIVE', hash);
      const resultCorrect = await comparePassword('CaseSensitive', hash);

      // Assert
      expect(resultLower).toBe(false);
      expect(resultUpper).toBe(false);
      expect(resultCorrect).toBe(true);
    });

    it('should return false for empty password against hash', async () => {
      // Arrange
      const password = 'ActualPassword';
      const hash = await hashPassword(password);

      // Act
      const result = await comparePassword('', hash);

      // Assert
      expect(result).toBe(false);
    });

    it('should return false for invalid hash format', async () => {
      // Arrange
      const password = 'TestPassword';
      const invalidHash = 'not-a-valid-hash';

      // Act & Assert
      await expect(comparePassword(password, invalidHash)).rejects.toThrow();
    });

    it('should handle special characters correctly', async () => {
      // Arrange
      const password = '!@#$%^&*()_+Pass';
      const hash = await hashPassword(password);

      // Act
      const resultCorrect = await comparePassword('!@#$%^&*()_+Pass', hash);
      const resultWrong = await comparePassword('!@#$%^&*()_Pass', hash);

      // Assert
      expect(resultCorrect).toBe(true);
      expect(resultWrong).toBe(false);
    });

    it('should handle unicode characters correctly', async () => {
      // Arrange
      const password = '密码🔐Test';
      const hash = await hashPassword(password);

      // Act
      const result = await comparePassword('密码🔐Test', hash);

      // Assert
      expect(result).toBe(true);
    });

    it('should work with long passwords', async () => {
      // Arrange
      const password = 'A'.repeat(100) + 'B'.repeat(100);
      const hash = await hashPassword(password);

      // Act
      const resultCorrect = await comparePassword(password, hash);
      const resultWrong = await comparePassword('A'.repeat(200), hash);

      // Assert
      expect(resultCorrect).toBe(true);
      expect(resultWrong).toBe(false);
    });

    it('should detect subtle password differences', async () => {
      // Arrange
      const password = 'Password123';
      const hash = await hashPassword(password);

      // Act
      const tests = [
        { password: 'Password123 ', expected: false }, // Extra space
        { password: ' Password123', expected: false }, // Leading space
        { password: 'Password124', expected: false }, // Different last char
        { password: 'password123', expected: false }, // Different case
        { password: 'Password123', expected: true }, // Correct
      ];

      // Assert
      for (const test of tests) {
        const result = await comparePassword(test.password, hash);
        expect(result).toBe(test.expected);
      }
    });
  });

  describe('round trip', () => {
    it('should hash and verify password successfully', async () => {
      // Arrange
      const password = 'RoundTripPassword123!';

      // Act
      const hash = await hashPassword(password);
      const isValid = await comparePassword(password, hash);

      // Assert
      expect(isValid).toBe(true);
    });

    it('should work for multiple different passwords', async () => {
      // Arrange
      const passwords = [
        'Simple123',
        'Complex!@#$%Password',
        'Unicode密码🔐',
        'Long' + 'A'.repeat(100),
        '',
      ];

      // Act & Assert
      for (const password of passwords) {
        const hash = await hashPassword(password);
        const isValid = await comparePassword(password, hash);
        expect(isValid).toBe(true);

        // Also test that wrong password fails
        const isInvalid = await comparePassword(password + 'wrong', hash);
        expect(isInvalid).toBe(false);
      }
    });
  });
});
