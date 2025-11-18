import bcrypt from 'bcrypt';
import crypto from 'crypto';

const SALT_ROUNDS = 10;
const BCRYPT_MAX_BYTES = 72;

/**
 * Pre-hash password with SHA-256 to overcome bcrypt's 72-byte limitation
 * This ensures long passwords are fully utilized and not truncated
 * Only applied to passwords longer than 72 bytes
 */
const preHashPassword = (password: string): string => {
  // Check if password exceeds bcrypt's limit
  const passwordBytes = Buffer.byteLength(password, 'utf8');

  if (passwordBytes > BCRYPT_MAX_BYTES) {
    // Use SHA-256 for long passwords
    return crypto.createHash('sha256').update(password).digest('hex');
  }

  // Return as-is for shorter passwords (bcrypt compatible)
  return password;
};

export const hashPassword = async (password: string): Promise<string> => {
  const processedPassword = preHashPassword(password);
  return bcrypt.hash(processedPassword, SALT_ROUNDS);
};

export const comparePassword = async (
  password: string,
  hash: string
): Promise<boolean> => {
  // Validate hash format (bcrypt hashes are 60 characters: $2a/b/y$ + 2 digits + $ + 53 chars)
  const bcryptHashRegex = /^\$2[aby]\$\d{2}\$.{53}$/;

  if (!bcryptHashRegex.test(hash)) {
    throw new Error('Invalid hash format');
  }

  try {
    const processedPassword = preHashPassword(password);
    return await bcrypt.compare(processedPassword, hash);
  } catch (error) {
    // bcrypt.compare can throw for malformed hashes that pass regex
    throw new Error('Invalid hash format');
  }
};
