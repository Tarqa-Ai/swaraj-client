"use client";

import { useQuery } from "@tanstack/react-query";
import Link from "next/link";
import { useSession } from "next-auth/react";
import { Activity, Award, BarChart3, BookOpenCheck, ClipboardList, HelpCircle, MessageSquare, TrendingUp, Trophy, Users } from "lucide-react";
import { api } from "@/lib/api";
import { Card, Skeleton } from "@/components/ui";

type Analytics = {
  totalUsers: number;
  activeUsers: number;
  totalModules: number;
  totalLessons: number;
  totalQuizzes: number;
  totalQuestions: number;
  dailyChallenges: number;
  activeDebates: number;
  completionPercent: number;
  averagePoliticalIq: number;
  debateParticipation: number;
  topSchools: Array<{ id: string; name: string; students: number }>;
};

const quickActions = [
  { href: "/modules", label: "Manage Modules", helper: "Add, edit, remove learning modules", icon: BookOpenCheck },
  { href: "/quizzes", label: "Manage Quizzes", helper: "Update quiz shells per module", icon: HelpCircle },
  { href: "/quiz-questions", label: "Edit Questions", helper: "MCQ, True/False, Match Column", icon: ClipboardList },
  { href: "/students", label: "Citizen Records", helper: "View and correct user details", icon: Users },
  { href: "/challenges", label: "Daily Challenge", helper: "Schedule three questions per day", icon: Award },
  { href: "/debates", label: "Active Debate", helper: "Control the live For/Against topic", icon: MessageSquare }
];

function greeting() {
  const h = new Date().getHours();
  if (h < 12) return "Good morning";
  if (h < 17) return "Good afternoon";
  return "Good evening";
}

export default function DashboardPage() {
  const { data: session } = useSession();
  const { data, isLoading, error } = useQuery({ queryKey: ["analytics"], queryFn: () => api<Analytics>("/admin/analytics") });

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-28" />
        <div className="grid gap-4 md:grid-cols-4">
          {Array.from({ length: 4 }).map((_, i) => <Skeleton key={i} className="h-32" />)}
        </div>
        <div className="grid gap-4 lg:grid-cols-2">
          {Array.from({ length: 2 }).map((_, i) => <Skeleton key={i} className="h-64" />)}
        </div>
      </div>
    );
  }
  if (error) return <Card className="text-red-700">Unable to load analytics.</Card>;

  const metrics = [
    { label: "Total citizens", value: data?.totalUsers ?? 0, icon: Users, max: 1000 },
    { label: "Active citizens", value: data?.activeUsers ?? 0, icon: Activity, max: data?.totalUsers || 1 },
    { label: "Avg. Political IQ", value: data?.averagePoliticalIq ?? 0, icon: BarChart3, max: 1000 },
    { label: "Module completion", value: `${data?.completionPercent ?? 0}%`, icon: Trophy, max: 100, raw: data?.completionPercent ?? 0 }
  ];

  const contentHealth = [
    { label: "Modules", value: data?.totalModules ?? 0 },
    { label: "Lessons", value: data?.totalLessons ?? 0 },
    { label: "Quizzes", value: data?.totalQuizzes ?? 0 },
    { label: "Questions", value: data?.totalQuestions ?? 0 },
    { label: "Daily challenges", value: data?.dailyChallenges ?? 0 },
    { label: "Active debates", value: data?.activeDebates ?? 0 }
  ];
  const topSchools = data?.topSchools ?? [];
  const firstName = session?.user?.name?.split(" ")[0] ?? "Admin";

  return (
    <div className="space-y-6">
      {/* Page header */}
      <section className="relative overflow-hidden rounded-2xl border border-[#e8e1d6] bg-white p-6 shadow-soft">
        <div className="absolute right-0 top-0 h-full w-64 bg-[linear-gradient(135deg,rgba(255,157,37,0.06),transparent)]" />
        <div className="relative flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
          <div>
            <p className="text-sm font-semibold text-slate-400">{greeting()}, {firstName}</p>
            <h1 className="mt-1 text-3xl font-black tracking-normal text-navy">Swaraj Dashboard</h1>
            <p className="mt-2 max-w-xl text-sm text-slate-500">
              Manage learning modules, citizen records, quizzes, and platform analytics.
            </p>
          </div>
          <div className="flex shrink-0 items-center gap-2 rounded-xl border border-[#eadfce] bg-[#fbfaf6] px-4 py-3">
            <TrendingUp size={16} className="text-saffron" />
            <div>
              <p className="text-[10px] font-extrabold uppercase tracking-widest text-slate-400">Completion</p>
              <p className="text-lg font-black text-navy">{data?.completionPercent ?? 0}%</p>
            </div>
          </div>
        </div>
      </section>

      {/* Metrics */}
      <section className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {metrics.map((metric) => {
          const Icon = metric.icon;
          const rawVal = typeof metric.value === "number" ? metric.value : metric.raw ?? 0;
          const pct = Math.min(100, (rawVal / (metric.max ?? 1)) * 100);
          return (
            <Card key={metric.label} className="relative overflow-hidden">
              <div className="flex items-start justify-between">
                <p className="text-xs font-extrabold uppercase tracking-wider text-slate-400">{metric.label}</p>
                <div className="grid h-8 w-8 place-items-center rounded-lg bg-[#fff4e5] text-saffron">
                  <Icon size={16} />
                </div>
              </div>
              <p className="mt-4 text-3xl font-black tracking-normal text-navy">{metric.value}</p>
              <div className="mt-3 h-1 w-full overflow-hidden rounded-full bg-[#f0e8dd]">
                <div
                  className="h-full rounded-full bg-saffron transition-all"
                  style={{ width: `${pct}%` }}
                />
              </div>
            </Card>
          );
        })}
      </section>

      {/* Quick actions + Content health */}
      <section className="grid gap-4 lg:grid-cols-[1fr_0.65fr]">
        <Card>
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-base font-black text-navy">Quick actions</h2>
              <p className="mt-0.5 text-xs text-slate-400">Common admin tasks</p>
            </div>
            <ClipboardList className="text-saffron" size={20} />
          </div>
          <div className="mt-4 grid gap-2.5 sm:grid-cols-2">
            {quickActions.map((action) => {
              const Icon = action.icon;
              return (
                <Link
                  key={action.href}
                  href={action.href}
                  className="group flex items-center gap-3 rounded-xl border border-[#eadfce] bg-[#fbfaf6] p-3.5 transition hover:-translate-y-0.5 hover:border-saffron/40 hover:bg-[#fff8ed] hover:shadow-md"
                >
                  <span className="grid h-9 w-9 shrink-0 place-items-center rounded-lg bg-navy text-saffron transition group-hover:bg-[#102f55]">
                    <Icon size={17} />
                  </span>
                  <span>
                    <span className="block text-sm font-black text-navy">{action.label}</span>
                    <span className="mt-0.5 block text-[11px] text-slate-500">{action.helper}</span>
                  </span>
                </Link>
              );
            })}
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-base font-black text-navy">Content health</h2>
              <p className="mt-0.5 text-xs text-slate-400">Live counts from backend</p>
            </div>
            <BookOpenCheck className="text-saffron" size={20} />
          </div>
          <div className="mt-4 divide-y divide-[#f5f0ea]">
            {contentHealth.map((item) => (
              <div key={item.label} className="flex items-center justify-between py-2.5">
                <span className="text-sm font-semibold text-slate-600">{item.label}</span>
                <span className="rounded-full bg-[#fff4e5] px-3 py-0.5 text-sm font-extrabold text-saffron">{item.value}</span>
              </div>
            ))}
          </div>
        </Card>
      </section>

      {/* Top schools */}
      {topSchools.length > 0 && (
        <Card>
          <h2 className="text-base font-black text-navy">Top schools</h2>
          <p className="mt-0.5 text-xs text-slate-400">Ranked by citizen onboarding</p>
          <div className="mt-4 grid gap-2 sm:grid-cols-2 lg:grid-cols-3">
            {topSchools.map((school, i) => (
              <div key={school.id} className="flex items-center justify-between rounded-xl border border-[#eadfce] bg-[#fbfaf6] px-4 py-3">
                <div className="flex items-center gap-3">
                  <span className="grid h-7 w-7 place-items-center rounded-lg bg-navy text-[11px] font-black text-saffron">{i + 1}</span>
                  <span className="text-sm font-semibold text-navy">{school.name}</span>
                </div>
                <span className="text-xs font-extrabold text-saffron">{school.students}</span>
              </div>
            ))}
          </div>
        </Card>
      )}
    </div>
  );
}
