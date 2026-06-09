#!/bin/sh
set -e

# Run database migrations using the local Prisma CLI binary
./apps/backend/node_modules/.bin/prisma migrate deploy --schema=apps/backend/prisma/schema.prisma

exec node apps/backend/dist/src/main.js
