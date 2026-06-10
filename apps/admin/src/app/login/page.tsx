import { Suspense } from "react";
import { LoginClient } from "./login-client";

// Server component — reads env vars and passes as props
export default function LoginPage() {
  const googleConfigured = !!(
    process.env.GOOGLE_CLIENT_ID &&
    process.env.GOOGLE_CLIENT_SECRET &&
    process.env.ALLOWED_ADMIN_EMAIL
  );

  return (
    <Suspense>
      <LoginClient googleConfigured={googleConfigured} />
    </Suspense>
  );
}
