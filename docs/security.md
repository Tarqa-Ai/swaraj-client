# Security

- JWT access and refresh tokens are signed with separate secrets.
- Student OTP challenges are hashed and expire after 5 minutes.
- MSG91 is the production OTP provider; console OTP output is restricted to non-production environments.
- DTOs are validated with Zod before business logic runs.
- Prisma parameterization prevents SQL injection.
- Reflection text is sanitized before persistence.
- AI explain requests are moderated and rate-limited.
- Secrets are provided only through environment variables.
