#!/bin/sh
set -e

npx prisma migrate deploy --schema=apps/backend/prisma/schema.prisma
exec node apps/backend/dist/main.js
