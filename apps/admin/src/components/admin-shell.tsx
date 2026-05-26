"use client";

import { Award, BarChart3, BookOpen, Building2, FileBadge, HelpCircle, LayoutDashboard, LogOut, MessageSquare, Users } from "lucide-react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { Button } from "./ui";
import { useAuthStore } from "@/store/auth";
import clsx from "clsx";
import { useEffect } from "react";

const nav = [
  { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { href: "/students", label: "Students", icon: Users },
  { href: "/schools", label: "Schools", icon: Building2 },
  { href: "/modules", label: "Modules", icon: BookOpen },
  { href: "/quizzes", label: "Quizzes", icon: HelpCircle },
  { href: "/challenges", label: "Challenges", icon: Award },
  { href: "/debates", label: "Debates", icon: MessageSquare },
  { href: "/leaderboard", label: "Leaderboard", icon: BarChart3 },
  { href: "/certificates", label: "Certificates", icon: FileBadge }
];

export function AdminShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { accessToken, logout } = useAuthStore();

  useEffect(() => {
    if (!accessToken && pathname !== "/login") router.replace("/login");
  }, [accessToken, pathname, router]);

  if (pathname === "/login") return <>{children}</>;

  return (
    <div className="min-h-screen bg-slate-50">
      <aside className="fixed inset-y-0 left-0 hidden w-72 border-r border-slate-200 bg-white p-5 lg:block">
        <div>
          <p className="text-2xl font-black tracking-wide text-navy">SWARAJ</p>
          <p className="mt-1 text-sm text-slate-600">Civic learning admin</p>
        </div>
        <nav className="mt-8 space-y-1">
          {nav.map((item) => {
            const Icon = item.icon;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={clsx(
                  "flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium",
                  pathname === item.href ? "bg-orange-50 text-saffron" : "text-slate-700 hover:bg-slate-100"
                )}
              >
                <Icon size={18} />
                {item.label}
              </Link>
            );
          })}
        </nav>
        <Button
          variant="ghost"
          className="absolute bottom-5 left-5"
          onClick={() => {
            logout();
            router.replace("/login");
          }}
        >
          <LogOut size={16} />
          Logout
        </Button>
      </aside>
      <main className="lg:pl-72">
        <div className="mx-auto max-w-7xl p-5 lg:p-8">{children}</div>
      </main>
    </div>
  );
}
