# Server - Mini Task Tracker

Node.js + Express + Prisma + SQLite backend for the Mini Task Tracker system.

## 🔧 Tech Stack

- **Runtime**: Node.js (v18+)
- **Framework**: Express
- **ORM**: Prisma
- **Database**: SQLite (production can use PostgreSQL/MySQL)
- **Authentication**: JWT (jsonwebtoken)
- **Validation**: Zod / express-validator
- **Security**: helmet, cors, bcrypt

## 📁 Project Structure (Planned)

```
server/
├── prisma/
│   ├── schema.prisma          # Database schema
│   ├── seed.ts                # Initial data (admin user)
│   └── migrations/
├── src/
│   ├── routes/
│   │   ├── auth.ts            # POST /auth/login
│   │   ├── tasks.ts           # Task CRUD + status updates
│   │   ├── users.ts           # Admin user management
│   │   └── index.ts
│   ├── middleware/
│   │   ├── auth.ts            # JWT verification
│   │   ├── roles.ts           # Role-based access control
│   │   ├── errorHandler.ts
│   │   └── validation.ts
│   ├── services/
│   │   ├── authService.ts     # Login, JWT generation
│   │   ├── taskService.ts     # Task logic + guest filtering
│   │   └── userService.ts     # User CRUD, 15-user limit check
│   ├── utils/
│   │   ├── jwt.ts
│   │   ├── password.ts        # bcrypt helpers
│   │   └── constants.ts       # Roles, status enums
│   └── index.ts               # Express app entry
├── .env.example
├── package.json
├── tsconfig.json
└── README.md
```

## 🗄️ Database Schema (Prisma)

### User Model
- `id` (UUID)
- `username` (unique)
- `email` (unique)
- `passwordHash`
- `role` (ADMIN | MEMBER | GUEST)
- `isActive` (boolean)
- `createdAt`, `updatedAt`

### Task Model
- `id` (UUID)
- `title`, `description`
- `status` (TODO | IN_PROGRESS | DONE)
- `priority` (LOW | MEDIUM | HIGH)
- `assignedUserId` (FK → User)
- `guestSafe` (boolean) - if false, guests see limited fields
- `createdById` (FK → User - admin who created)
- `createdAt`, `updatedAt`

## 🚀 Getting Started

### Prerequisites

- Node.js 18+ and npm/yarn/pnpm
- SQLite (included with Prisma)

### Installation

```bash
cd server
npm install
```

### Environment Setup

Create `.env` file:
```env
DATABASE_URL="file:./prisma/dev.db"
JWT_SECRET="your-super-secret-jwt-key-change-in-production"
JWT_EXPIRES_IN="7d"
PORT=3000
NODE_ENV="development"
MAX_ACTIVE_USERS=15
```

### Database Setup

```bash
# Generate Prisma client
npm run prisma:generate

# Run migrations
npm run prisma:migrate

# Seed database (creates admin user)
npm run seed
```

**Default Admin User**:
- Username: `admin`
- Email: `admin@minitasktracker.local`
- Password: `admin123`
- Role: `ADMIN`

### Run Development Server

```bash
npm run dev
```

Server runs on `http://localhost:3000`

### Production Build

```bash
npm run build
npm start
```

## 🔌 API Endpoints

### Authentication
- `POST /auth/login`
  - Body: `{ "username": "...", "password": "..." }` or `{ "email": "...", "password": "..." }`
  - Response: `{ "token": "...", "user": {...} }`

### Tasks
- `GET /tasks?scope=my_active` - User's To-Do + In-Progress tasks
- `GET /tasks?scope=team_active` - All active tasks (guests see limited fields)
- `GET /tasks?scope=my_done` - User's completed tasks
- `PATCH /tasks/:id/status` - Update task status
  - Body: `{ "status": "IN_PROGRESS" }`
  - Users can only update their own tasks; admins can update any

### Admin - Users
- `POST /users` - Create new user
  - Body: `{ "username": "...", "email": "...", "password": "...", "role": "MEMBER" }`
  - Enforces 15 active user limit
- `PATCH /users/:id` - Update user
  - Body: `{ "isActive": false, "role": "GUEST", "password": "newpass" }`

### Admin - Tasks
- `POST /tasks` - Create task
  - Body: `{ "title": "...", "description": "...", "assignedUserId": "...", "priority": "HIGH", "guestSafe": true }`
- `PATCH /tasks/:id` - Update task
- `DELETE /tasks/:id` - Delete task

## 🔐 Security Features

1. **Password Hashing**: bcrypt with salt rounds = 10
2. **JWT Authentication**: Verified on all protected routes
3. **Role-Based Access Control**: Middleware enforces ADMIN-only routes
4. **Guest Field Filtering**: Server strips sensitive fields for guests on team_active endpoint
5. **15 User Limit**: Enforced in user creation logic
6. **HTTPS**: Required in production (helmet + secure cookies)

## 🧪 Testing (To Be Implemented)

- Unit tests: Services, utilities
- Integration tests: API routes with test DB
- E2E tests: Full flows (login → task CRUD)

## 📦 Quick Start

```bash
# Install dependencies
npm install

# Generate Prisma client
npm run prisma:generate

# Run migrations
npm run prisma:migrate

# Seed database
npm run prisma:seed

# Start development server
npm run dev
```

Server will be running at `http://localhost:8080`

## ✨ Security Features

- **Helmet.js**: HTTP security headers
- **Rate Limiting**: 100 requests per 15 minutes per IP
- **CORS**: Configured for Android emulator in development
- **JWT Authentication**: Bearer token with 7-day expiry
- **bcrypt**: Password hashing with 10 salt rounds
- **Role-based Access Control**: ADMIN, MEMBER, GUEST
- **Guest Field Filtering**: Sensitive fields automatically removed for GUEST role
- **Ownership Validation**: Non-admin users can only update their own tasks

## 🧠 API Testing with cURL

### Authentication

#### Login (Admin)
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usernameOrEmail": "admin",
    "password": "admin123"
  }'
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "name": "Admin User",
    "username": "admin",
    "email": "admin@minitasktracker.local",
    "role": "ADMIN",
    "active": true
  }
}
```

#### Login (Guest)
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usernameOrEmail": "guest",
    "password": "guest123"
  }'
```

---

### Tasks (User Endpoints)

**Note:** Replace `$TOKEN` with your JWT token from login response.

#### Get My Active Tasks
```bash
curl -X GET "http://localhost:8080/tasks?scope=my_active" \
  -H "Authorization: Bearer $TOKEN"
```

**Response:**
```json
{
  "tasks": [
    {
      "id": "uuid",
      "title": "Setup development environment",
      "desc": "Install all necessary tools...",
      "assigneeId": "uuid",
      "status": "IN_PROGRESS",
      "priority": "HIGH",
      "dueDate": "2025-10-18T03:41:14.000Z",
      "visibility": "NORMAL",
      "createdAt": "2025-10-17T03:41:14.000Z",
      "updatedAt": "2025-10-17T03:41:14.000Z",
      "completedAt": null,
      "assignee": {
        "id": "uuid",
        "name": "Alice Johnson",
        "username": "alice"
      }
    }
  ]
}
```

#### Get Team Active Tasks (Member)
```bash
curl -X GET "http://localhost:8080/tasks?scope=team_active" \
  -H "Authorization: Bearer $TOKEN"
```

#### Get Team Active Tasks (Guest - Limited Fields)
```bash
# Login as guest first, then:
curl -X GET "http://localhost:8080/tasks?scope=team_active" \
  -H "Authorization: Bearer $GUEST_TOKEN"
```

**Response (Guest):**
```json
{
  "tasks": [
    {
      "id": "uuid",
      "title": "Review API documentation",
      "status": "TODO",
      "priority": "NORMAL",
      "dueDate": "2025-10-24T03:41:14.000Z",
      "assignee": {
        "id": "uuid",
        "name": "Alice Johnson"
      }
    }
  ]
}
```
*Note: Guests only see limited fields (no desc, no username, etc.)*

#### Get My Completed Tasks
```bash
curl -X GET "http://localhost:8080/tasks?scope=my_done" \
  -H "Authorization: Bearer $TOKEN"
```

#### Update Task Status
```bash
curl -X PATCH http://localhost:8080/tasks/{TASK_ID}/status \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "IN_PROGRESS"
  }'
```

**Valid status values:** `TODO`, `IN_PROGRESS`, `DONE`

---

### Admin Endpoints - Users

**Note:** Requires ADMIN role.

#### List All Users
```bash
curl -X GET http://localhost:8080/users \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

#### Get User by ID
```bash
curl -X GET http://localhost:8080/users/{USER_ID} \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

#### Create New User
```bash
curl -X POST http://localhost:8080/users \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "username": "john",
    "email": "john@example.com",
    "password": "secure123",
    "role": "MEMBER",
    "active": true
  }'
```

**Valid roles:** `ADMIN`, `MEMBER`, `GUEST`

**Response:**
```json
{
  "user": {
    "id": "uuid",
    "name": "John Doe",
    "username": "john",
    "email": "john@example.com",
    "role": "MEMBER",
    "active": true,
    "createdAt": "2025-10-17T03:41:14.000Z",
    "updatedAt": "2025-10-17T03:41:14.000Z"
  }
}
```

#### Update User
```bash
# Deactivate user
curl -X PATCH http://localhost:8080/users/{USER_ID} \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "active": false
  }'

# Change role
curl -X PATCH http://localhost:8080/users/{USER_ID} \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "role": "GUEST"
  }'

# Reset password
curl -X PATCH http://localhost:8080/users/{USER_ID} \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "password": "newpassword123"
  }'
```

---

### Admin Endpoints - Tasks

**Note:** Requires ADMIN role.

#### List All Tasks
```bash
curl -X GET http://localhost:8080/admin/tasks \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

#### Get Task by ID
```bash
curl -X GET http://localhost:8080/admin/tasks/{TASK_ID} \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

#### Create New Task
```bash
curl -X POST http://localhost:8080/admin/tasks \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "New Feature Development",
    "desc": "Implement the new user dashboard feature",
    "assigneeId": "USER_UUID",
    "status": "TODO",
    "priority": "HIGH",
    "dueDate": "2025-10-25T00:00:00.000Z",
    "visibility": "NORMAL"
  }'
```

**Valid values:**
- `status`: `TODO`, `IN_PROGRESS`, `DONE`
- `priority`: `LOW`, `NORMAL`, `HIGH`
- `visibility`: `NORMAL`, `GUEST_SAFE`

#### Update Task
```bash
curl -X PATCH http://localhost:8080/admin/tasks/{TASK_ID} \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Task Title",
    "priority": "LOW",
    "visibility": "GUEST_SAFE"
  }'
```

#### Delete Task
```bash
curl -X DELETE http://localhost:8080/admin/tasks/{TASK_ID} \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

**Response:**
```json
{
  "success": true
}
```

---

## 🧪 Complete Test Flow Example

```bash
# 1. Login as admin
ADMIN_TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usernameOrEmail":"admin","password":"admin123"}' | jq -r '.token')

# 2. Create a new user
curl -X POST http://localhost:8080/users \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name":"Test User",
    "username":"testuser",
    "email":"test@example.com",
    "password":"test123",
    "role":"MEMBER"
  }'

# 3. Login as the new user
USER_TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usernameOrEmail":"testuser","password":"test123"}' | jq -r '.token')

# 4. Get my active tasks
curl -X GET "http://localhost:8080/tasks?scope=my_active" \
  -H "Authorization: Bearer $USER_TOKEN"

# 5. Login as guest
GUEST_TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usernameOrEmail":"guest","password":"guest123"}' | jq -r '.token')

# 6. Get team tasks as guest (limited fields)
curl -X GET "http://localhost:8080/tasks?scope=team_active" \
  -H "Authorization: Bearer $GUEST_TOKEN"
```

---

## 🔗 Related

See main `README.md` at repository root for project overview.
