"use client";

import { useQuery } from "@tanstack/react-query";
import { Activity, BarChart3, BookOpenCheck, MessageSquare, School, ShieldCheck, Trophy, Users } from "lucide-react";
import { api } from "@/lib/api";
import { Card, Skeleton } from "@/components/ui";

type Analytics = {
  totalUsers: number;
  activeUsers: number;
  completionPercent: number;
  averagePoliticalIq: number;
  debateParticipation: number;
  topSchools: Array<{ id: string; name: string; students: number }>;
};

export default function DashboardPage() {
  const { data, isLoading, error } = useQuery({ queryKey: ["analytics"], queryFn: () => api<Analytics>("/admin/analytics") });

  if (isLoading) {
    return <div className="grid gap-4 md:grid-cols-3">{Array.from({ length: 6 }).map((_, index) => <Skeleton key={index} className="h-32" />)}</div>;
  }
  if (error) return <Card className="text-red-700">Unable to load analytics.</Card>;

  const metrics = [
    { label: "Total students", value: data?.totalUsers ?? 0, icon: Users },
    { label: "Active users", value: data?.activeUsers ?? 0, icon: Activity },
    { label: "Completion", value: `${data?.completionPercent ?? 0}%`, icon: Trophy },
    { label: "Average Political IQ", value: data?.averagePoliticalIq ?? 0, icon: BarChart3 },
    { label: "Debate responses", value: data?.debateParticipation ?? 0, icon: MessageSquare },
    { label: "Schools tracked", value: data?.topSchools?.length ?? 0, icon: School }
  ];
  const topSchools = data?.topSchools ?? [];

  return (
    <div className="space-y-6">
      <section className="rounded-lg border border-[#e8e1d6] bg-white p-6 shadow-soft">
        <div className="flex flex-col gap-5 lg:flex-row lg:items-end lg:justify-between">
          <div>
            <p className="inline-flex items-center gap-2 rounded-full bg-[#fff4e5] px-3 py-1 text-[11px] font-extrabold uppercase tracking-normal text-saffron">
              <ShieldCheck size={14} />
              Live Operations
            </p>
            <h1 className="mt-4 text-4xl font-black leading-tight tracking-normal text-navy">Admin Dashboard</h1>
            <p className="mt-2 max-w-2xl text-slate-600">Live view of citizen learning progress across the SWARAJ app.</p>
          </div>
          <div className="grid grid-cols-2 gap-3 sm:flex">
            <div className="rounded-lg border border-[#eadfce] bg-[#fbfaf6] px-4 py-3">
              <p className="text-[10px] font-extrabold uppercase tracking-normal text-slate-400">Mission</p>
              <p className="mt-1 text-sm font-bold text-navy">Viksit Bharat 2047</p>
            </div>
            <div className="rounded-lg border border-[#eadfce] bg-[#fbfaf6] px-4 py-3">
              <p className="text-[10px] font-extrabold uppercase tracking-normal text-slate-400">Mode</p>
              <p className="mt-1 text-sm font-bold text-navy">App Admin</p>
            </div>
          </div>
        </div>
      </section>

      <section className="grid gap-4 md:grid-cols-3">
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
              <h2 className="text-lg font-black text-navy">Top schools</h2>
              <p className="mt-1 text-sm text-slate-500">Highest current citizen participation</p>
            </div>
            <School className="text-saffron" size={22} />
          </div>
          <div className="mt-4 divide-y divide-[#f0e8dd]">
            {topSchools.map((school) => (
              <div key={school.id} className="flex items-center justify-between py-3">
                <span className="font-medium">{school.name}</span>
                <span className="rounded-full bg-[#fff4e5] px-3 py-1 text-sm font-extrabold text-saffron">{school.students} students</span>
              </div>
            ))}
          </div>
        </Card>

        <Card className="!border-navy !bg-navy text-white">
          <BookOpenCheck className="text-saffron" size={28} />
          <h2 className="mt-5 text-2xl font-black tracking-normal">Civic journey status</h2>
          <p className="mt-3 text-sm leading-6 text-white/70">Modules, debates, quizzes, and daily challenges all feed into Political IQ, achievements, leaderboard rank, and certificate eligibility.</p>
          <div className="mt-6 rounded-lg border border-white/10 bg-white/5 p-4">
            <p className="text-[10px] font-extrabold uppercase tracking-normal text-saffron">System note</p>
            <p className="mt-2 text-sm font-semibold text-white">Backend remains the source of truth for scoring.</p>
          </div>
        </Card>
      </section>
    </div>
  );
}
