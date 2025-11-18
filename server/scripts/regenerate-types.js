/**
 * Script to regenerate Prisma types and restart the development server
 * Run with: node scripts/regenerate-types.js
 */

const { execSync } = require('child_process');
const path = require('path');

console.log('🔄 Regenerating Prisma Client types...\n');

try {
    // Change to server directory
    process.chdir(path.join(__dirname, '..'));

    // Generate Prisma Client
    console.log('📦 Running prisma generate...');
    execSync('npx prisma generate', { stdio: 'inherit' });

    console.log('\n✅ Prisma types regenerated successfully!');
    console.log('\n💡 To apply changes:');
    console.log('   1. Restart your TypeScript language server (VS Code: Ctrl+Shift+P > "TypeScript: Restart TS Server")');
    console.log('   2. Or restart your IDE');
    console.log('   3. Then run: npm run dev');

} catch (error) {
    console.error('\n❌ Error regenerating types:', error.message);
    process.exit(1);
}
