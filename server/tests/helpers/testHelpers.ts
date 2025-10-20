import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

export const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL || 'file:./test.db',
    },
  },
});

export async function setupTestDatabase() {
  // Clean database
  await prisma.task.deleteMany();
  await prisma.user.deleteMany();

  // Create test users
  const hashedPassword = await bcrypt.hash('test123', 10);

  const admin = await prisma.user.create({
    data: {
      username: 'admin',
      email: 'admin@test.com',
      password: hashedPassword,
      name: 'Admin User',
      role: 'ADMIN',
      isActive: true,
    },
  });

  const member1 = await prisma.user.create({
    data: {
      username: 'alice',
      email: 'alice@test.com',
      password: hashedPassword,
      name: 'Alice Member',
      role: 'MEMBER',
      isActive: true,
    },
  });

  const member2 = await prisma.user.create({
    data: {
      username: 'bob',
      email: 'bob@test.com',
      password: hashedPassword,
      name: 'Bob Member',
      role: 'MEMBER',
      isActive: true,
    },
  });

  const guest = await prisma.user.create({
    data: {
      username: 'guest',
      email: 'guest@test.com',
      password: hashedPassword,
      name: 'Guest User',
      role: 'GUEST',
      isActive: true,
    },
  });

  // Create test tasks
  const task1 = await prisma.task.create({
    data: {
      title: 'Alice Task - Todo',
      desc: 'Secret description for Alice',
      status: 'TODO',
      priority: 'HIGH',
      assigneeId: member1.id,
      createdBy: admin.id,
    },
  });

  const task2 = await prisma.task.create({
    data: {
      title: 'Bob Task - In Progress',
      desc: 'Secret description for Bob',
      status: 'IN_PROGRESS',
      priority: 'MEDIUM',
      assigneeId: member2.id,
      createdBy: admin.id,
    },
  });

  const task3 = await prisma.task.create({
    data: {
      title: 'Alice Task - Done',
      desc: 'Completed task',
      status: 'DONE',
      priority: 'LOW',
      assigneeId: member1.id,
      createdBy: admin.id,
    },
  });

  return { admin, member1, member2, guest, task1, task2, task3 };
}

export async function cleanupTestDatabase() {
  await prisma.task.deleteMany();
  await prisma.user.deleteMany();
}

export async function disconnectDatabase() {
  await prisma.$disconnect();
}
