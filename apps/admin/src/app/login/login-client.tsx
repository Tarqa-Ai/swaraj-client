"use client";

import { useSearchParams } from "next/navigation";
import { signIn, useSession } from "next-auth/react";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { AlertTriangle, Shield, ShieldAlert } from "lucide-react";

function GoogleIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M17.64 9.205c0-.639-.057-1.252-.164-1.841H9v3.481h4.844a4.14 4.14 0 0 1-1.796 2.716v2.259h2.908c1.702-1.567 2.684-3.875 2.684-6.615Z" fill="#4285F4" />
      <path d="M9 18c2.43 0 4.467-.806 5.956-2.18l-2.908-2.259c-.806.54-1.837.86-3.048.86-2.344 0-4.328-1.584-5.036-3.711H.957v2.332A8.997 8.997 0 0 0 9 18Z" fill="#34A853" />
      <path d="M3.964 10.71A5.41 5.41 0 0 1 3.682 9c0-.593.102-1.17.282-1.71V4.958H.957A8.996 8.996 0 0 0 0 9c0 1.452.348 2.827.957 4.042l3.007-2.332Z" fill="#FBBC05" />
      <path d="M9 3.58c1.321 0 2.508.454 3.44 1.345l2.582-2.58C13.463.891 11.426 0 9 0A8.997 8.997 0 0 0 .957 4.958L3.964 6.29C4.672 4.163 6.656 3.58 9 3.58Z" fill="#EA4335" />
    </svg>
  );
}

export function LoginClient({ googleConfigured }: { googleConfigured: boolean }) {
  const params = useSearchParams();
  const router = useRouter();
  const { status } = useSession();
  const [loading, setLoading] = useState(false);
  const isAccessDenied = params.get("error") === "AccessDenied";
  const isOtherError = params.get("error") !== null && params.get("error") !== "" && !isAccessDenied;

  useEffect(() => {
    if (status === "authenticated") router.replace("/dashboard");
  }, [status, router]);

  async function handleGoogleSignIn() {
    setLoading(true);
    await signIn("google", { redirectTo: "/dashboard" });
  }

  return (
    <main className="relative flex min-h-screen items-center justify-center overflow-hidden bg-[#fbfaf6] px-5 py-12">
      <div className="pointer-events-none absolute inset-0 bg-[linear-gradient(180deg,rgba(255,157,37,0.08)_0%,rgba(255,157,37,0)_400px)]" />
      <div className="pointer-events-none absolute -right-32 -top-32 h-96 w-96 rounded-full bg-saffron/5 blur-3xl" />
      <div className="pointer-events-none absolute -bottom-32 -left-32 h-96 w-96 rounded-full bg-navy/5 blur-3xl" />

      <section className="relative z-10 w-full max-w-sm">
        <div className="flex flex-col items-center gap-4">
          <div className="grid h-16 w-16 place-items-center rounded-2xl bg-navy shadow-[0_20px_40px_rgba(7,29,54,0.25)]">
            <Shield size={30} fill="currentColor" className="text-saffron" strokeWidth={1.5} />
          </div>
          <div className="text-center">
            <p className="text-3xl font-black tracking-normal text-navy">SWARAJ</p>
            <p className="mt-1 text-[11px] font-extrabold uppercase tracking-widest text-saffron">Admin Console</p>
          </div>
        </div>

        <div className="mt-8 rounded-2xl border border-[#e8e1d6] bg-white p-8 shadow-[0_16px_40px_rgba(7,29,54,0.08)]">
          <h1 className="text-xl font-black text-navy">Sign in to continue</h1>
          <p className="mt-2 text-sm text-slate-500">Access is restricted to authorized administrators only.</p>

          {!googleConfigured && (
            <div className="mt-4 flex items-start gap-3 rounded-xl border border-amber-200 bg-amber-50 p-4">
              <AlertTriangle size={15} className="mt-0.5 shrink-0 text-amber-600" />
              <div>
                <p className="text-sm font-bold text-amber-700">OAuth not configured</p>
                <p className="mt-0.5 text-xs leading-relaxed text-amber-600">
                  Fill <code className="rounded bg-amber-100 px-1 font-mono">GOOGLE_CLIENT_ID</code>,{" "}
                  <code className="rounded bg-amber-100 px-1 font-mono">GOOGLE_CLIENT_SECRET</code>, and{" "}
                  <code className="rounded bg-amber-100 px-1 font-mono">ALLOWED_ADMIN_EMAIL</code> in{" "}
                  <code className="rounded bg-amber-100 px-1 font-mono">.env</code>, then restart the server.
                </p>
              </div>
            </div>
          )}

          {isAccessDenied && (
            <div className="mt-4 flex items-start gap-3 rounded-xl border border-red-200 bg-red-50 p-4">
              <ShieldAlert size={15} className="mt-0.5 shrink-0 text-red-600" />
              <div>
                <p className="text-sm font-bold text-red-700">Access denied</p>
                <p className="mt-0.5 text-xs text-red-600">This Google account is not authorized. Only the designated admin account may sign in.</p>
              </div>
            </div>
          )}

          {isOtherError && (
            <div className="mt-4 flex items-start gap-3 rounded-xl border border-red-200 bg-red-50 p-4">
              <ShieldAlert size={15} className="mt-0.5 shrink-0 text-red-600" />
              <div>
                <p className="text-sm font-bold text-red-700">Sign-in error</p>
                <p className="mt-0.5 text-xs text-red-600">Something went wrong. Try again or check the server logs.</p>
              </div>
            </div>
          )}

          <button
            onClick={handleGoogleSignIn}
            disabled={loading || !googleConfigured || status === "loading"}
            className="mt-6 flex h-12 w-full items-center justify-center gap-3 rounded-xl border border-[#d8d1c7] bg-white px-4 text-sm font-bold text-navy shadow-sm transition hover:border-saffron hover:shadow-md disabled:cursor-not-allowed disabled:opacity-50"
          >
            {loading ? (
              <svg className="h-4 w-4 animate-spin" viewBox="0 0 24 24" fill="none">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
              </svg>
            ) : (
              <GoogleIcon />
            )}
            {loading ? "Redirecting…" : "Continue with Google"}
          </button>
        </div>

        <p className="mt-6 text-center text-xs text-slate-400">
          Swaraj Civic Learning Platform &mdash; Admin v2
        </p>
      </section>
    </main>
  );
}
