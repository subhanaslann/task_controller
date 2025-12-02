# Multi-Tenant Migration Guide

## Overview
This guide explains how to migrate your Mini Task Tracker backend from single-tenant to multi-tenant (multi-organization) architecture.

## What's Been Completed ✅

### 1. Database Schema Updates
- ✅ Created `Organization` model with fields: id, name, teamName, slug, isActive, maxUsers
- ✅ Added `Role` enum: ADMIN, TEAM_MANAGER, MEMBER, GUEST
- ✅ Added `organizationId` foreign key to User, Task, and Topic models
- ✅ Added cascading delete constraints for organization relationships
- ✅ Updated uniqueness constraints (username and email unique per organization)
- ✅ Added appropriate indexes for performance

### 2. Type System & Utilities
- ✅ Created comprehensive TypeScript types in `src/types/index.ts`
- ✅ Updated JWT payload to include `organizationId`, `role`, and `email`
- ✅ Added organization-specific error classes:
  - `OrganizationNotFoundError`
  - `OrganizationInactiveError`
  - `OrganizationUserLimitReachedError`
  - `CrossOrganizationAccessError`

### 3. Authentication & Authorization
- ✅ Updated `authService.ts` to:
  - Include organization in login response
  - Verify organization is active
  - Generate JWT with organizationId
- ✅ Updated `authenticate` middleware to:
  - Verify organization exists and is active
  - Extract organizationId from JWT
- ✅ Created `ensureOrganizationAccess` middleware to prevent cross-org data access
- ✅ Updated role middleware to support TEAM_MANAGER role
- ✅ Added helper functions: `isTeamManagerOrAdmin()`, `isAdmin()`

### 4. Registration System
- ✅ Created `registrationService.ts` with `registerTeamManager()` function
- ✅ Added registration validation schema
- ✅ Implemented slug generation and email uniqueness checks
- ✅ Created `/auth/register` endpoint

### 5. Organization Management
- ✅ Created `organizationService.ts` with full CRUD operations
- ✅ Created organization routes:
  - `GET /organization` - Get current org details
  - `PATCH /organization` - Update org (TEAM_MANAGER/ADMIN)
  - `GET /organization/stats` - Get usage statistics
  - `POST /organization/:id/activate` - Activate org (ADMIN)
  - `POST /organization/:id/deactivate` - Deactivate org (ADMIN)

### 6. Migration Scripts
- ✅ Created `prisma/migrate-to-multi-tenant.ts` for data migration
- ✅ Updated seed data to create 3 sample organizations

## What Still Needs To Be Done ⚠️

### Critical (Must be completed before testing)

1. **Update User Service** (`src/services/userService.ts`)
   - Add `organizationId` parameter to all methods
   - Enforce organization filtering in all Prisma queries
   - Update user limit enforcement to be per-organization
   - Prevent TEAM_MANAGER from creating ADMIN users

2. **Update Task Service** (`src/services/taskService.ts`)
   - Add `organizationId` parameter to all methods
   - Add organization filter to ALL queries
   - Validate assignees belong to same organization
   - Ensure guests only see allowed tasks

3. **Update Topic Service** (`src/services/topicService.ts`)
   - Add `organizationId` parameter to all methods
   - Add organization filter to ALL queries
   - Update guest access logic for organization scope

4. **Update All Route Files**
   - `src/routes/users.ts` - Pass organizationId to service calls
   - `src/routes/tasks.ts` - Add ensureOrganizationAccess middleware
   - `src/routes/adminTasks.ts` - Replace requireAdmin with requireTeamManagerOrAdmin
   - `src/routes/memberTasks.ts` - Pass organizationId
   - `src/routes/topics.ts` - Pass organizationId
   - `src/routes/adminTopics.ts` - Update role checks
   - `src/routes/auth.ts` - Already handles multi-tenant login

5. **Update App Registration** (`src/app.ts`)
   - Register registration routes: `app.use('/auth', registrationRoutes)`
   - Register organization routes: `app.use('/organization', organizationRoutes)`

6. **Update Environment Variables** (`.env.example`)
   - Add `DEFAULT_ORG_MAX_USERS=15`
   - Add `ALLOW_SELF_REGISTRATION=true`

## Migration Execution Steps

### Step 1: Backup Your Database
```bash
# Backup your current database
cp server/prisma/dev.db server/prisma/dev.db.backup
```

### Step 2: Generate Prisma Client
```bash
cd server
npm run prisma:generate
```

### Step 3: Create Migration
```bash
npx prisma migrate dev --name add_organizations
```

### Step 4: Run Data Migration
```bash
npm run ts-node prisma/migrate-to-multi-tenant.ts
```

This will:
- Create a "Default Organization"
- Assign all existing users to it
- Assign all existing tasks and topics to it
- Convert ADMIN users to TEAM_MANAGER

### Step 5: Update Package.json Scripts
Add these scripts to `package.json`:
```json
{
  "scripts": {
    "migrate:multi-tenant": "ts-node prisma/migrate-to-multi-tenant.ts"
  }
}
```

### Step 6: Run New Seed Data (Optional)
```bash
npm run prisma:seed
```

This creates 3 sample organizations with test data.

## Testing Checklist

### Registration Tests
- [ ] Can register new team with valid data
- [ ] Cannot register with duplicate email
- [ ] Cannot register with weak password
- [ ] Slug is generated correctly and uniquely

### Organization Isolation Tests
- [ ] User from Org A cannot see users from Org B
- [ ] User from Org A cannot see tasks from Org B
- [ ] User from Org A cannot update topics in Org B
- [ ] Direct ID manipulation fails (cross-org access)

### Role Permission Tests
- [ ] TEAM_MANAGER can create users in their org
- [ ] TEAM_MANAGER cannot create ADMIN users
- [ ] TEAM_MANAGER cannot access other orgs
- [ ] ADMIN can access all orgs (if needed)

### User Limit Tests
- [ ] Cannot create 16th user in same org
- [ ] Multiple orgs can each have 15 users
- [ ] Only active users count toward limit

### Login Tests
- [ ] Can login with email
- [ ] Token includes organizationId
- [ ] Cannot login if org is deactivated
- [ ] Response includes organization info

## New API Endpoints

### Registration
```
POST /auth/register
Body: {
  "companyName": "Acme Corp",
  "teamName": "Engineering",
  "managerName": "John Doe",
  "email": "john@acme.com",
  "password": "SecurePassword123"
}
```

### Organization Management
```
GET /organization
PATCH /organization
GET /organization/stats
POST /organization/:id/activate (ADMIN only)
POST /organization/:id/deactivate (ADMIN only)
```

## Updated Login Response
```json
{
  "token": "jwt.token.here",
  "user": {
    "id": "uuid",
    "organizationId": "org-uuid",
    "name": "John Doe",
    "email": "john@acme.com",
    "role": "TEAM_MANAGER",
    ...
  },
  "organization": {
    "id": "org-uuid",
    "name": "Acme Corp",
    "teamName": "Engineering",
    "slug": "acme-corp-engineering"
  }
}
```

## Security Considerations

### Critical Security Rules
1. **Every Prisma query MUST include `organizationId` filter**
   - This prevents data leakage between organizations
   - Use code search to verify: `prisma.` should always have organizationId

2. **Use `ensureOrganizationAccess` middleware on resource routes**
   - Add to all `/:id` routes (GET, PATCH, DELETE)
   - Prevents accessing resources by direct ID manipulation

3. **TEAM_MANAGER vs ADMIN distinction**
   - TEAM_MANAGER: Admin within their organization only
   - ADMIN: System-wide access (use sparingly)

4. **JWT token changes**
   - Old tokens will be invalid after migration
   - All users must log in again
   - Mobile apps will need to re-authenticate

## Breaking Changes

### For Mobile Apps
- JWT payload structure changed (added organizationId)
- Login response includes organization object
- All existing tokens will be invalidated
- Users must log in again after backend update

### For Frontend
- Registration UI needed for new teams
- Organization settings UI needed
- Handle organization in user context
- Display organization name in UI

## Rollback Plan

If migration fails:
1. Restore database backup: `cp server/prisma/dev.db.backup server/prisma/dev.db`
2. Revert code changes: `git reset --hard HEAD~1`
3. Restart server

## Next Steps (Phase 2)

After backend is complete and tested:
1. Update Flutter app for registration UI
2. Update Android app for registration UI
3. Add organization switcher (if users can belong to multiple orgs)
4. Add billing/subscription management per organization
5. Add email verification for new registrations
6. Add organization invitations system

## Support

For issues during migration:
- Check logs in `server/logs/`
- Verify Prisma migrations: `npx prisma migrate status`
- Test with fresh seed data: `npm run prisma:seed`

## New Test Credentials (After Seed)

Organization: **Acme Corporation**
- Team Manager: `john@acme.com` / `manager123`
- Member: `alice@acme.com` / `member123`
- Member: `bob@acme.com` / `member123`
- Guest: `charlie@acme.com` / `guest123`

Organization: **Tech Startup Inc**
- Team Manager: `sarah@techstartup.com` / `manager123`
- Member: `david@techstartup.com` / `member123`
- Member: `emma@techstartup.com` / `member123`
- Guest: `frank@consultant.com` / `guest123`

Organization: **Design Agency**
- Team Manager: `lisa@designagency.com` / `manager123`
- Member: `mark@designagency.com` / `member123`
