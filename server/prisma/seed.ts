import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

const SALT_ROUNDS = 10;

async function main() {
  console.log('🌱 Seeding database...');

  // Clear existing data
  await prisma.task.deleteMany();
  await prisma.topic.deleteMany();
  await prisma.user.deleteMany();

  // Create users
  const adminPasswordHash = await bcrypt.hash('admin123', SALT_ROUNDS);
  const guestPasswordHash = await bcrypt.hash('guest123', SALT_ROUNDS);
  const memberPasswordHash = await bcrypt.hash('member123', SALT_ROUNDS);

  await prisma.user.create({
    data: {
      name: 'Admin User',
      username: 'admin',
      email: 'admin@minitasktracker.local',
      passwordHash: adminPasswordHash,
      role: 'ADMIN',
      active: true,
    },
  });

  const member1 = await prisma.user.create({
    data: {
      name: 'Alice Johnson',
      username: 'alice',
      email: 'alice@minitasktracker.local',
      passwordHash: memberPasswordHash,
      role: 'MEMBER',
      active: true,
    },
  });

  const member2 = await prisma.user.create({
    data: {
      name: 'Bob Smith',
      username: 'bob',
      email: 'bob@minitasktracker.local',
      passwordHash: memberPasswordHash,
      role: 'MEMBER',
      active: true,
    },
  });

  await prisma.user.create({
    data: {
      name: 'Guest User',
      username: 'guest',
      email: 'guest@minitasktracker.local',
      passwordHash: guestPasswordHash,
      role: 'GUEST',
      active: true,
    },
  });

  console.log('✓ Created users:');
  console.log('  - Admin (admin/admin123)');
  console.log('  - Alice Johnson (alice/member123)');
  console.log('  - Bob Smith (bob/member123)');
  console.log('  - Guest User (guest/guest123)');

  // Create topics
  const topic1 = await prisma.topic.create({
    data: {
      title: 'Backend Development',
      description: 'Tasks related to backend API and database development',
      isActive: true,
    },
  });

  const topic2 = await prisma.topic.create({
    data: {
      title: 'Frontend Development',
      description: 'UI/UX and mobile app development tasks',
      isActive: true,
    },
  });

  const topic3 = await prisma.topic.create({
    data: {
      title: 'DevOps',
      description: 'Deployment, CI/CD, and infrastructure tasks',
      isActive: true,
    },
  });

  await prisma.topic.create({
    data: {
      title: 'Archived Topic',
      description: 'This topic is inactive and should not appear in Team Active',
      isActive: false,
    },
  });

  console.log('✓ Created 4 topics (3 active, 1 inactive)');

  // Create sample tasks
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);

  const nextWeek = new Date();
  nextWeek.setDate(nextWeek.getDate() + 7);

  await prisma.task.create({
    data: {
      topicId: topic1.id,
      title: 'Setup development environment',
      note: 'Install all necessary tools and configure the development environment',
      assigneeId: member1.id,
      status: 'IN_PROGRESS',
      priority: 'HIGH',
      dueDate: tomorrow,
    },
  });

  await prisma.task.create({
    data: {
      topicId: topic1.id,
      title: 'Review API documentation',
      note: 'Go through the API documentation and test all endpoints',
      assigneeId: member1.id,
      status: 'TODO',
      priority: 'NORMAL',
      dueDate: nextWeek,
    },
  });

  await prisma.task.create({
    data: {
      topicId: topic1.id,
      title: 'Implement authentication flow',
      note: 'Complete the JWT authentication implementation with proper error handling',
      assigneeId: member2.id,
      status: 'TODO',
      priority: 'HIGH',
      dueDate: tomorrow,
    },
  });

  await prisma.task.create({
    data: {
      topicId: topic2.id,
      title: 'Update user interface',
      note: 'Make the UI more user-friendly and responsive',
      assigneeId: member2.id,
      status: 'IN_PROGRESS',
      priority: 'NORMAL',
      dueDate: nextWeek,
    },
  });

  await prisma.task.create({
    data: {
      topicId: topic1.id,
      title: 'Write unit tests',
      note: 'Add comprehensive unit tests for all services',
      assigneeId: member1.id,
      status: 'TODO',
      priority: 'LOW',
    },
  });

  await prisma.task.create({
    data: {
      topicId: topic1.id,
      title: 'Database optimization',
      note: 'Analyze and optimize database queries for better performance',
      assigneeId: member2.id,
      status: 'DONE',
      priority: 'NORMAL',
      completedAt: new Date(),
    },
  });

  await prisma.task.create({
    data: {
      topicId: topic3.id,
      title: 'Deploy to staging',
      note: 'Deploy the latest version to staging environment',
      status: 'TODO',
      priority: 'HIGH',
      dueDate: tomorrow,
    },
  });

  console.log('✓ Created 7 sample tasks');

  console.log('\n✅ Seeding completed successfully!');
  console.log('\n📝 Login credentials:');
  console.log('   Admin:  admin/admin123');
  console.log('   Member: alice/member123 or bob/member123');
  console.log('   Guest:  guest/guest123');
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
