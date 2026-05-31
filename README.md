# SWARAJ

SWARAJ is a civic education platform for Indian students in Grades 9-12. It includes a Flutter mobile app, NestJS API, PostgreSQL database, and Next.js admin panel.

## Current Repo Status

- Detailed handoff: [`docs/team-handoff.md`](docs/team-handoff.md)
- Current build/update report: [`docs/repo-status-and-latest-update.md`](docs/repo-status-and-latest-update.md)
- Product flow and runbook: [`docs/product-flow-runbook.md`](docs/product-flow-runbook.md)
- GitHub remote: `https://github.com/Tarqa-Ai/swaraj-client.git`
- Android APK output after build: `apps/mobile/build/app/outputs/flutter-apk/app-release.apk`

## Latest Update

The latest update modernizes the admin portal while keeping it simple for app admins: SWARAJ logo, navy/cream/saffron styling, a minimal login screen, redesigned sidebar, certificate records, and clearer admin content forms with dropdowns and helper text.

## Stack

- Mobile: Flutter, Riverpod, GoRouter, Dio, Hive, secure token storage, localization assets.
- Backend: NestJS, Prisma, PostgreSQL, JWT, Zod validation, Swagger, throttling, MSG91 OTP adapter, OpenAI explain service, PDF certificates.
- Admin: Next.js App Router, TypeScript, Tailwind, React Query, Zustand.
- Infra: Docker Compose, GitHub Actions, environment-based configuration.

## Local Setup

```bash
cd swaraj
cp .env.example .env
pnpm install
docker compose up -d postgres redis
pnpm --filter @swaraj/backend prisma:generate
pnpm db:migrate
pnpm db:seed
pnpm dev:backend
pnpm dev:admin
```

Backend API: `http://localhost:4000/api`

Swagger docs: `http://localhost:4000/api/docs`

Admin panel: `http://localhost:3000`

Seed admin:

- Email: `admin@swaraj.local`
- Password: `ChangeMe123!`

## Mobile

Flutter is required locally:

```bash
cd apps/mobile
flutter pub get
flutter run --dart-define=API_URL=http://localhost:4000/api
```

## Production Notes

- Set `OTP_PROVIDER=msg91`, `MSG91_AUTH_KEY`, and `MSG91_TEMPLATE_ID`.
- Set `OPENAI_API_KEY` for AI concept simplification.
- Use `STORAGE_DRIVER=s3` with S3-compatible credentials for production media and certificates.
- Rotate JWT secrets and never commit `.env`.

## Verification

```bash
pnpm lint
pnpm test
pnpm build
cd apps/mobile && flutter analyze && flutter test
```
