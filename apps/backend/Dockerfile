FROM node:22-alpine AS deps
WORKDIR /app
RUN corepack enable
COPY package.json pnpm-lock.yaml* pnpm-workspace.yaml ./
COPY apps/backend/package.json apps/backend/package.json
COPY packages/ packages/
RUN ls -laR
RUN exit 1
RUN pnpm install --filter @swaraj/backend... --frozen-lockfile=false

FROM deps AS build
COPY . .
RUN pnpm --filter @swaraj/shared-types build && pnpm --filter @swaraj/shared-utils build
RUN pnpm --filter @swaraj/backend prisma:generate
RUN pnpm --filter @swaraj/backend build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN corepack enable
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/apps/backend/dist ./apps/backend/dist
COPY --from=build /app/apps/backend/prisma ./apps/backend/prisma
COPY --from=build /app/apps/backend/package.json ./apps/backend/package.json
COPY --from=build /app/packages ./packages
COPY apps/backend/docker-entrypoint.sh ./apps/backend/docker-entrypoint.sh
RUN chmod +x ./apps/backend/docker-entrypoint.sh
EXPOSE 4000
CMD ["./apps/backend/docker-entrypoint.sh"]
