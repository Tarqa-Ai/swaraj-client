# API Contract

All endpoints are prefixed by `/api`.

## Auth

- `POST /auth/send-otp`
- `POST /auth/verify-otp`
- `POST /auth/refresh`
- `POST /auth/admin/login`

## Student

- `GET /me`
- `PATCH /me/profile`
- `GET /schools`
- `GET /dashboard`
- `GET /modules`
- `GET /modules/:id`
- `POST /lessons/:id/complete`
- `POST /quiz/submit`
- `GET /daily-challenge`
- `GET /daily-challenge/history`
- `POST /daily-challenge/submit`
- `GET /debate/current`
- `POST /debate/respond`
- `POST /ai/explain`
- `GET /leaderboard`
- `GET /certificate/status`
- `GET /certificate/download`

## Admin

- `GET /admin/analytics`
- `GET /admin/students`
- `GET /admin/schools`
- `POST /admin/schools`
- `GET /admin/modules`
- `POST /admin/modules`
- `POST /admin/lessons`
- `GET /admin/daily-challenges`
- `POST /admin/daily-challenges`
- `GET /admin/debates`
- `POST /admin/debates`

Swagger is generated at `/api/docs`.
