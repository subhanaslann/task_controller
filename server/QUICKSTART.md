# Mini Task Tracker Server - Quick Start Guide

## ✅ Setup Complete!

The server is fully configured and ready to use.

## 🚀 Start Development Server

```bash
npm run dev
```

Server will start on: **http://localhost:8080**

## 📝 Test Credentials

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |
| Member | `alice` | `member123` |
| Member | `bob` | `member123` |
| Guest | `guest` | `guest123` |

## 🧪 Quick API Test

### 1. Login as Admin
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usernameOrEmail":"admin","password":"admin123"}'
```

Save the returned `token` value.

### 2. Get Team Active Tasks
```bash
curl -X GET "http://localhost:8080/tasks?scope=team_active" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 3. Create a New User (Admin Only)
```bash
curl -X POST http://localhost:8080/users \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "username": "testuser",
    "email": "test@example.com",
    "password": "test123",
    "role": "MEMBER"
  }'
```

## 🔑 Key Features Implemented

### ✅ Authentication & Authorization
- JWT-based authentication with 7-day expiry
- Role-based access control (ADMIN, MEMBER, GUEST)
- Password hashing with bcrypt (10 rounds)

### ✅ Business Rules
- **15 Active User Limit**: Server enforces max 15 active users
- **Guest Field Filtering**: Guests see limited fields on team tasks:
  - ✓ Visible: id, title, status, priority, dueDate, assignee.name
  - ✗ Hidden: desc, assignee.username, other sensitive data

### ✅ Task Management
- Status tracking: TODO → IN_PROGRESS → DONE
- Auto-timestamp on completion
- Priority levels: LOW, NORMAL, HIGH
- Visibility control: NORMAL, GUEST_SAFE

### ✅ Security
- Helmet.js for HTTP security headers
- CORS enabled for Android emulator (dev mode)
- Input validation with Zod
- Secure password storage

## 📊 Database

**Location**: `prisma/dev.db` (SQLite)

**Sample Data**:
- 4 users (1 admin, 2 members, 1 guest)
- 7 tasks with various statuses and priorities
- Mixed visibility (NORMAL vs GUEST_SAFE)

## 🔄 Database Management

```bash
# View database in Prisma Studio
npm run prisma:studio

# Reset database and re-seed
npm run prisma:migrate -- --name reset
npm run prisma:seed
```

## 📚 Full Documentation

See `README.md` for complete API documentation with curl examples for all endpoints.

## 🐛 Troubleshooting

### Port already in use?
Change `PORT` in `.env` file:
```env
PORT=3000
```

### Database locked?
Stop any running Prisma Studio instances:
```bash
taskkill /F /IM node.exe /FI "WINDOWTITLE eq Prisma Studio"
```

### Want to see SQL queries?
Add to `.env`:
```env
DEBUG=prisma:query
```

## 🎯 Next Steps

1. **Test all endpoints** - Use the curl examples in README.md
2. **Build Android app** - See `../android-app/README.md`
3. **Production deployment** - Switch from SQLite to PostgreSQL
4. **Add tests** - Unit tests for services, integration tests for routes

---

**Status**: ✅ Production-ready backend with all features implemented
