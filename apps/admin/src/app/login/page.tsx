"use client";

import { FormEvent, useState } from "react";
import { useRouter } from "next/navigation";
import { post } from "@/lib/api";
import { useAuthStore } from "@/store/auth";
import { Button, Input, SwarajLogo } from "@/components/ui";

export default function LoginPage() {
  const router = useRouter();
  const setTokens = useAuthStore((state) => state.setTokens);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setLoading(true);
    setError(null);
    const form = new FormData(event.currentTarget);
    try {
      const result = await post<{ accessToken: string; refreshToken: string }>("/auth/admin/login", {
        email: form.get("email"),
        password: form.get("password")
      });
      setTokens(result);
      router.replace("/dashboard");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Login failed");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="grid min-h-screen place-items-center bg-[#fbfaf6] px-5 py-8">
      <section className="w-full max-w-md">
        <div className="flex justify-center">
          <SwarajLogo />
        </div>

        <div className="mt-8 rounded-lg border border-[#e8e1d6] bg-white p-6 shadow-soft md:p-8">
          <h1 className="text-2xl font-black text-navy">Admin Login</h1>

          <form className="mt-6 space-y-5" onSubmit={submit}>
            <label className="block text-xs font-extrabold uppercase tracking-normal text-slate-500">
              Email
              <Input name="email" type="email" required className="mt-2 h-12" placeholder="admin@swaraj.local" />
            </label>
            <label className="block text-xs font-extrabold uppercase tracking-normal text-slate-500">
              Password
              <Input name="password" type="password" required className="mt-2 h-12" placeholder="Enter password" />
            </label>
            {error ? <p className="rounded-lg border border-red-200 bg-red-50 p-3 text-sm font-semibold text-red-700">{error}</p> : null}
            <Button disabled={loading} className="h-12 w-full">
              {loading ? "Signing in..." : "Sign in"}
            </Button>
          </form>
        </div>
      </section>
    </main>
  );
}
