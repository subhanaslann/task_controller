-- CreateTable
CREATE TABLE "GuestTopicAccess" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "topicId" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "GuestTopicAccess_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "GuestTopicAccess_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES "Topic" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateIndex
CREATE INDEX "GuestTopicAccess_userId_idx" ON "GuestTopicAccess"("userId");

-- CreateIndex
CREATE INDEX "GuestTopicAccess_topicId_idx" ON "GuestTopicAccess"("topicId");

-- CreateIndex
CREATE UNIQUE INDEX "GuestTopicAccess_userId_topicId_key" ON "GuestTopicAccess"("userId", "topicId");
