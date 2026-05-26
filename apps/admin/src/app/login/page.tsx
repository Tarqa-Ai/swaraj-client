"use client";

import { FormEvent, useState } from "react";
import { useRouter } from "next/navigation";
import { post } from "@/lib/api";
import { useAuthStore } from "@/store/auth";
import { Button, Card, Input } from "@/components/ui";

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
    <main className="grid min-h-screen place-items-center bg-slate-50 p-5">
      <Card className="w-full max-w-md">
        <p className="text-3xl font-black text-navy">SWARAJ</p>
        <p className="mt-2 text-sm text-slate-600">Sign in to manage schools, lessons, debates, and analytics.</p>
        <form className="mt-6 space-y-4" onSubmit={submit}>
          <label className="block text-sm font-medium text-slate-700">
            Email
            <Input name="email" type="email" required defaultValue="admin@swaraj.local" className="mt-1" />
          </label>
          <label className="block text-sm font-medium text-slate-700">
            Password
            <Input name="password" type="password" required defaultValue="ChangeMe123!" className="mt-1" />
          </label>
          {error ? <p className="rounded-lg bg-red-50 p-3 text-sm text-red-700">{error}</p> : null}
          <Button disabled={loading} className="w-full">
            {loading ? "Signing in..." : "Sign in"}
          </Button>
        </form>
      </Card>
    </main>
  );
}
