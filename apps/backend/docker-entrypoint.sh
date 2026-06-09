#!/bin/sh
set -e

# Change directory to backend so npx runs the local Prisma version
cd apps/backend
npx prisma migrate deploy
cd /app

exec node apps/backend/dist/main.js
