# Type Regeneration Scripts

This document explains how to regenerate types after making changes to your database schema (Prisma) or data models (Dart).

## 🎯 When to Use These Scripts

Run these scripts when you:
- Add/modify fields in Prisma schema (`server/prisma/schema.prisma`)
- Add/modify Dart models with JSON serialization
- See TypeScript errors about missing Prisma fields
- See Dart errors about missing generated code
- After pulling changes that modified schemas

## 🚀 Quick Start - All Types at Once

### Windows (Recommended)

**PowerShell:**
```powershell
.\regenerate-all-types.ps1
```

**Command Prompt:**
```cmd
regenerate-all-types.bat
```

This will regenerate both backend (Prisma) and frontend (Dart) types in one command.

## 📦 Individual Components

### Backend (Server) - Prisma Types

**From server directory:**

**PowerShell:**
```powershell
.\scripts\regenerate-types.ps1
```

**NPM:**
```bash
cd server
npm run regenerate-types
# OR
npm run prisma:generate
```

**Direct command:**
```bash
cd server
npx prisma generate
```

### Frontend (Flutter) - Dart Code

**From flutter_app directory:**

**PowerShell:**
```powershell
.\scripts\regenerate-types.ps1
```

**Direct command:**
```bash
cd flutter_app
dart run build_runner build --delete-conflicting-outputs
```

## 🔄 After Running Scripts

To ensure IDE picks up the changes:

### Visual Studio Code

1. **TypeScript (Backend):**
   - Press `Ctrl + Shift + P`
   - Type and select: `TypeScript: Restart TS Server`

2. **Dart (Frontend):**
   - Press `Ctrl + Shift + P`
   - Type and select: `Dart: Restart Analysis Server`

### Alternative: Restart IDE
Simply restart your IDE/editor to reload all language servers.

## 🛠️ Troubleshooting

### TypeScript Errors Persist

1. Delete `node_modules/.prisma`:
   ```bash
   cd server
   rm -r node_modules/.prisma
   npx prisma generate
   ```

2. Restart TypeScript server in IDE

### Dart Errors Persist

1. Clean build artifacts:
   ```bash
   cd flutter_app
   dart run build_runner clean
   dart run build_runner build --delete-conflicting-outputs
   ```

2. Restart Dart Analysis Server in IDE

### Build Errors

If you get build errors:

1. Make sure all dependencies are installed:
   ```bash
   # Backend
   cd server
   npm install
   
   # Frontend
   cd flutter_app
   flutter pub get
   ```

2. Try deleting and regenerating:
   ```bash
   # Backend
   cd server
   rm -r node_modules/@prisma
   npm install
   npx prisma generate
   
   # Frontend  
   cd flutter_app
   rm -r .dart_tool/build
   dart run build_runner build --delete-conflicting-outputs
   ```

## 📝 What Gets Generated

### Backend (Prisma)
- TypeScript types for database models
- Prisma Client with type-safe queries
- Located in: `node_modules/.prisma/client/`

### Frontend (Dart)
- JSON serialization code (`.g.dart` files)
- Riverpod providers (`.g.dart` files)
- Retrofit API service implementations (`.g.dart` files)
- Located next to your source files with `.g.dart` extension

## 🔗 Related Commands

### Database Migrations
```bash
cd server
npm run prisma:migrate      # Create and apply migration
npm run prisma:studio       # Open database GUI
```

### Clean Build
```bash
# Backend
cd server
rm -r dist node_modules
npm install
npm run build

# Frontend
cd flutter_app
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## 💡 Best Practices

1. **Always commit schema changes** before running migrations
2. **Run type regeneration** immediately after schema changes
3. **Restart language servers** after regeneration
4. **Test both backend and frontend** after schema changes
5. **Share migrations** with team via version control

## 🆘 Still Having Issues?

If problems persist:

1. Check that your schema files are valid:
   - `server/prisma/schema.prisma`
   - `flutter_app/lib/data/models/*.dart`

2. Verify no syntax errors in your code

3. Try a full clean install:
   ```bash
   # Backend
   cd server
   rm -r node_modules
   npm install
   npx prisma generate
   
   # Frontend
   cd flutter_app
   flutter clean
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Restart your entire IDE
