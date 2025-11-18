import { PrismaClient } from '@prisma/client';
import { mockDeep, mockReset, DeepMockProxy } from 'jest-mock-extended';

// Create a deep mock of PrismaClient
export const prismaMock = mockDeep<PrismaClient>();

// Reset mock before each test
beforeEach(() => {
  mockReset(prismaMock);
});

// Export the mock as default
export default prismaMock;

// Type definition for the mock
export type MockPrismaClient = DeepMockProxy<PrismaClient>;
