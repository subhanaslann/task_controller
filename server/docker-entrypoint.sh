#!/bin/sh
set -e

echo "Running database migrations..."
npm run prisma:migrate:deploy

echo "Seeding database..."
npm run prisma:seed:prod || echo "Seeding failed or already seeded, continuing..."

echo "Starting server..."
exec node dist/index.js
