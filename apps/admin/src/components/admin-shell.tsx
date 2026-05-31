"use client";

import {
  Award,
  BarChart3,
  BookOpen,
  FileBadge,
  HelpCircle,
  LayoutDashboard,
  ListChecks,
  LogOut,
  MessageSquare,
  ShieldCheck,
  Star,
  Users
} from "lucide-react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { Button, SwarajLogo } from "./ui";
import { useAuthStore } from "@/store/auth";
import clsx from "clsx";
import { useEffect, useState } from "react";

const nav = [
  { href: "/dashboard", label: "Overview", icon: LayoutDashboard },
  { href: "/students", label: "Citizens", icon: Users },
  { href: "/modules", label: "Modules", icon: BookOpen },
  { href: "/lessons", label: "Lessons", icon: ListChecks },
  { href: "/quizzes", label: "Quizzes", icon: HelpCircle },
  { href: "/quiz-questions", label: "Questions", icon: HelpCircle },
  { href: "/challenges", label: "Daily Challenge", icon: Award },
  { href: "/debates", label: "Active Debate", icon: MessageSquare },
  { href: "/leaderboard", label: "Leaderboard", icon: BarChart3 },
  { href: "/certificates", label: "Certificates", icon: FileBadge },
  { href: "/achievements", label: "Badges", icon: Star }
];

export function AdminShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { accessToken, logout } = useAuthStore();
  const [authHydrated, setAuthHydrated] = useState(false);

  useEffect(() => {
    setAuthHydrated(useAuthStore.persist.hasHydrated());
    return useAuthStore.persist.onFinishHydration(() => setAuthHydrated(true));
  }, []);

  useEffect(() => {
    if (!authHydrated || pathname === "/login") return;
    if (!accessToken) router.replace("/login");
  }, [accessToken, authHydrated, pathname, router]);

  if (pathname === "/login") return <>{children}</>;
  if (!authHydrated) return <div className="min-h-screen bg-[#fbfaf6]" />;

  return (
    <div className="min-h-screen bg-[#fbfaf6]">
      <aside className="fixed inset-y-0 left-0 hidden w-[19rem] border-r border-[#e8e1d6] bg-[#fffdf8] p-5 lg:block">
        <SwarajLogo />

        <div className="mt-7 rounded-lg border border-[#eadfce] bg-[#fff7eb] p-4">
          <div className="flex items-center gap-2 text-navy">
            <ShieldCheck size={18} className="text-saffron" />
            <p className="text-sm font-extrabold">SWARAJ App Admin</p>
          </div>
          <p className="mt-2 text-xs leading-5 text-slate-600">Update learning content, quizzes, challenges, debates, and citizen records from one sober console.</p>
        </div>

        <nav className="mt-6 space-y-1.5">
          {nav.map((item) => {
            const Icon = item.icon;
            const active = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={clsx(
                  "flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-bold transition",
                  active ? "bg-navy text-white shadow-[0_12px_24px_rgba(7,29,54,0.16)]" : "text-slate-700 hover:bg-[#fff4e5] hover:text-navy"
                )}
              >
                <Icon size={18} className={active ? "text-saffron" : "text-slate-500"} />
                {item.label}
              </Link>
            );
          })}
        </nav>
        <Button
          variant="ghost"
          className="absolute bottom-5 left-5 text-slate-600 hover:text-navy"
          onClick={() => {
            logout();
            router.replace("/login");
          }}
        >
          <LogOut size={16} />
          Logout
        </Button>
      </aside>

      <header className="sticky top-0 z-20 border-b border-[#e8e1d6] bg-[#fffdf8]/95 px-4 py-3 backdrop-blur lg:hidden">
        <div className="flex items-center justify-between">
          <SwarajLogo compact />
          <Button
            variant="ghost"
            onClick={() => {
              logout();
              router.replace("/login");
            }}
            aria-label="Logout"
          >
            <LogOut size={18} />
          </Button>
        </div>
      </header>

      <main className="lg:pl-[19rem]">
        <div className="mx-auto max-w-7xl p-5 lg:p-8">{children}</div>
      </main>
    </div>
  );
}
