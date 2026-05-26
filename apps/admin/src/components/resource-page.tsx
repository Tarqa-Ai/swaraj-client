"use client";

import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { Card, EmptyState, Skeleton } from "./ui";

type ResourcePageProps<T extends Record<string, unknown>> = {
  title: string;
  description: string;
  endpoint: string;
  columns: Array<{ key: string; label: string }>;
};

export function ResourcePage<T extends Record<string, unknown>>({ title, description, endpoint, columns }: ResourcePageProps<T>) {
  const { data, isLoading, error } = useQuery({
    queryKey: [endpoint],
    queryFn: () => api<T[] | { items: T[] }>(endpoint)
  });

  const items = Array.isArray(data) ? data : data?.items ?? [];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-black text-navy">{title}</h1>
        <p className="mt-1 text-slate-600">{description}</p>
      </div>
      {isLoading ? <Skeleton className="h-80" /> : null}
      {error ? <Card className="text-red-700">Unable to load {title.toLowerCase()}.</Card> : null}
      {!isLoading && !error && items.length === 0 ? <EmptyState title="No records yet" body="Create content from the API or seed command to populate this table." /> : null}
      {items.length > 0 ? (
        <Card className="overflow-x-auto p-0">
          <table className="w-full min-w-[720px] text-left text-sm">
            <thead className="bg-slate-50 text-xs uppercase text-slate-500">
              <tr>{columns.map((column) => <th key={String(column.key)} className="px-4 py-3">{column.label}</th>)}</tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {items.map((item, index) => (
                <tr key={String(item.id ?? index)} className="hover:bg-slate-50">
                  {columns.map((column) => (
                    <td key={String(column.key)} className="px-4 py-3">
                      {String(item[column.key] ?? "")}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </Card>
      ) : null}
    </div>
  );
}
