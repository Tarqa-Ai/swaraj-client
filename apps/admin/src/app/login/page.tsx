"use client";

import { FormEvent, useState } from "react";
import { ArrowRight, LockKeyhole, ShieldCheck } from "lucide-react";
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
    <main className="min-h-screen bg-[#fbfaf6] px-5 py-8">
      <div className="mx-auto flex min-h-[calc(100vh-4rem)] w-full max-w-6xl items-center">
        <section className="grid w-full gap-8 lg:grid-cols-[1.08fr_0.92fr] lg:items-center">
          <div className="max-w-2xl">
            <SwarajLogo />
            <div className="mt-14">
              <p className="inline-flex items-center gap-2 rounded-full border border-[#eadfce] bg-[#fff7eb] px-3 py-1 text-[11px] font-extrabold uppercase tracking-normal text-saffron">
                <ShieldCheck size={14} />
                Administrative Portal
              </p>
              <h1 className="mt-6 text-5xl font-black leading-[1.05] tracking-normal text-navy md:text-6xl">Civic learning command center</h1>
              <p className="mt-5 max-w-xl text-lg leading-8 text-slate-600">
                Manage Rajasthan schools, student progress, lessons, debates, daily challenges, certificates, and Political IQ analytics with the same SWARAJ identity students see in the app.
              </p>
            </div>
            <div className="mt-10 grid max-w-xl gap-3 sm:grid-cols-3">
              {["Schools", "Lessons", "Analytics"].map((item) => (
                <div key={item} className="rounded-lg border border-[#eadfce] bg-white px-4 py-3">
                  <p className="text-xs font-extrabold uppercase tracking-normal text-slate-400">{item}</p>
                  <p className="mt-1 text-sm font-bold text-navy">Admin ready</p>
                </div>
              ))}
            </div>
          </div>

          <div className="rounded-lg border border-[#e8e1d6] bg-white p-6 shadow-[0_28px_70px_rgba(7,29,54,0.13)] md:p-8">
            <div className="flex items-center gap-3">
              <div className="grid h-11 w-11 place-items-center rounded-lg bg-navy text-saffron">
                <LockKeyhole size={21} />
              </div>
              <div>
                <h2 className="text-2xl font-black text-navy">Sign in</h2>
                <p className="text-sm text-slate-500">Secure workspace session</p>
              </div>
            </div>

            <form className="mt-8 space-y-5" onSubmit={submit}>
              <label className="block text-xs font-extrabold uppercase tracking-normal text-slate-500">
                Email Address
                <Input name="email" type="email" required className="mt-2 h-12" placeholder="admin@swaraj.local" />
              </label>
              <label className="block text-xs font-extrabold uppercase tracking-normal text-slate-500">
                Security Password
                <Input name="password" type="password" required className="mt-2 h-12" placeholder="Enter password" />
              </label>
              {error ? <p className="rounded-lg border border-red-200 bg-red-50 p-3 text-sm font-semibold text-red-700">{error}</p> : null}
              <Button disabled={loading} className="h-12 w-full">
                {loading ? "Authorizing..." : "Sign In Gateway"}
                <ArrowRight size={17} />
              </Button>
            </form>

            <div className="mt-6 rounded-lg border border-[#eadfce] bg-[#fffaf2] p-4">
              <p className="text-xs font-bold leading-5 text-slate-600">
                Seed access: <span className="text-navy">admin@swaraj.local</span> / <span className="text-navy">ChangeMe123!</span>
              </p>
            </div>
          </div>
        </section>
      </div>
    </main>
  );
}
