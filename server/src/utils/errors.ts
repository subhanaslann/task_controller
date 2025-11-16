export class AppError extends Error {
  constructor(
    public code: string,
    public message: string,
    public statusCode: number = 400
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string = 'Unauthorized') {
    super('UNAUTHORIZED', message, 401);
    this.name = 'UnauthorizedError';
  }
}

export class ForbiddenError extends AppError {
  constructor(message: string = 'Forbidden') {
    super('FORBIDDEN', message, 403);
    this.name = 'ForbiddenError';
  }
}

export class NotFoundError extends AppError {
  constructor(message: string = 'Not found') {
    super('NOT_FOUND', message, 404);
    this.name = 'NotFoundError';
  }
}

export class ValidationError extends AppError {
  constructor(message: string = 'Validation failed') {
    super('VALIDATION_ERROR', message, 400);
    this.name = 'ValidationError';
  }
}

export class ConflictError extends AppError {
  constructor(message: string = 'Resource conflict') {
    super('CONFLICT', message, 409);
    this.name = 'ConflictError';
  }
}

// =====================================================
// Multi-Tenant Specific Errors
// =====================================================

export class OrganizationNotFoundError extends AppError {
  constructor(message: string = 'Organization not found') {
    super('ORGANIZATION_NOT_FOUND', message, 404);
    this.name = 'OrganizationNotFoundError';
  }
}

export class OrganizationInactiveError extends AppError {
  constructor(message: string = 'Organization is inactive') {
    super('ORGANIZATION_INACTIVE', message, 403);
    this.name = 'OrganizationInactiveError';
  }
}

export class OrganizationUserLimitReachedError extends AppError {
  constructor(maxUsers: number = 15) {
    super(
      'ORGANIZATION_USER_LIMIT_REACHED',
      `Your organization has reached the maximum of ${maxUsers} users`,
      403
    );
    this.name = 'OrganizationUserLimitReachedError';
  }
}

export class CrossOrganizationAccessError extends AppError {
  constructor(message: string = 'You do not have access to resources from another organization') {
    super('CROSS_ORGANIZATION_ACCESS', message, 403);
    this.name = 'CrossOrganizationAccessError';
  }
}
