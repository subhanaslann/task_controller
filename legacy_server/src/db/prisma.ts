// Re-export the main Prisma client from connection.ts to avoid multiple instances
export { default as prisma, default } from './connection';
