#!/bin/sh
set -e

pnpm --dir apps/backend prisma migrate deploy
exec node apps/backend/dist/main.js
