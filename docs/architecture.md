# Architecture

SWARAJ is organized as a monorepo with independently deployable apps and shared contracts.

## Backend

The NestJS backend is the source of truth for auth, content, scoring, debate participation, certificates, and analytics. Prisma models define all relations and indexes. Business events that affect Political IQ are written to immutable `PoliticalIQLog` rows before updating the user's aggregate score.

Provider integrations are isolated:

- OTP uses `OtpProvider`, with MSG91 in production and console logging in development.
- AI uses `AiService`, backed by OpenAI moderation and single-turn chat completion.
- Files use `FileStorageService`, with local and S3-compatible implementations.

## Mobile

The Flutter app uses feature-first folders. Riverpod providers isolate data access, Dio attaches auth tokens, and `flutter_secure_storage` stores sessions. The app is structured around the core student loops: onboarding, learning, quiz, challenge, debate, AI explain, leaderboard, profile, and certificate.

## Admin

The admin panel is a Next.js App Router application. It uses only backend REST APIs and stores admin JWTs in a Zustand persisted store. React Query owns server state and provides loading/error surfaces.
