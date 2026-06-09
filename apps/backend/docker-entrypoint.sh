#!/bin/sh
set -e

./node_modules/.bin/prisma migrate deploy --schema=apps/backend/prisma/schema.prisma
exec node apps/backend/dist/main.js
