"use client";

import { useQuery } from "@tanstack/react-query";
import Link from "next/link";
import { Activity, Award, BarChart3, BookOpenCheck, ClipboardList, HelpCircle, MessageSquare, ShieldCheck, Trophy, Users } from "lucide-react";
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

export default function DashboardPage() {
  const { data, isLoading, error } = useQuery({ queryKey: ["analytics"], queryFn: () => api<Analytics>("/admin/analytics") });

  if (isLoading) {
    return <div className="grid gap-4 md:grid-cols-3">{Array.from({ length: 6 }).map((_, index) => <Skeleton key={index} className="h-32" />)}</div>;
  }
  if (error) return <Card className="text-red-700">Unable to load analytics.</Card>;

  const metrics = [
    { label: "Total citizens", value: data?.totalUsers ?? 0, icon: Users },
    { label: "Active citizens", value: data?.activeUsers ?? 0, icon: Activity },
    { label: "Average Political IQ", value: data?.averagePoliticalIq ?? 0, icon: BarChart3 },
    { label: "Module completion", value: `${data?.completionPercent ?? 0}%`, icon: Trophy }
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

  return (
    <div className="space-y-6">
      <section className="rounded-lg border border-[#e8e1d6] bg-white p-6 shadow-soft">
        <div className="flex flex-col gap-5 lg:flex-row lg:items-end lg:justify-between">
          <div>
            <p className="inline-flex items-center gap-2 rounded-full bg-[#fff4e5] px-3 py-1 text-[11px] font-extrabold uppercase tracking-normal text-saffron">
              <ShieldCheck size={14} />
              App Admin Console
            </p>
            <h1 className="mt-4 text-4xl font-black leading-tight tracking-normal text-navy">Swaraj Operations</h1>
            <p className="mt-2 max-w-2xl text-slate-600">Manage citizen records, learning modules, quizzes, daily challenges, debate topics, certificates, and basic analytics for the mobile app.</p>
          </div>
          <div className="rounded-lg border border-[#eadfce] bg-[#fbfaf6] px-4 py-3">
            <p className="text-[10px] font-extrabold uppercase tracking-normal text-slate-400">Scope</p>
            <p className="mt-1 text-sm font-bold text-navy">MVP content and citizen admin</p>
          </div>
        </div>
      </section>

      <section className="grid gap-4 md:grid-cols-4">
        {metrics.map((metric) => {
          const Icon = metric.icon;
          return (
            <Card key={metric.label} className="relative overflow-hidden">
              <div className="absolute right-0 top-0 h-20 w-20 rounded-bl-full bg-[#fff4e5]" />
              <div className="flex items-center justify-between">
                <p className="text-sm font-extrabold text-slate-600">{metric.label}</p>
                <div className="relative grid h-10 w-10 place-items-center rounded-lg bg-navy text-saffron">
                  <Icon size={20} />
                </div>
              </div>
              <p className="mt-5 text-3xl font-black tracking-normal text-navy">{metric.value}</p>
            </Card>
          );
        })}
      </section>

      <section className="grid gap-4 lg:grid-cols-[1fr_0.72fr]">
        <Card>
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-lg font-black text-navy">Admin tasks</h2>
              <p className="mt-1 text-sm text-slate-500">Fast links for the app team.</p>
            </div>
            <ClipboardList className="text-saffron" size={22} />
          </div>
          <div className="mt-5 grid gap-3 sm:grid-cols-2">
            {quickActions.map((action) => {
              const Icon = action.icon;
              return (
                <Link key={action.href} href={action.href} className="rounded-lg border border-[#eadfce] bg-[#fbfaf6] p-4 transition hover:border-saffron hover:bg-[#fff8ed]">
                  <div className="flex items-center gap-3">
                    <span className="grid h-9 w-9 place-items-center rounded-lg bg-navy text-saffron">
                      <Icon size={18} />
                    </span>
                    <span>
                      <span className="block text-sm font-black text-navy">{action.label}</span>
                      <span className="mt-1 block text-xs font-semibold text-slate-500">{action.helper}</span>
                    </span>
                  </div>
                </Link>
              );
            })}
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-lg font-black text-navy">Content health</h2>
              <p className="mt-1 text-sm text-slate-500">Counts from the admin backend.</p>
            </div>
            <BookOpenCheck className="text-saffron" size={22} />
          </div>
          <div className="mt-5 divide-y divide-[#f0e8dd]">
            {contentHealth.map((item) => (
              <div key={item.label} className="flex items-center justify-between py-3">
                <span className="font-semibold text-slate-600">{item.label}</span>
                <span className="rounded-full bg-[#fff4e5] px-3 py-1 text-sm font-extrabold text-saffron">{item.value}</span>
              </div>
            ))}
          </div>
        </Card>
      </section>

      <section className="grid gap-4 lg:grid-cols-[0.8fr_1fr]">
        <Card>
          <h2 className="text-lg font-black text-navy">Top schools</h2>
          <p className="mt-1 text-sm text-slate-500">Based on citizen onboarding records.</p>
          <div className="mt-4 divide-y divide-[#f0e8dd]">
            {topSchools.length > 0 ? topSchools.map((school) => (
              <div key={school.id} className="flex items-center justify-between py-3">
                <span className="font-medium">{school.name}</span>
                <span className="rounded-full bg-[#fff4e5] px-3 py-1 text-sm font-extrabold text-saffron">{school.students} citizens</span>
              </div>
            )) : <p className="py-4 text-sm text-slate-500">No school data yet.</p>}
          </div>
        </Card>

        <Card className="!border-navy !bg-navy text-white">
          <h2 className="text-2xl font-black tracking-normal">Wiring notes</h2>
          <p className="mt-3 text-sm leading-6 text-white/70">This admin panel edits backend records for modules, lessons, quizzes, questions, daily challenges, debates, badges, certificates, and citizens. The mobile app should read these endpoints when backend integration is connected.</p>
          <div className="mt-6 grid gap-3 sm:grid-cols-3">
            <div className="rounded-lg border border-white/10 bg-white/5 p-4">
              <p className="text-[10px] font-extrabold uppercase tracking-normal text-saffron">Quiz</p>
              <p className="mt-2 text-sm font-semibold text-white">Questions include explanation fields.</p>
            </div>
            <div className="rounded-lg border border-white/10 bg-white/5 p-4">
              <p className="text-[10px] font-extrabold uppercase tracking-normal text-saffron">Modules</p>
              <p className="mt-2 text-sm font-semibold text-white">Order controls app display.</p>
            </div>
            <div className="rounded-lg border border-white/10 bg-white/5 p-4">
              <p className="text-[10px] font-extrabold uppercase tracking-normal text-saffron">Users</p>
              <p className="mt-2 text-sm font-semibold text-white">Citizen details can be corrected.</p>
            </div>
          </div>
        </Card>
      </section>
    </div>
  );
}
