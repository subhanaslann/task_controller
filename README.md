# Mini Task Tracker

A secure monorepo project with Android mobile app and Node.js backend for team task management.

## 🏗️ Architecture

- **android-app/**: Kotlin + Jetpack Compose mobile client
- **server/**: Node.js + Express + Prisma + SQLite backend

## 🔐 Security & Features

- **Authentication**: JWT-based (HTTPS in production, HTTP allowed in dev only)
- **Role-Based Access**: ADMIN, MEMBER, GUEST
- **User Limit**: Max 15 active users (server-enforced)
- **Guest Restrictions**: Limited field visibility on team tasks (server-side trimming)

## 📱 User Features

### Standard Screens (All Roles)
1. **My Active Tasks**: To-Do/In-Progress tasks; users can update their own status
2. **Team Active Tasks**: Read-only view of all active tasks (guests see limited fields)
3. **My Completed**: Read-only list of completed tasks

### Admin Mode (ADMIN only)
- **User Management**: Create, activate, deactivate, reset passwords, assign roles
- **Task Management**: Create, edit, delete tasks; assign to users; set priority/status; mark guest_safe

## 🚀 Quick Start

### 1. Backend Setup

```bash
cd server
npm install                 # Install dependencies
npm run prisma:generate     # Generate Prisma client
npm run prisma:migrate      # Run database migrations
npm run prisma:seed         # Seed with test data
npm run dev                 # Start development server
```

✅ **Server running at:** `http://localhost:8080`

🔑 **Test Credentials:**
| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |
| Member | `alice` | `member123` |
| Member | `bob` | `member123` |
| Guest | `guest` | `guest123` |

### 2. Android App Setup

```bash
cd android-app
./gradlew assembleDebug      # Build debug APK
./gradlew installDebug       # Install on connected device/emulator
```

**Or use Android Studio:**
1. Open `android-app/` in Android Studio
2. Wait for Gradle sync to complete
3. Select device/emulator
4. Click Run ▶️

📡 **Network Configuration:**
- **Debug builds:** Automatically points to `http://10.0.2.2:8080` (Android emulator → localhost)
- **Physical device:** Update `BuildConfig.BASE_URL` or use `http://<your-computer-ip>:8080`
- **Production:** HTTPS only (configured in release build)

🔒 **Security:**
- Debug: Cleartext HTTP allowed for local development
- Release: HTTPS enforced via network security config

## 🔌 API Endpoints

### Authentication
- `POST /auth/login` - Username/email + password

### Tasks
- `GET /tasks?scope=my_active` - User's active tasks
- `GET /tasks?scope=team_active` - All active tasks (filtered by role)
- `GET /tasks?scope=my_done` - User's completed tasks
- `PATCH /tasks/:id/status` - Update task status (own tasks or admin)

### Admin Only
- `POST /users` - Create user
- `PATCH /users/:id` - Update user (activate/deactivate/role/reset password)
- `POST /tasks` - Create task
- `PATCH /tasks/:id` - Update task
- `DELETE /tasks/:id` - Delete task

## 📝 Important Notes

### Security
- ✅ **No sign-up flow**: Admins create all user accounts (prevents spam)
- ✅ **No password reset**: Admins reset passwords manually (secure workflow)
- ✅ **Guest filtering**: Sensitive fields automatically hidden from GUEST role
- ✅ **Token security**: JWT stored in encrypted DataStore (Android)
- ✅ **Rate limiting**: 100 requests per 15 minutes per IP
- ✅ **HTTPS enforced**: Production builds require HTTPS
- ✅ **Ownership validation**: Users can only modify their own tasks (except ADMIN)

### Production Readiness
- ✅ **15 active user limit**: Server-enforced with clear error messages
- ✅ **Centralized error handling**: Consistent JSON format across all endpoints
- ✅ **Role-based access control**: ADMIN, MEMBER, GUEST with proper authorization
- ✅ **Pull-to-refresh**: All task lists support manual refresh
- ✅ **Empty states**: Clear messages when no data available
- ✅ **Loading states**: Skeleton loaders for better UX
- ✅ **Error recovery**: Retry buttons on all error states

## 📄 License

MIT - See LICENSE file
