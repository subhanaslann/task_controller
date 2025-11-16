import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

const SALT_ROUNDS = 10;

async function main() {
  console.log('🌱 Seeding database...');

  // Clear existing data
  await prisma.guestTopicAccess.deleteMany();
  await prisma.task.deleteMany();
  await prisma.topic.deleteMany();
  await prisma.user.deleteMany();
  await prisma.organization.deleteMany();

  // Password hashes
  const managerPasswordHash = await bcrypt.hash('manager123', SALT_ROUNDS);
  const memberPasswordHash = await bcrypt.hash('member123', SALT_ROUNDS);
  const guestPasswordHash = await bcrypt.hash('guest123', SALT_ROUNDS);

  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  const nextWeek = new Date();
  nextWeek.setDate(nextWeek.getDate() + 7);

  // =====================================================
  // ORGANIZATION 1: Acme Corporation
  // =====================================================
  console.log('\n🏢 Creating Organization 1: Acme Corporation...');
  const acmeOrg = await prisma.organization.create({
    data: {
      name: 'Acme Corporation',
      teamName: 'Engineering Team',
      slug: 'acme-engineering',
      isActive: true,
      maxUsers: 15,
    },
  });

  // Acme Users
  await prisma.user.create({
    data: {
      organizationId: acmeOrg.id,
      name: 'John Manager',
      username: 'john',
      email: 'john@acme.com',
      passwordHash: managerPasswordHash,
      role: 'TEAM_MANAGER',
      active: true,
    },
  });

  const acmeMember1 = await prisma.user.create({
    data: {
      organizationId: acmeOrg.id,
      name: 'Alice Johnson',
      username: 'alice',
      email: 'alice@acme.com',
      passwordHash: memberPasswordHash,
      role: 'MEMBER',
      active: true,
    },
  });

  const acmeMember2 = await prisma.user.create({
    data: {
      organizationId: acmeOrg.id,
      name: 'Bob Smith',
      username: 'bob',
      email: 'bob@acme.com',
      passwordHash: memberPasswordHash,
      role: 'MEMBER',
      active: true,
    },
  });

  const acmeGuest = await prisma.user.create({
    data: {
      organizationId: acmeOrg.id,
      name: 'Charlie Guest',
      username: 'charlie',
      email: 'charlie@acme.com',
      passwordHash: guestPasswordHash,
      role: 'GUEST',
      active: true,
    },
  });

  // Acme Topics
  const acmeTopic1 = await prisma.topic.create({
    data: {
      organizationId: acmeOrg.id,
      title: 'Backend Development',
      description: 'API and database development tasks',
      isActive: true,
    },
  });

  const acmeTopic2 = await prisma.topic.create({
    data: {
      organizationId: acmeOrg.id,
      title: 'Frontend Development',
      description: 'UI/UX and client-side development',
      isActive: true,
    },
  });

  // Acme Tasks
  await prisma.task.createMany({
    data: [
      {
        organizationId: acmeOrg.id,
        topicId: acmeTopic1.id,
        title: 'Setup authentication API',
        note: 'Implement JWT-based authentication endpoints',
        assigneeId: acmeMember1.id,
        status: 'IN_PROGRESS',
        priority: 'HIGH',
        dueDate: tomorrow,
      },
      {
        organizationId: acmeOrg.id,
        topicId: acmeTopic1.id,
        title: 'Database schema design',
        note: 'Design the database schema for user management',
        assigneeId: acmeMember2.id,
        status: 'TODO',
        priority: 'HIGH',
        dueDate: nextWeek,
      },
      {
        organizationId: acmeOrg.id,
        topicId: acmeTopic2.id,
        title: 'Build login UI',
        note: 'Create responsive login page',
        assigneeId: acmeMember1.id,
        status: 'DONE',
        priority: 'NORMAL',
        completedAt: new Date(),
      },
    ],
  });

  // Guest topic access for Acme
  await prisma.guestTopicAccess.create({
    data: {
      userId: acmeGuest.id,
      topicId: acmeTopic2.id,
    },
  });

  console.log('✓ Created Acme Corporation with 4 users and 3 tasks');

  // =====================================================
  // ORGANIZATION 2: Tech Startup Inc
  // =====================================================
  console.log('\n🚀 Creating Organization 2: Tech Startup Inc...');
  const techOrg = await prisma.organization.create({
    data: {
      name: 'Tech Startup Inc',
      teamName: 'Product Team',
      slug: 'tech-startup-product',
      isActive: true,
      maxUsers: 15,
    },
  });

  // Tech Startup Users
  await prisma.user.create({
    data: {
      organizationId: techOrg.id,
      name: 'Sarah Manager',
      username: 'sarah',
      email: 'sarah@techstartup.com',
      passwordHash: managerPasswordHash,
      role: 'TEAM_MANAGER',
      active: true,
    },
  });

  const techMember1 = await prisma.user.create({
    data: {
      organizationId: techOrg.id,
      name: 'David Developer',
      username: 'david',
      email: 'david@techstartup.com',
      passwordHash: memberPasswordHash,
      role: 'MEMBER',
      active: true,
    },
  });

  const techMember2 = await prisma.user.create({
    data: {
      organizationId: techOrg.id,
      name: 'Emma Engineer',
      username: 'emma',
      email: 'emma@techstartup.com',
      passwordHash: memberPasswordHash,
      role: 'MEMBER',
      active: true,
    },
  });

  const techGuest = await prisma.user.create({
    data: {
      organizationId: techOrg.id,
      name: 'Frank Consultant',
      username: 'frank',
      email: 'frank@consultant.com',
      passwordHash: guestPasswordHash,
      role: 'GUEST',
      active: true,
    },
  });

  // Tech Startup Topics
  const techTopic1 = await prisma.topic.create({
    data: {
      organizationId: techOrg.id,
      title: 'Mobile App Development',
      description: 'iOS and Android app development',
      isActive: true,
    },
  });

  const techTopic2 = await prisma.topic.create({
    data: {
      organizationId: techOrg.id,
      title: 'DevOps',
      description: 'Infrastructure and deployment',
      isActive: true,
    },
  });

  // Tech Startup Tasks
  await prisma.task.createMany({
    data: [
      {
        organizationId: techOrg.id,
        topicId: techTopic1.id,
        title: 'Implement push notifications',
        note: 'Add Firebase Cloud Messaging for push notifications',
        assigneeId: techMember1.id,
        status: 'TODO',
        priority: 'HIGH',
        dueDate: tomorrow,
      },
      {
        organizationId: techOrg.id,
        topicId: techTopic1.id,
        title: 'App store submission',
        note: 'Prepare and submit app to App Store and Play Store',
        assigneeId: techMember2.id,
        status: 'IN_PROGRESS',
        priority: 'NORMAL',
        dueDate: nextWeek,
      },
      {
        organizationId: techOrg.id,
        topicId: techTopic2.id,
        title: 'Setup CI/CD pipeline',
        note: 'Configure automated testing and deployment',
        assigneeId: techMember1.id,
        status: 'TODO',
        priority: 'HIGH',
      },
      {
        organizationId: techOrg.id,
        topicId: techTopic2.id,
        title: 'Monitor server performance',
        note: 'Setup monitoring and alerting for production servers',
        status: 'TODO',
        priority: 'NORMAL',
      },
    ],
  });

  // Guest topic access for Tech Startup
  await prisma.guestTopicAccess.create({
    data: {
      userId: techGuest.id,
      topicId: techTopic1.id,
    },
  });

  console.log('✓ Created Tech Startup Inc with 4 users and 4 tasks');

  // =====================================================
  // ORGANIZATION 3: Design Agency (for backward compatibility testing)
  // =====================================================
  console.log('\n🎨 Creating Organization 3: Design Agency...');
  const designOrg = await prisma.organization.create({
    data: {
      name: 'Design Agency',
      teamName: 'Creative Team',
      slug: 'design-agency-creative',
      isActive: true,
      maxUsers: 15,
    },
  });

  const designManager = await prisma.user.create({
    data: {
      organizationId: designOrg.id,
      name: 'Lisa Designer',
      username: 'lisa',
      email: 'lisa@designagency.com',
      passwordHash: managerPasswordHash,
      role: 'TEAM_MANAGER',
      active: true,
    },
  });

  await prisma.user.create({
    data: {
      organizationId: designOrg.id,
      name: 'Mark Creative',
      username: 'mark',
      email: 'mark@designagency.com',
      passwordHash: memberPasswordHash,
      role: 'MEMBER',
      active: true,
    },
  });

  const designTopic = await prisma.topic.create({
    data: {
      organizationId: designOrg.id,
      title: 'Client Projects',
      description: 'Active client design projects',
      isActive: true,
    },
  });

  await prisma.task.create({
    data: {
      organizationId: designOrg.id,
      topicId: designTopic.id,
      title: 'Design new logo',
      note: 'Create logo concepts for new client',
      assigneeId: designManager.id,
      status: 'IN_PROGRESS',
      priority: 'HIGH',
      dueDate: tomorrow,
    },
  });

  console.log('✓ Created Design Agency with 2 users and 1 task');

  // Summary
  console.log('\n✅ Seeding completed successfully!');
  console.log('\n📊 Summary:');
  console.log('   Organizations: 3');
  console.log('   Total Users: 10');
  console.log('   Total Tasks: 8');
  console.log('   Total Topics: 5');

  console.log('\n📝 Login Credentials:');
  console.log('\n   🏢 Acme Corporation:');
  console.log('      Team Manager: john@acme.com / manager123');
  console.log('      Member:       alice@acme.com / member123');
  console.log('      Member:       bob@acme.com / member123');
  console.log('      Guest:        charlie@acme.com / guest123');

  console.log('\n   🚀 Tech Startup Inc:');
  console.log('      Team Manager: sarah@techstartup.com / manager123');
  console.log('      Member:       david@techstartup.com / member123');
  console.log('      Member:       emma@techstartup.com / member123');
  console.log('      Guest:        frank@consultant.com / guest123');

  console.log('\n   🎨 Design Agency:');
  console.log('      Team Manager: lisa@designagency.com / manager123');
  console.log('      Member:       mark@designagency.com / member123');
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
