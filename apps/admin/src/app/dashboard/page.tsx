"use client";

import { useQuery } from "@tanstack/react-query";
import { Activity, BarChart3, MessageSquare, School, Trophy, Users } from "lucide-react";
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
    { label: "Schools tracked", value: data?.topSchools.length ?? 0, icon: School }
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-black text-navy">Admin Dashboard</h1>
        <p className="mt-1 text-slate-600">Live view of civic learning progress across Rajasthan schools.</p>
      </div>
      <section className="grid gap-4 md:grid-cols-3">
        {metrics.map((metric) => {
          const Icon = metric.icon;
          return (
            <Card key={metric.label}>
              <div className="flex items-center justify-between">
                <p className="text-sm font-medium text-slate-600">{metric.label}</p>
                <Icon className="text-saffron" size={22} />
              </div>
              <p className="mt-4 text-3xl font-black text-navy">{metric.value}</p>
            </Card>
          );
        })}
      </section>
      <Card>
        <h2 className="text-lg font-bold text-navy">Top schools</h2>
        <div className="mt-4 divide-y divide-slate-100">
          {data?.topSchools.map((school) => (
            <div key={school.id} className="flex items-center justify-between py-3">
              <span className="font-medium">{school.name}</span>
              <span className="rounded-full bg-orange-50 px-3 py-1 text-sm font-semibold text-saffron">{school.students} students</span>
            </div>
          ))}
        </div>
      </Card>
    </div>
  );
}
