"use client";

import {
  Award,
  BarChart3,
  BookOpen,
  FileBadge,
  GraduationCap,
  HelpCircle,
  LayoutDashboard,
  ListChecks,
  LogOut,
  MessageSquare,
  Shield,
  Star,
  Users
} from "lucide-react";
import Link from "next/link";
import Image from "next/image";
import { usePathname, useRouter } from "next/navigation";
import { signOut, useSession } from "next-auth/react";
import { useAuthStore } from "@/store/auth";
import clsx from "clsx";
import { useEffect, useRef } from "react";

const navGroups = [
  {
    label: "Overview",
    items: [
      { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
      { href: "/students", label: "Citizens", icon: Users }
    ]
  },
  {
    label: "Content",
    items: [
      { href: "/modules", label: "Modules", icon: BookOpen },
      { href: "/lessons", label: "Lessons", icon: ListChecks },
      { href: "/quizzes", label: "Quizzes", icon: HelpCircle },
      { href: "/quiz-questions", label: "Questions", icon: HelpCircle },
      { href: "/challenges", label: "Daily Challenge", icon: Award }
    ]
  },
  {
    label: "Community",
    items: [
      { href: "/debates", label: "Active Debate", icon: MessageSquare },
      { href: "/leaderboard", label: "Leaderboard", icon: BarChart3 },
      { href: "/schools", label: "Schools", icon: GraduationCap }
    ]
  },
  {
    label: "System",
    items: [
      { href: "/certificates", label: "Certificates", icon: FileBadge },
      { href: "/achievements", label: "Badges", icon: Star }
    ]
  }
];

function NavItem({ href, label, icon: Icon, active }: { href: string; label: string; icon: React.ElementType; active: boolean }) {
  return (
    <Link
      href={href}
      className={clsx(
        "flex items-center gap-3 rounded-lg border px-3 py-2.5 text-sm font-bold transition",
        active
          ? "border-saffron/20 bg-navy text-white shadow-[0_8px_20px_rgba(7,29,54,0.18)]"
          : "border-transparent text-slate-600 hover:border-[#f0e8dd] hover:bg-[#fff8ed] hover:text-navy"
      )}
    >
      <Icon size={17} className={active ? "text-saffron" : "text-slate-400"} />
      {label}
    </Link>
  );
}

function SidebarContent({ pathname, onLogout }: { pathname: string; onLogout: () => void }) {
  const { data: session } = useSession();

  return (
    <>
      <div className="flex items-center gap-3 border-b border-[#ede8e0] pb-5">
        <div className="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-navy shadow-[0_8px_20px_rgba(7,29,54,0.2)]">
          <Shield size={20} fill="currentColor" className="text-saffron" strokeWidth={1.5} />
        </div>
        <div>
          <p className="text-lg font-black leading-none tracking-normal text-navy">SWARAJ</p>
          <p className="mt-1 text-[9px] font-extrabold uppercase tracking-widest text-saffron">Admin Console</p>
        </div>
      </div>

      <nav className="mt-5 flex-1 space-y-5 overflow-y-auto pb-4">
        {navGroups.map((group) => (
          <div key={group.label}>
            <p className="mb-2 px-3 text-[9px] font-extrabold uppercase tracking-widest text-slate-400">{group.label}</p>
            <div className="space-y-0.5">
              {group.items.map((item) => (
                <NavItem key={item.href} {...item} active={pathname === item.href} />
              ))}
            </div>
          </div>
        ))}
      </nav>

      <div className="border-t border-[#ede8e0] pt-4">
        {session?.user && (
          <div className="mb-3 flex items-center gap-3 rounded-xl border border-[#ede8e0] bg-[#fbfaf6] p-3">
            {session.user.image ? (
              <Image
                src={session.user.image}
                alt={session.user.name ?? "Admin"}
                width={36}
                height={36}
                className="rounded-full ring-2 ring-saffron/20"
              />
            ) : (
              <div className="grid h-9 w-9 place-items-center rounded-full bg-navy text-saffron text-sm font-black">
                {(session.user.name ?? "A")[0]}
              </div>
            )}
            <div className="min-w-0">
              <p className="truncate text-sm font-bold text-navy">{session.user.name ?? "Admin"}</p>
              <p className="truncate text-[11px] text-slate-500">{session.user.email}</p>
            </div>
          </div>
        )}
        <button
          onClick={onLogout}
          className="flex w-full items-center gap-2 rounded-lg px-3 py-2.5 text-sm font-bold text-slate-500 transition hover:bg-red-50 hover:text-red-600"
        >
          <LogOut size={16} />
          Sign out
        </button>
      </div>
    </>
  );
}

export function AdminShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { data: session, status } = useSession();
  const { accessToken, setTokens, logout } = useAuthStore();
  const fetchingRef = useRef(false);

  const publicRoutes = ["/", "/login", "/privacy", "/terms"];
  const isPublicRoute = publicRoutes.includes(pathname);

  // Redirect to login if not authenticated
  useEffect(() => {
    if (isPublicRoute || status === "loading") return;
    if (status === "unauthenticated") router.replace("/login");
  }, [status, isPublicRoute, router]);

  // Fetch backend JWT once we have a NextAuth session but no access token
  useEffect(() => {
    if (isPublicRoute || status !== "authenticated" || accessToken || fetchingRef.current) return;
    fetchingRef.current = true;

    fetch("/api/admin-auth")
      .then((res) => (res.ok ? res.json() : Promise.reject()))
      .then((tokens: { accessToken: string; refreshToken: string }) => setTokens(tokens))
      .catch(() => {
        logout();
        router.replace("/login");
      })
      .finally(() => {
        fetchingRef.current = false;
      });
  }, [status, accessToken, isPublicRoute, setTokens, logout, router]);

  async function handleLogout() {
    logout();
    await signOut({ redirectTo: "/login" });
  }

  if (isPublicRoute) return <>{children}</>;

  if (status === "loading" || (status === "authenticated" && !accessToken)) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-[#fbfaf6]">
        <div className="flex flex-col items-center gap-4">
          <div className="grid h-12 w-12 place-items-center rounded-xl bg-navy">
            <Shield size={22} fill="currentColor" className="text-saffron" strokeWidth={1.5} />
          </div>
          <div className="h-1 w-32 overflow-hidden rounded-full bg-[#e8e1d6]">
            <div className="h-full w-1/2 animate-[slide_1.2s_ease-in-out_infinite] rounded-full bg-saffron" />
          </div>
        </div>
      </div>
    );
  }

  if (status === "unauthenticated") return null;

  const currentPage = navGroups.flatMap((g) => g.items).find((i) => i.href === pathname);

  return (
    <div className="min-h-screen bg-[#fbfaf6]">
      {/* Desktop sidebar */}
      <aside className="fixed inset-y-0 left-0 hidden w-[20rem] flex-col border-r border-[#e8e1d6] bg-[#fffdf8] p-5 lg:flex">
        <SidebarContent pathname={pathname} onLogout={handleLogout} />
      </aside>

      {/* Mobile header */}
      <header className="sticky top-0 z-20 border-b border-[#e8e1d6] bg-[#fffdf8]/95 px-4 py-3 backdrop-blur lg:hidden">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="grid h-8 w-8 place-items-center rounded-lg bg-navy">
              <Shield size={16} fill="currentColor" className="text-saffron" strokeWidth={1.5} />
            </div>
            <span className="text-base font-black text-navy">SWARAJ</span>
          </div>
          <div className="flex items-center gap-2">
            {session?.user?.image && (
              <Image
                src={session.user.image}
                alt="Admin"
                width={28}
                height={28}
                className="rounded-full ring-1 ring-saffron/30"
              />
            )}
            <button
              onClick={handleLogout}
              className="grid h-8 w-8 place-items-center rounded-lg text-slate-500 hover:bg-red-50 hover:text-red-600"
              aria-label="Sign out"
            >
              <LogOut size={16} />
            </button>
          </div>
        </div>
      </header>

      <main className="lg:pl-[20rem]">
        <div className="mx-auto max-w-7xl p-5 lg:p-8">
          {currentPage && (
            <div className="mb-6 flex items-center gap-2 text-xs font-extrabold uppercase tracking-widest text-slate-400">
              <currentPage.icon size={13} />
              <span>{currentPage.label}</span>
            </div>
          )}
          {children}
        </div>
      </main>
    </div>
  );
}
