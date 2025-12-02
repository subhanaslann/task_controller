import * as admin from 'firebase-admin';
import { CallableRequest } from 'firebase-functions/v2/https';
import { UnauthorizedError, ForbiddenError, OrganizationInactiveError } from './errors';
import { Role } from './validation';

export interface AuthContext {
  uid: string;
  organizationId: string;
  role: Role;
  email: string;
}

export async function getAuthContext(request: CallableRequest): Promise<AuthContext> {
  if (!request.auth) {
    throw new UnauthorizedError('Authentication required');
  }

  const { uid } = request.auth;
  const claims = request.auth.token;

  if (!claims.organizationId || !claims.role) {
    throw new UnauthorizedError('Invalid token claims');
  }

  return {
    uid,
    organizationId: claims.organizationId as string,
    role: claims.role as Role,
    email: claims.email as string,
  };
}

export async function requireAuth(request: CallableRequest): Promise<AuthContext> {
  const context = await getAuthContext(request);

  // Check if organization is active
  const db = admin.firestore();
  const orgDoc = await db.collection('organizations').doc(context.organizationId).get();

  if (!orgDoc.exists) {
    throw new UnauthorizedError('Organization not found');
  }

  const orgData = orgDoc.data();
  if (!orgData?.isActive) {
    throw new OrganizationInactiveError('Your organization has been deactivated');
  }

  return context;
}

export function requireRole(context: AuthContext, ...allowedRoles: Role[]): void {
  if (!allowedRoles.includes(context.role)) {
    throw new ForbiddenError(`This action requires one of the following roles: ${allowedRoles.join(', ')}`);
  }
}

export function requireTeamManagerOrAdmin(context: AuthContext): void {
  requireRole(context, 'ADMIN', 'TEAM_MANAGER');
}

export function requireAdmin(context: AuthContext): void {
  requireRole(context, 'ADMIN');
}

export async function setCustomClaims(
  uid: string,
  organizationId: string,
  role: Role,
  email: string
): Promise<void> {
  await admin.auth().setCustomUserClaims(uid, {
    organizationId,
    role,
    email,
  });
}

export async function createCustomToken(
  uid: string,
  organizationId: string,
  role: Role
): Promise<string> {
  return admin.auth().createCustomToken(uid, {
    organizationId,
    role,
  });
}
