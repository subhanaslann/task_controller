import { PrismaClient } from '@prisma/client';
import { hashPassword } from '../../src/utils/password';

export const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL || 'file:./test.db',
    },
  },
});

// Store test data IDs for use across tests
export const testData: {
  organizations: { [key: string]: any };
  users: { [key: string]: any };
  topics: { [key: string]: any };
  tasks: { [key: string]: any };
} = {
  organizations: {},
  users: {},
  topics: {},
  tasks: {},
};

export async function setupTestDatabase() {
  // Clean database in correct order (respecting foreign keys)
  await prisma.guestTopicAccess.deleteMany();
  await prisma.task.deleteMany();
  await prisma.topic.deleteMany();
  await prisma.user.deleteMany();
  await prisma.organization.deleteMany();

  // Hash passwords once
  const managerPassword = await hashPassword('manager123');
  const memberPassword = await hashPassword('member123');
  const guestPassword = await hashPassword('guest123');

  // ===== ORGANIZATION 1: Acme Corporation =====
  const acmeOrg = await prisma.organization.create({
    data: {
      name: 'Acme Corporation',
      teamName: 'Engineering Team',
      slug: 'acme-engineering',
      isActive: true,
      maxUsers: 15,
    },
  });
  testData.organizations.acme = acmeOrg;

  // Acme Users
  const johnManager = await prisma.user.create({
    data: {
      organizationId: acmeOrg.id,
      name: 'John Manager',
      username: 'john',
      email: 'john@acme.com',
      passwordHash: managerPassword,
      role: 'TEAM_MANAGER',
      active: true,
    },
  });
  testData.users.johnManager = johnManager;

  const aliceJohnson = await prisma.user.create({
    data: {
      organizationId: acmeOrg.id,
      name: 'Alice Johnson',
      username: 'alice',
      email: 'alice@acme.com',
      passwordHash: memberPassword,
      role: 'MEMBER',
      active: true,
    },
  });
  testData.users.aliceJohnson = aliceJohnson;

  const bobSmith = await prisma.user.create({
    data: {
      organizationId: acmeOrg.id,
      name: 'Bob Smith',
      username: 'bob',
      email: 'bob@acme.com',
      passwordHash: memberPassword,
      role: 'MEMBER',
      active: true,
    },
  });
  testData.users.bobSmith = bobSmith;

  const charlieGuest = await prisma.user.create({
    data: {
      organizationId: acmeOrg.id,
      name: 'Charlie Guest',
      username: 'charlie',
      email: 'charlie@acme.com',
      passwordHash: guestPassword,
      role: 'GUEST',
      active: true,
    },
  });
  testData.users.charlieGuest = charlieGuest;

  // Acme Topics
  const acmeBackendTopic = await prisma.topic.create({
    data: {
      organizationId: acmeOrg.id,
      title: 'Backend Development',
      description: 'API and database development tasks',
      isActive: true,
    },
  });
  testData.topics.acmeBackend = acmeBackendTopic;

  const acmeFrontendTopic = await prisma.topic.create({
    data: {
      organizationId: acmeOrg.id,
      title: 'Frontend Development',
      description: 'UI/UX and client-side development',
      isActive: true,
    },
  });
  testData.topics.acmeFrontend = acmeFrontendTopic;

  // Acme Tasks
  const acmeTask1 = await prisma.task.create({
    data: {
      organizationId: acmeOrg.id,
      topicId: acmeBackendTopic.id,
      title: 'Implement user authentication',
      note: 'Add JWT-based authentication',
      assigneeId: aliceJohnson.id,
      status: 'TODO',
      priority: 'HIGH',
      dueDate: new Date('2025-12-31'),
    },
  });
  testData.tasks.acmeTask1 = acmeTask1;

  const acmeTask2 = await prisma.task.create({
    data: {
      organizationId: acmeOrg.id,
      topicId: acmeBackendTopic.id,
      title: 'Setup database schema',
      note: 'Design and implement database models',
      assigneeId: bobSmith.id,
      status: 'IN_PROGRESS',
      priority: 'HIGH',
      dueDate: new Date('2025-11-30'),
    },
  });
  testData.tasks.acmeTask2 = acmeTask2;

  const acmeTask3 = await prisma.task.create({
    data: {
      organizationId: acmeOrg.id,
      topicId: acmeFrontendTopic.id,
      title: 'Design landing page',
      note: 'Create mockups for homepage',
      assigneeId: aliceJohnson.id,
      status: 'DONE',
      priority: 'NORMAL',
      completedAt: new Date('2025-11-10'),
    },
  });
  testData.tasks.acmeTask3 = acmeTask3;

  // Guest access for Charlie
  await prisma.guestTopicAccess.create({
    data: {
      userId: charlieGuest.id,
      topicId: acmeBackendTopic.id,
    },
  });

  // ===== ORGANIZATION 2: Tech Startup Inc =====
  const techOrg = await prisma.organization.create({
    data: {
      name: 'Tech Startup Inc',
      teamName: 'Product Team',
      slug: 'tech-startup-product',
      isActive: true,
      maxUsers: 15,
    },
  });
  testData.organizations.tech = techOrg;

  // Tech Users
  const sarahManager = await prisma.user.create({
    data: {
      organizationId: techOrg.id,
      name: 'Sarah Manager',
      username: 'sarah',
      email: 'sarah@techstartup.com',
      passwordHash: managerPassword,
      role: 'TEAM_MANAGER',
      active: true,
    },
  });
  testData.users.sarahManager = sarahManager;

  const davidDeveloper = await prisma.user.create({
    data: {
      organizationId: techOrg.id,
      name: 'David Developer',
      username: 'david',
      email: 'david@techstartup.com',
      passwordHash: memberPassword,
      role: 'MEMBER',
      active: true,
    },
  });
  testData.users.davidDeveloper = davidDeveloper;

  const emmaEngineer = await prisma.user.create({
    data: {
      organizationId: techOrg.id,
      name: 'Emma Engineer',
      username: 'emma',
      email: 'emma@techstartup.com',
      passwordHash: memberPassword,
      role: 'MEMBER',
      active: true,
    },
  });
  testData.users.emmaEngineer = emmaEngineer;

  const frankConsultant = await prisma.user.create({
    data: {
      organizationId: techOrg.id,
      name: 'Frank Consultant',
      username: 'frank',
      email: 'frank@consultant.com',
      passwordHash: guestPassword,
      role: 'GUEST',
      active: true,
    },
  });
  testData.users.frankConsultant = frankConsultant;

  // Tech Topics
  const techMobileTopic = await prisma.topic.create({
    data: {
      organizationId: techOrg.id,
      title: 'Mobile App Development',
      description: 'iOS and Android app development',
      isActive: true,
    },
  });
  testData.topics.techMobile = techMobileTopic;

  const techDevOpsTopic = await prisma.topic.create({
    data: {
      organizationId: techOrg.id,
      title: 'DevOps',
      description: 'Infrastructure and deployment',
      isActive: true,
    },
  });
  testData.topics.techDevOps = techDevOpsTopic;

  // Tech Tasks
  const techTask1 = await prisma.task.create({
    data: {
      organizationId: techOrg.id,
      topicId: techMobileTopic.id,
      title: 'Build iOS app',
      note: 'Implement core features for iOS',
      assigneeId: davidDeveloper.id,
      status: 'TODO',
      priority: 'HIGH',
    },
  });
  testData.tasks.techTask1 = techTask1;

  const techTask2 = await prisma.task.create({
    data: {
      organizationId: techOrg.id,
      topicId: techMobileTopic.id,
      title: 'Build Android app',
      note: 'Implement core features for Android',
      assigneeId: emmaEngineer.id,
      status: 'IN_PROGRESS',
      priority: 'HIGH',
    },
  });
  testData.tasks.techTask2 = techTask2;

  const techTask3 = await prisma.task.create({
    data: {
      organizationId: techOrg.id,
      topicId: techDevOpsTopic.id,
      title: 'Setup CI/CD pipeline',
      note: 'Configure automated deployment',
      assigneeId: davidDeveloper.id,
      status: 'TODO',
      priority: 'NORMAL',
    },
  });
  testData.tasks.techTask3 = techTask3;

  const techTask4 = await prisma.task.create({
    data: {
      organizationId: techOrg.id,
      topicId: techDevOpsTopic.id,
      title: 'Configure monitoring',
      note: 'Setup application monitoring',
      assigneeId: emmaEngineer.id,
      status: 'DONE',
      priority: 'NORMAL',
      completedAt: new Date('2025-11-05'),
    },
  });
  testData.tasks.techTask4 = techTask4;

  // Guest access for Frank
  await prisma.guestTopicAccess.create({
    data: {
      userId: frankConsultant.id,
      topicId: techMobileTopic.id,
    },
  });

  // ===== ORGANIZATION 3: Design Agency =====
  const designOrg = await prisma.organization.create({
    data: {
      name: 'Design Agency',
      teamName: 'Creative Team',
      slug: 'design-agency-creative',
      isActive: true,
      maxUsers: 15,
    },
  });
  testData.organizations.design = designOrg;

  // Design Users
  const lisaDesigner = await prisma.user.create({
    data: {
      organizationId: designOrg.id,
      name: 'Lisa Designer',
      username: 'lisa',
      email: 'lisa@designagency.com',
      passwordHash: managerPassword,
      role: 'TEAM_MANAGER',
      active: true,
    },
  });
  testData.users.lisaDesigner = lisaDesigner;

  const markCreative = await prisma.user.create({
    data: {
      organizationId: designOrg.id,
      name: 'Mark Creative',
      username: 'mark',
      email: 'mark@designagency.com',
      passwordHash: memberPassword,
      role: 'MEMBER',
      active: true,
    },
  });
  testData.users.markCreative = markCreative;

  // Design Topics
  const designClientTopic = await prisma.topic.create({
    data: {
      organizationId: designOrg.id,
      title: 'Client Projects',
      description: 'Active client design projects',
      isActive: true,
    },
  });
  testData.topics.designClient = designClientTopic;

  // Design Tasks
  const designTask1 = await prisma.task.create({
    data: {
      organizationId: designOrg.id,
      topicId: designClientTopic.id,
      title: 'Create brand identity',
      note: 'Design logo and brand guidelines',
      assigneeId: lisaDesigner.id,
      status: 'IN_PROGRESS',
      priority: 'HIGH',
    },
  });
  testData.tasks.designTask1 = designTask1;

  return testData;
}

export async function cleanupTestDatabase() {
  await prisma.guestTopicAccess.deleteMany();
  await prisma.task.deleteMany();
  await prisma.topic.deleteMany();
  await prisma.user.deleteMany();
  await prisma.organization.deleteMany();
}

export async function disconnectDatabase() {
  await prisma.$disconnect();
}
