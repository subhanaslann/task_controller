/*
  Warnings:

  - Added the required column `organizationId` to the `Task` table without a default value. This is not possible if the table is not empty.
  - Added the required column `organizationId` to the `Topic` table without a default value. This is not possible if the table is not empty.
  - Added the required column `organizationId` to the `User` table without a default value. This is not possible if the table is not empty.

*/
-- CreateTable
CREATE TABLE "Organization" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "teamName" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "maxUsers" INTEGER NOT NULL DEFAULT 15,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Task" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "organizationId" TEXT NOT NULL,
    "topicId" TEXT,
    "title" TEXT NOT NULL,
    "note" TEXT,
    "assigneeId" TEXT,
    "status" TEXT NOT NULL DEFAULT 'TODO',
    "priority" TEXT NOT NULL DEFAULT 'NORMAL',
    "dueDate" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "completedAt" DATETIME,
    CONSTRAINT "Task_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "Task_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES "Topic" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "Task_assigneeId_fkey" FOREIGN KEY ("assigneeId") REFERENCES "User" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_Task" ("assigneeId", "completedAt", "createdAt", "dueDate", "id", "note", "priority", "status", "title", "topicId", "updatedAt") SELECT "assigneeId", "completedAt", "createdAt", "dueDate", "id", "note", "priority", "status", "title", "topicId", "updatedAt" FROM "Task";
DROP TABLE "Task";
ALTER TABLE "new_Task" RENAME TO "Task";
CREATE INDEX "Task_organizationId_idx" ON "Task"("organizationId");
CREATE INDEX "Task_topicId_idx" ON "Task"("topicId");
CREATE INDEX "Task_assigneeId_idx" ON "Task"("assigneeId");
CREATE INDEX "Task_status_idx" ON "Task"("status");
CREATE TABLE "new_Topic" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "organizationId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "Topic_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "new_Topic" ("createdAt", "description", "id", "isActive", "title", "updatedAt") SELECT "createdAt", "description", "id", "isActive", "title", "updatedAt" FROM "Topic";
DROP TABLE "Topic";
ALTER TABLE "new_Topic" RENAME TO "Topic";
CREATE INDEX "Topic_organizationId_idx" ON "Topic"("organizationId");
CREATE INDEX "Topic_isActive_idx" ON "Topic"("isActive");
CREATE TABLE "new_User" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "organizationId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "username" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "role" TEXT NOT NULL DEFAULT 'MEMBER',
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "User_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "new_User" ("active", "createdAt", "email", "id", "name", "passwordHash", "role", "updatedAt", "username") SELECT "active", "createdAt", "email", "id", "name", "passwordHash", "role", "updatedAt", "username" FROM "User";
DROP TABLE "User";
ALTER TABLE "new_User" RENAME TO "User";
CREATE INDEX "User_organizationId_idx" ON "User"("organizationId");
CREATE INDEX "User_email_idx" ON "User"("email");
CREATE UNIQUE INDEX "User_organizationId_username_key" ON "User"("organizationId", "username");
CREATE UNIQUE INDEX "User_organizationId_email_key" ON "User"("organizationId", "email");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;

-- CreateIndex
CREATE UNIQUE INDEX "Organization_slug_key" ON "Organization"("slug");

-- CreateIndex
CREATE INDEX "Organization_slug_idx" ON "Organization"("slug");

-- CreateIndex
CREATE INDEX "Organization_isActive_idx" ON "Organization"("isActive");
