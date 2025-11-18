import { validate } from '../../../src/middleware/validate';
import { z, ZodError } from 'zod';
import { createMockRequest, createMockResponse, createMockNext } from '../utils/testUtils';

describe('Validate Middleware', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should pass validation with valid data', async () => {
    // Arrange
    const schema = z.object({
      body: z.object({
        name: z.string(),
        email: z.string().email(),
      }),
    });

    const middleware = validate(schema);
    const req = createMockRequest({
      body: {
        name: 'John Doe',
        email: 'john@example.com',
      },
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    await middleware(req, res, next);

    // Assert
    expect(next).toHaveBeenCalledWith();
  });

  it('should fail validation with invalid data', async () => {
    // Arrange
    const schema = z.object({
      body: z.object({
        name: z.string(),
        email: z.string().email(),
      }),
    });

    const middleware = validate(schema);
    const req = createMockRequest({
      body: {
        name: 'John Doe',
        email: 'invalid-email',
      },
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    await middleware(req, res, next);

    // Assert
    expect(next).toHaveBeenCalledWith(expect.any(ZodError));
  });

  it('should validate query parameters', async () => {
    // Arrange
    const schema = z.object({
      query: z.object({
        page: z.string(),
        limit: z.string(),
      }),
    });

    const middleware = validate(schema);
    const req = createMockRequest({
      query: {
        page: '1',
        limit: '10',
      },
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    await middleware(req, res, next);

    // Assert
    expect(next).toHaveBeenCalledWith();
  });

  it('should validate route params', async () => {
    // Arrange
    const schema = z.object({
      params: z.object({
        id: z.string().uuid(),
      }),
    });

    const middleware = validate(schema);
    const req = createMockRequest({
      params: {
        id: '123e4567-e89b-12d3-a456-426614174000',
      },
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    await middleware(req, res, next);

    // Assert
    expect(next).toHaveBeenCalledWith();
  });

  it('should fail validation for invalid params', async () => {
    // Arrange
    const schema = z.object({
      params: z.object({
        id: z.string().uuid(),
      }),
    });

    const middleware = validate(schema);
    const req = createMockRequest({
      params: {
        id: 'not-a-uuid',
      },
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    await middleware(req, res, next);

    // Assert
    expect(next).toHaveBeenCalledWith(expect.any(ZodError));
  });

  it('should validate combined body, query, and params', async () => {
    // Arrange
    const schema = z.object({
      body: z.object({
        title: z.string().min(1),
      }),
      query: z.object({
        sort: z.string().optional(),
      }),
      params: z.object({
        id: z.string(),
      }),
    });

    const middleware = validate(schema);
    const req = createMockRequest({
      body: { title: 'Test Task' },
      query: { sort: 'asc' },
      params: { id: 'task-123' },
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    await middleware(req, res, next);

    // Assert
    expect(next).toHaveBeenCalledWith();
  });

  it('should handle missing required fields', async () => {
    // Arrange
    const schema = z.object({
      body: z.object({
        name: z.string(),
        email: z.string().email(),
      }),
    });

    const middleware = validate(schema);
    const req = createMockRequest({
      body: {
        name: 'John Doe',
        // email is missing
      },
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    await middleware(req, res, next);

    // Assert
    expect(next).toHaveBeenCalledWith(expect.any(ZodError));
  });

  it('should allow optional fields to be missing', async () => {
    // Arrange
    const schema = z.object({
      body: z.object({
        name: z.string(),
        email: z.string().email().optional(),
      }),
    });

    const middleware = validate(schema);
    const req = createMockRequest({
      body: {
        name: 'John Doe',
        // email is optional and missing
      },
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    await middleware(req, res, next);

    // Assert
    expect(next).toHaveBeenCalledWith();
  });

  it('should validate nested objects', async () => {
    // Arrange
    const schema = z.object({
      body: z.object({
        user: z.object({
          name: z.string(),
          profile: z.object({
            age: z.number().min(0),
          }),
        }),
      }),
    });

    const middleware = validate(schema);
    const req = createMockRequest({
      body: {
        user: {
          name: 'John',
          profile: {
            age: 25,
          },
        },
      },
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    await middleware(req, res, next);

    // Assert
    expect(next).toHaveBeenCalledWith();
  });

  it('should validate arrays', async () => {
    // Arrange
    const schema = z.object({
      body: z.object({
        topicIds: z.array(z.string()),
      }),
    });

    const middleware = validate(schema);
    const req = createMockRequest({
      body: {
        topicIds: ['topic-1', 'topic-2', 'topic-3'],
      },
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    await middleware(req, res, next);

    // Assert
    expect(next).toHaveBeenCalledWith();
  });

  it('should fail validation for invalid array items', async () => {
    // Arrange
    const schema = z.object({
      body: z.object({
        ages: z.array(z.number()),
      }),
    });

    const middleware = validate(schema);
    const req = createMockRequest({
      body: {
        ages: [25, 'not-a-number', 30],
      },
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    await middleware(req, res, next);

    // Assert
    expect(next).toHaveBeenCalledWith(expect.any(ZodError));
  });

  it('should validate string formats (email, url, etc)', async () => {
    // Arrange
    const schema = z.object({
      body: z.object({
        email: z.string().email(),
        website: z.string().url(),
      }),
    });

    const middleware = validate(schema);
    const req = createMockRequest({
      body: {
        email: 'test@example.com',
        website: 'https://example.com',
      },
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    await middleware(req, res, next);

    // Assert
    expect(next).toHaveBeenCalledWith();
  });

  it('should validate number constraints (min, max)', async () => {
    // Arrange
    const schema = z.object({
      body: z.object({
        age: z.number().min(18).max(100),
      }),
    });

    const middleware = validate(schema);
    const req = createMockRequest({
      body: {
        age: 25,
      },
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    await middleware(req, res, next);

    // Assert
    expect(next).toHaveBeenCalledWith();
  });

  it('should fail validation for number out of range', async () => {
    // Arrange
    const schema = z.object({
      body: z.object({
        age: z.number().min(18).max(100),
      }),
    });

    const middleware = validate(schema);
    const req = createMockRequest({
      body: {
        age: 150, // Exceeds max
      },
    });
    const res = createMockResponse();
    const next = createMockNext();

    // Act
    await middleware(req, res, next);

    // Assert
    expect(next).toHaveBeenCalledWith(expect.any(ZodError));
  });
});
