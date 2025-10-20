# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Common Development Commands

### Server Development
Navigate to `server/` directory first:

```bash
cd server
```

**Essential Commands:**
- `npm run dev` - Start development server with hot reload (port 8080)
- `npm run build` - Build TypeScript to JavaScript
- `npm start` - Run production build
- `npm run prisma:migrate` - Apply database migrations
- `npm run prisma:seed` - Seed database with initial data (creates admin user)
- `npm run prisma:studio` - Open Prisma database browser
- `npm run prisma:generate` - Generate Prisma client after schema changes

**Database Management:**
- Database file: `prisma/dev.db` (SQLite)
- To reset database: `npm run prisma:migrate -- --name reset && npm run prisma:seed`

### Android Development
- Open `android-app/` folder in Android Studio
- Sync Gradle files when opening project
- Run on emulator or physical device via Android Studio

### Testing the API
Default test credentials after seeding:
- **Admin**: username `admin`, password `admin123`
- **Member**: username `alice`, password `member123`
- **Guest**: username `guest`, password `guest123`

Quick API test:
```bash
curl -X POST http://localhost:8080/auth/login -H "Content-Type: application/json" -d '{"usernameOrEmail":"admin","password":"admin123"}'
```

## Architecture Overview

### Monorepo Structure
- `server/` - Node.js + Express + Prisma + SQLite backend
- `android-app/` - Kotlin + Jetpack Compose mobile client (planned)

### Backend Architecture (server/)

**Tech Stack:**
- **Runtime**: Node.js with TypeScript
- **Framework**: Express.js with middleware layering
- **Database**: Prisma ORM with SQLite (dev), supports PostgreSQL/MySQL for production
- **Authentication**: JWT with bcrypt password hashing
- **Validation**: Zod schemas with custom middleware

**Code Organization:**
```
src/
├── routes/           # API route handlers (auth, tasks, users, adminTasks)
├── middleware/       # Auth, roles, validation, error handling
├── services/         # Business logic layer (authService, taskService, userService)
├── schemas/          # Zod validation schemas
├── utils/           # JWT, password, error utilities
├── config/          # Environment configuration
└── db/              # Prisma client setup
```

**Key Patterns:**
- **Layered architecture**: Routes → Services → Prisma
- **Role-based access control**: Admin/Member/Guest roles with middleware enforcement
- **Guest field filtering**: Server-side data trimming for restricted users
- **Error handling**: Centralized error middleware with structured responses

### Database Design

**Core Models:**
- `User`: id, name, username, email, passwordHash, role, active status
- `Task`: id, title, desc, assigneeId, status, priority, dueDate, visibility

**Business Rules Enforced:**
- Maximum 15 active users (server validation)
- Guest users see limited fields on team tasks (`visibility: "GUEST_SAFE"` vs `"NORMAL"`)
- Task status flow: TODO → IN_PROGRESS → DONE
- Priority levels: LOW, NORMAL, HIGH

### Authentication Flow
1. User submits username/email + password
2. Server verifies with bcrypt
3. JWT token issued (7-day expiry)
4. Token required for all protected endpoints
5. Role-based access enforced via middleware

### API Design Patterns
- **Scope-based task endpoints**: `GET /tasks?scope=my_active|team_active|my_done`
- **Admin-only routes**: Separate `/admin/tasks` endpoints
- **Status updates**: Dedicated `PATCH /tasks/:id/status` endpoint
- **Field filtering**: Automatic guest data trimming in responses

### Security Features
- Helmet.js security headers
- CORS configured for Android emulator in development
- Password hashing with 10 salt rounds
- Input validation on all endpoints
- SQL injection prevention via Prisma

### Development Environment
- **Server port**: 8080 (configurable via .env)
- **Database**: SQLite file at `prisma/dev.db`
- **Hot reload**: ts-node-dev for development
- **CORS**: Allows Android emulator (`10.0.2.2:8080`) in dev mode

### Android Integration Notes
- API base URL for emulator: `http://10.0.2.2:8080`
- API base URL for physical device: `http://<computer-ip>:8080`
- HTTP allowed in debug builds via network security config
- HTTPS enforced in production builds

## Key Files to Understand

- `server/src/index.ts` - Main Express app setup and middleware configuration
- `server/prisma/schema.prisma` - Database schema with User and Task models
- `server/src/services/` - Business logic for auth, tasks, and users
- `server/src/middleware/auth.ts` - JWT verification and user context
- `server/src/middleware/roles.ts` - Role-based access control
- `server/QUICKSTART.md` - Complete setup and testing guide