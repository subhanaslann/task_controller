import { HttpsError, FunctionsErrorCode } from 'firebase-functions/v2/https';

export class AppError extends Error {
  constructor(
    public code: FunctionsErrorCode,
    public message: string
  ) {
    super(message);
    this.name = 'AppError';
  }

  toHttpsError(): HttpsError {
    return new HttpsError(this.code, this.message);
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') {
    super('unauthenticated', message);
    this.name = 'UnauthorizedError';
  }
}

export class ForbiddenError extends AppError {
  constructor(message = 'Forbidden') {
    super('permission-denied', message);
    this.name = 'ForbiddenError';
  }
}

export class NotFoundError extends AppError {
  constructor(message = 'Not found') {
    super('not-found', message);
    this.name = 'NotFoundError';
  }
}

export class ValidationError extends AppError {
  constructor(message = 'Validation failed') {
    super('invalid-argument', message);
    this.name = 'ValidationError';
  }
}

export class ConflictError extends AppError {
  constructor(message = 'Resource conflict') {
    super('already-exists', message);
    this.name = 'ConflictError';
  }
}

export class OrganizationNotFoundError extends AppError {
  constructor(message = 'Organization not found') {
    super('not-found', message);
    this.name = 'OrganizationNotFoundError';
  }
}

export class OrganizationInactiveError extends AppError {
  constructor(message = 'Organization is inactive') {
    super('permission-denied', message);
    this.name = 'OrganizationInactiveError';
  }
}

export class OrganizationUserLimitReachedError extends AppError {
  constructor(maxUsers = 15) {
    super(
      'resource-exhausted',
      `Your organization has reached the maximum of ${maxUsers} users`
    );
    this.name = 'OrganizationUserLimitReachedError';
  }
}

export function handleError(error: unknown): HttpsError {
  if (error instanceof AppError) {
    return error.toHttpsError();
  }
  if (error instanceof HttpsError) {
    return error;
  }
  console.error('Unexpected error:', error);
  return new HttpsError('internal', 'An unexpected error occurred');
}
