# SWARAJ

Civic education platform for Indian students in Grades 9–12. Flutter mobile app + NestJS API + Next.js admin panel, fully hosted on Supabase.

## Stack

| Layer | Tech |
|-------|------|
| Mobile | Flutter, Riverpod, supabase_flutter, flutter_secure_storage |
| Backend | NestJS, Prisma, PostgreSQL (Supabase), JWT, Zod, Swagger |
| Admin | Next.js App Router, TypeScript, Tailwind, React Query, Zustand |
| Auth | Supabase Phone OTP (SMS) for students · Email+password JWT for admins |
| AI | Google Gemini (`gemini-2.0-flash-lite`) |
| Storage | Supabase Storage (S3-compatible) |
| Database | Supabase PostgreSQL |

## Deployment

| Service | Platform |
|---------|----------|
| Admin panel | Vercel → `swaraj.org.in` |
| Backend API | Render (free tier) |
| Database | Supabase (free tier) |
| Mobile | Google Play Store · Apple App Store |

## Local Setup

```bash
cp .env.example .env   # fill in Supabase + Gemini values
pnpm install
pnpm --filter @swaraj/backend prisma:generate
pnpm db:migrate
pnpm db:seed
pnpm dev:backend       # http://localhost:4000/api
pnpm dev:admin         # http://localhost:3000
```

Swagger docs: `http://localhost:4000/api/docs`

Seed admin credentials (set in `.env`):
- `SEED_ADMIN_EMAIL` / `SEED_ADMIN_PASSWORD`

## Required Environment Variables

```env
# Database (Supabase pooler, port 6543)
DATABASE_URL=postgresql://postgres.<ref>:<password>@aws-0-<region>.pooler.supabase.com:6543/postgres?pgbouncer=true

# Supabase Auth
SUPABASE_URL=https://<ref>.supabase.co
SUPABASE_ANON_KEY=<anon_key>
SUPABASE_JWT_SECRET=<jwt_secret>

# Admin JWT
JWT_ACCESS_SECRET=<64-char hex>
JWT_REFRESH_SECRET=<64-char hex>

# Seed
SEED_ADMIN_EMAIL=admin@swaraj.local
SEED_ADMIN_PASSWORD=ChangeMe123!

# AI
GEMINI_API_KEY=<from aistudio.google.com>
GEMINI_MODEL=gemini-2.0-flash-lite

# Storage (Supabase Storage)
STORAGE_DRIVER=s3
S3_ENDPOINT=https://<ref>.supabase.co/storage/v1/s3
S3_REGION=ap-south-1
S3_BUCKET=swaraj-uploads
S3_ACCESS_KEY_ID=<supabase storage key>
S3_SECRET_ACCESS_KEY=<supabase storage secret>

# Server
PUBLIC_API_URL=https://your-backend.onrender.com
ADMIN_ORIGIN=https://swaraj.org.in
```

## Mobile

```bash
cd apps/mobile
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon_key> \
  --dart-define=API_URL=http://localhost:4000/api
```

### Release Build (Android)

```bash
flutter build appbundle \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon_key> \
  --dart-define=API_URL=https://your-backend.onrender.com/api
```

Output: `apps/mobile/build/app/outputs/bundle/release/app-release.aab`

### Release Build (iOS)

```bash
flutter build ios \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon_key> \
  --dart-define=API_URL=https://your-backend.onrender.com/api
```

Then archive and distribute via Xcode → App Store Connect.

## Supabase Setup Checklist

- [ ] Enable **Phone Auth** in Supabase Dashboard → Authentication → Providers
- [ ] Configure **Twilio** (or Supabase built-in SMS) for OTP delivery
- [ ] Create storage bucket `swaraj-uploads` (private) in Supabase Storage
- [ ] Get S3 credentials from Supabase Storage → Settings → S3 Connection
- [ ] Run `pnpm db:migrate` against Supabase DB after any schema changes

## Auth Flow

```
Student:  Mobile → Supabase OTP (SMS) → Supabase JWT → NestJS (SUPABASE_JWT_SECRET) → Prisma User auto-upsert
Admin:    Admin panel → email+password → NestJS → custom JWT (JWT_ACCESS_SECRET)
```

## Verification

```bash
pnpm lint
pnpm build
cd apps/mobile && flutter analyze
```
