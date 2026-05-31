# SWARAJ Repo Status And Latest Update

Date: 2026-05-31

Remote: `https://github.com/Tarqa-Ai/swaraj-client.git`

This document is for the team receiving the repository. It explains what has already been made, what changed in the latest update, what should remain in the 45k INR MVP, and what should be sold as paid extra scope.

## Repository Map

| Path | Purpose | Status |
|---|---|---|
| `apps/mobile` | Flutter student app for Android/iOS/web targets. | Made |
| `apps/backend` | NestJS API with Prisma, PostgreSQL, auth, learning, quiz, gamification, admin, and extra modules. | Made |
| `apps/admin` | Next.js admin portal for content, school, student, analytics, and operational management. | Made |
| `packages/shared-types` | Shared TypeScript types used across the platform. | Made |
| `packages/shared-utils` | Shared scoring, pagination, level, and badge utilities. | Made |
| `docs/api.md` | API endpoint overview. | Made |
| `docs/architecture.md` | Technical architecture overview. | Made |
| `docs/security.md` | Security notes and production hardening points. | Made |
| `docs/team-handoff.md` | Detailed team handoff, flow diagrams, commands, and module guide. | Made |

## Already Made Feature Inventory

| Product Area | Feature | Current Implementation | MVP Decision | Extra Money Scope |
|---|---|---|---|---|
| Mobile | Splash screen | Flutter screen exists. | Keep | No |
| Mobile | Student auth | Auth repository and screen exist. | Keep | No |
| Mobile | Onboarding | Name, language, grade, and school setup flow exists. | Keep | No |
| Mobile | Dashboard | Progress and civic learning dashboard exists. | Keep simplified | Advanced analytics |
| Mobile | Learning modules | Module list, module detail, and lesson screens exist. | Keep | No |
| Mobile | Lesson completion | Lesson completion route and backend API exist. | Keep | No |
| Mobile | Quiz | Quiz screen, repository, submit API, and scoring exist. | Keep basic | Advanced question bank/scoring |
| Mobile | Profile | Profile screen exists. | Keep basic | Profile editing extensions |
| Mobile | Hindi/English strings | Localization files exist. | Keep current copy | Professional translation review |
| Mobile | Daily challenges | Screen, repository, backend, schema, and admin page exist. | Hide for 45k | Yes |
| Mobile | Debate arena | Screen, repository, backend, schema, and admin page exist. | Hide for 45k | Yes |
| Mobile | AI explain | Screen and backend AI service/controller exist. | Hide/remove for 45k | Yes |
| Mobile | Leaderboard | Screen and backend endpoint exist. | Hide for 45k | Yes |
| Mobile | Certificate | Screen and backend certificate module exist. | Hide for 45k | Yes |
| Backend | Auth | Student OTP flow, admin login, JWT, refresh token handling. | Keep required parts | OTP provider production setup |
| Backend | Profile | Profile controller/service/schema exist. | Keep basic | Extra profile fields |
| Backend | Learning | Modules, lessons, progress APIs exist. | Keep | No |
| Backend | Quiz | Quiz submit, scoring, attempts, and schema exist. | Keep basic | More question types/reporting |
| Backend | Daily Challenge | Current challenge, submission, history, streak support. | Hide/disable for 45k | Yes |
| Backend | Debate | Active debate, sides, reflection submission. | Hide/disable for 45k | Yes |
| Backend | AI | OpenAI-backed concept simplification service. | Hide/disable for 45k | Yes |
| Backend | Gamification | Political IQ logs, points, badges, levels. | Simplify for 45k | Yes |
| Backend | Leaderboard | School/student ranking endpoint. | Hide for 45k | Yes |
| Backend | Certificate | Eligibility, certificate creation, verification support. | Hide for 45k | Yes |
| Backend | Storage | Storage service and media asset model exist. | Not needed for text-only MVP | Yes |
| Backend | Admin APIs | CRUD and analytics endpoints exist. | Keep core only | Advanced reporting |
| Admin | Admin login | Next.js login page using `/auth/admin/login`. | Keep | No |
| Admin | Admin shell | Sidebar, auth guard, logout, mobile header. | Keep | No |
| Admin | Dashboard | Analytics cards and top schools. | Keep basic | Advanced charts/filters |
| Admin | Schools | CRUD page exists. | Keep | No |
| Admin | Students | List/delete page exists. | Keep list only | Bulk tools/export |
| Admin | Modules | CRUD page exists. | Keep | No |
| Admin | Lessons | CRUD page exists. | Keep | No |
| Admin | Quizzes | CRUD page exists. | Keep basic | Advanced question editor |
| Admin | Quiz questions | CRUD page exists. | Keep basic | Bulk import/editor |
| Admin | Daily challenges | CRUD page exists. | Hide for 45k | Yes |
| Admin | Debates | CRUD page exists. | Hide for 45k | Yes |
| Admin | Achievements | CRUD page exists. | Hide for 45k | Yes |
| Admin | Leaderboard | Read page exists. | Hide for 45k | Yes |
| Admin | Certificates | Read page exists. | Hide for 45k | Yes |
| Admin | Exports | Export summary page exists. | Hide for 45k | Yes |
| Docs | Team handoff | Detailed team documentation exists. | Keep | No |

## Latest Update: Before And After

| Area | Before Latest Update | After Latest Update |
|---|---|---|
| Admin visual identity | Basic admin look with generic white/slate Tailwind surfaces. | SWARAJ-style navy, cream, saffron, shield logo, and app-matching tone. |
| Admin login | Simple form-focused login screen. | Branded two-column login with SWARAJ logo, shield icon, mission copy, and polished credential panel. |
| Admin shell | Basic sidebar navigation. | Wider branded sidebar, active navy states, saffron icons, admin context block, and compact mobile header. |
| Dashboard | Plain title, metric cards, and top schools card. | Branded operations header, mission/mode chips, modern metric cards, top schools panel, and navy civic status panel. |
| Shared UI | Basic buttons, cards, inputs, skeletons, and empty states. | Reusable app-style button/card/input components with consistent borders, shadows, colors, and logo component. |
| Resource pages | Plain page title, table, forms, text-only buttons. | Branded section headers, icon buttons, cream table headers, cleaner row spacing, polished forms. |
| Auth guard | Protected pages could redirect to login before persisted auth hydrated. | Auth hydration check added so direct reloads like `/schools` remain stable after login. |
| Tailwind tokens | Navy/saffron existed but did not fully match the app refresh. | Updated navy/saffron/cream tokens and softer SWARAJ shadow. |
| Documentation | Handoff existed separately. | README now links to detailed handoff and latest status/update report. |

## 45k INR MVP Scope

For a 45k INR delivery, ship the smallest complete learning product. Do not expose every feature that already exists in code.

| Keep In MVP | Reason |
|---|---|
| Student login and onboarding | Required to identify the learner. |
| Dashboard | Required landing surface after login. |
| Modules and lessons | Core learning value. |
| Basic quiz | Core engagement and assessment. |
| Basic profile | Needed for student identity and progress. |
| Basic admin login | Needed for content management. |
| Schools, modules, lessons, quizzes, questions admin | Minimum useful admin portal. |
| Basic dashboard analytics | Enough for admin visibility without enterprise scope. |
| Current SWARAJ branding | Required for a polished handoff. |

## Paid Extra Scope

| Feature | Why It Costs Extra |
|---|---|
| AI explain | Requires OpenAI cost, moderation, prompt safety, production key setup, and QA. |
| Debate arena | User-written reflections require moderation and more review handling. |
| Daily challenges | Requires content scheduling, streak logic, and admin operations. |
| Political IQ full scoring | Needs careful scoring rules, testing, and analytics. |
| Achievements/badges | Adds gamification rules and regression testing. |
| Leaderboard | Adds privacy, ranking, school filtering, and fairness concerns. |
| Certificates | Adds eligibility logic, PDF generation, storage, verification, and design. |
| Exports/reports | Business reporting scope, not MVP. |
| Push notifications | APNs/FCM setup, permissions, scheduling, and QA. |
| Offline mode | Local caching and sync conflict handling. |
| Multi-school roles | Role-based access control and more security testing. |
| Production CI/CD | Deployment pipelines, secrets, environments, and release automation. |

## Android APK Build

Build command:

```bash
cd apps/mobile
flutter pub get
flutter build apk --release --dart-define=API_URL=http://10.0.2.2:4000/api
```

Expected output:

```text
apps/mobile/build/app/outputs/flutter-apk/app-release.apk
```

Latest local APK build:

| Field | Value |
|---|---|
| Build command | `flutter build apk --release --dart-define=API_URL=http://10.0.2.2:4000/api` |
| Output path | `apps/mobile/build/app/outputs/flutter-apk/app-release.apk` |
| APK size | 22.8 MB |
| SHA-256 | `3cb4f571559a03f1422776927b56fc09df5fc9ec21365ad55157492358e07867` |

Important production note: the current Android config still uses debug signing for release builds. This is acceptable for a local APK handoff, but Play Store release needs a production keystore and final package id before submission. The Android Gradle wrapper and plugin versions are pinned to the Flutter 3.32 supported template values: Gradle `8.12`, Android Gradle Plugin `8.7.3`, Kotlin `2.1.0`.

## Run Commands

Backend:

```bash
pnpm dev:backend
```

Admin:

```bash
pnpm dev:admin
```

Mobile:

```bash
cd apps/mobile
flutter run --dart-define=API_URL=http://localhost:4000/api
```

## Suggested Client Positioning

| Version | Price Position | Included |
|---|---:|---|
| MVP | 45k-60k INR | Student login, onboarding, dashboard, modules, lessons, basic quiz, profile, core admin. |
| Standard | 1.25L-1.8L INR | MVP plus better admin, deployment, QA, and launch support. |
| Full SWARAJ | 3.25L-4.5L INR | AI, debates, challenges, Political IQ, achievements, leaderboard, certificates, exports. |
| Enterprise | 5L+ INR | Multi-school roles, advanced analytics, reporting, CI/CD, support, scaling. |
