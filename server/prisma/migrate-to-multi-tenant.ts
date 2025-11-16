import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function migrateToMultiTenant() {
  console.log('🔄 Starting migration to multi-tenant structure...\n');

  try {
    // Step 1: Create default organization
    console.log('1️⃣  Creating default organization...');
    const defaultOrg = await prisma.organization.create({
      data: {
        name: 'Default Organization',
        teamName: 'Default Team',
        slug: 'default',
        isActive: true,
        maxUsers: 15,
      },
    });
    console.log(`   ✓ Created organization: ${defaultOrg.name} (ID: ${defaultOrg.id})`);

    // Step 2: Get all existing users
    console.log('\n2️⃣  Migrating users to default organization...');
    const users = await prisma.user.findMany();
    console.log(`   Found ${users.length} users to migrate`);

    let migratedUsers = 0;
    for (const user of users) {
      await prisma.user.update({
        where: { id: user.id },
        data: {
          organizationId: defaultOrg.id,
          // Convert ADMIN to TEAM_MANAGER for the default org
          role: user.role === 'ADMIN' ? 'TEAM_MANAGER' : user.role,
        },
      });
      migratedUsers++;
      console.log(`   ✓ Migrated user: ${user.username} (${user.role})`);
    }
    console.log(`   ✓ Migrated ${migratedUsers} users`);

    // Step 3: Migrate all tasks
    console.log('\n3️⃣  Migrating tasks to default organization...');
    const tasks = await prisma.task.findMany();
    console.log(`   Found ${tasks.length} tasks to migrate`);

    let migratedTasks = 0;
    for (const task of tasks) {
      await prisma.task.update({
        where: { id: task.id },
        data: {
          organizationId: defaultOrg.id,
        },
      });
      migratedTasks++;
    }
    console.log(`   ✓ Migrated ${migratedTasks} tasks`);

    // Step 4: Migrate all topics
    console.log('\n4️⃣  Migrating topics to default organization...');
    const topics = await prisma.topic.findMany();
    console.log(`   Found ${topics.length} topics to migrate`);

    let migratedTopics = 0;
    for (const topic of topics) {
      await prisma.topic.update({
        where: { id: topic.id },
        data: {
          organizationId: defaultOrg.id,
        },
      });
      migratedTopics++;
    }
    console.log(`   ✓ Migrated ${migratedTopics} topics`);

    // Step 5: Verify data integrity
    console.log('\n5️⃣  Verifying data integrity...');

    const orgUsers = await prisma.user.count({
      where: { organizationId: defaultOrg.id },
    });

    const orgTasks = await prisma.task.count({
      where: { organizationId: defaultOrg.id },
    });

    const orgTopics = await prisma.topic.count({
      where: { organizationId: defaultOrg.id },
    });

    console.log(`   ✓ Organization has ${orgUsers} users`);
    console.log(`   ✓ Organization has ${orgTasks} tasks`);
    console.log(`   ✓ Organization has ${orgTopics} topics`);

    // Step 6: Display summary
    console.log('\n✅ Migration completed successfully!');
    console.log('\n📊 Migration Summary:');
    console.log(`   Organization: ${defaultOrg.name}`);
    console.log(`   Slug: ${defaultOrg.slug}`);
    console.log(`   Users: ${migratedUsers}`);
    console.log(`   Tasks: ${migratedTasks}`);
    console.log(`   Topics: ${migratedTopics}`);
    console.log('\n⚠️  Note: All ADMIN users have been converted to TEAM_MANAGER role.');
    console.log('   The application now supports multi-tenant architecture.');

  } catch (error) {
    console.error('\n❌ Migration failed:', error);
    throw error;
  }
}

// Run migration
migrateToMultiTenant()
  .catch((e) => {
    console.error('Migration error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
