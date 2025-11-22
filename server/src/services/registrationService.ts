import prisma from '../db/connection';
import { hashPassword } from '../utils/password';
import { generateToken } from '../utils/jwt';
import { ConflictError, ValidationError } from '../utils/errors';
import { RegisterTeamDto, RegisterTeamResponse } from '../types';
import { Role } from '../types';

/**
 * Generate a URL-friendly slug from company and team names
 */
function generateSlug(companyName: string, teamName: string): string {
  const combined = `${companyName}-${teamName}`;
  return combined
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, '') // Remove special characters
    .replace(/[\s_-]+/g, '-') // Replace spaces, underscores with single dash
    .replace(/^-+|-+$/g, ''); // Remove leading/trailing dashes
}

/**
 * Ensure slug is unique by appending a number if necessary
 */
async function ensureUniqueSlug(baseSlug: string): Promise<string> {
  let slug = baseSlug;
  let counter = 1;

  while (true) {
    const existing = await prisma.organization.findUnique({
      where: { slug },
    });

    if (!existing) {
      return slug;
    }

    slug = `${baseSlug}-${counter}`;
    counter++;
  }
}

/**
 * Check if email is already in use across all organizations
 */
async function isEmailTaken(email: string): Promise<boolean> {
  const existingUser = await prisma.user.findFirst({
    where: { email },
  });

  return !!existingUser;
}

/**
 * Register a new team (organization) with a team manager
 */
export async function registerTeamManager(data: RegisterTeamDto): Promise<RegisterTeamResponse> {
  const { companyName, teamName, managerName, username, email, password } = data;

  // 1. Validate that email is not already in use
  const emailTaken = await isEmailTaken(email);
  if (emailTaken) {
    throw new ConflictError('Email is already registered');
  }

  // 2. Validate username uniqueness
  const existingUser = await prisma.user.findFirst({
    where: { username },
  });
  if (existingUser) {
    throw new ConflictError('Username is already taken');
  }

  // 3. Generate unique slug
  const baseSlug = generateSlug(companyName, teamName);
  if (!baseSlug) {
    throw new ValidationError('Could not generate valid slug from company and team names');
  }
  const slug = await ensureUniqueSlug(baseSlug);

  // 4. Hash password
  const passwordHash = await hashPassword(password);

  // 5. Create organization and team manager in a transaction
  const result = await prisma.$transaction(async (tx) => {
    // Create organization
    const organization = await tx.organization.create({
      data: {
        name: companyName,
        teamName,
        slug,
        isActive: true,
        maxUsers: 15,
      },
    });

    // Create team manager user
    const user = await tx.user.create({
      data: {
        organizationId: organization.id,
        name: managerName,
        username, // Use provided username directly
        email,
        passwordHash,
        role: Role.TEAM_MANAGER,
        active: true,
      },
    });

    return { organization, user };
  });

  // 5. Generate JWT token
  const token = generateToken({
    userId: result.user.id,
    organizationId: result.organization.id,
    role: result.user.role as Role,
    email: result.user.email,
  });

  // 6. Return response
  return {
    organization: {
      id: result.organization.id,
      name: result.organization.name,
      teamName: result.organization.teamName,
      slug: result.organization.slug,
      isActive: result.organization.isActive,
      maxUsers: result.organization.maxUsers,
      createdAt: result.organization.createdAt,
      updatedAt: result.organization.updatedAt,
    },
    user: {
      id: result.user.id,
      organizationId: result.user.organizationId,
      name: result.user.name,
      username: result.user.username,
      email: result.user.email,
      role: result.user.role as Role,
      active: result.user.active,
      createdAt: result.user.createdAt,
      updatedAt: result.user.updatedAt,
    },
    token,
  };
}
