"use client";

import { FormEvent, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Pencil, Plus, Trash2 } from "lucide-react";
import { api, del, patch, post } from "@/lib/api";
import { Button, Card, EmptyState, Input, Skeleton, Textarea } from "./ui";

type ResourcePageProps<T extends Record<string, unknown>> = {
  title: string;
  description: string;
  endpoint: string;
  columns: Array<{ key: string; label: string }>;
  fields?: ResourceField[];
  deletable?: boolean;
};

type ResourceField = {
  key: string;
  label: string;
  type?: "text" | "number" | "date" | "textarea" | "json" | "boolean";
  required?: boolean;
};

export function ResourcePage<T extends Record<string, unknown>>({ title, description, endpoint, columns, fields = [], deletable = false }: ResourcePageProps<T>) {
  const queryClient = useQueryClient();
  const [editing, setEditing] = useState<T | null>(null);
  const [formOpen, setFormOpen] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const { data, isLoading, error } = useQuery({
    queryKey: [endpoint],
    queryFn: () => api<T[] | { items: T[] }>(endpoint)
  });
  const saveMutation = useMutation({
    mutationFn: (body: Record<string, unknown>) => {
      if (editing?.id) return patch(`${endpoint}/${String(editing.id)}`, body);
      return post(endpoint, body);
    },
    onSuccess: async () => {
      setEditing(null);
      setFormOpen(false);
      setErrorMessage(null);
      await queryClient.invalidateQueries({ queryKey: [endpoint] });
    },
    onError: (err) => setErrorMessage(err instanceof Error ? err.message : "Save failed")
  });
  const deleteMutation = useMutation({
    mutationFn: (id: string) => del(`${endpoint}/${id}`),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [endpoint] })
  });

  const items = Array.isArray(data) ? data : data?.items ?? [];

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    const body = Object.fromEntries(
      fields.map((field) => {
        const raw = form.get(field.key)?.toString() ?? "";
        if (field.type === "number") return [field.key, Number(raw)];
        if (field.type === "boolean") return [field.key, raw === "true"];
        if (field.type === "json") return [field.key, JSON.parse(raw)];
        if (field.type === "date") return [field.key, raw];
        return [field.key, raw];
      }).filter(([, value]) => value !== "")
    );
    saveMutation.mutate(body);
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 rounded-lg border border-[#e8e1d6] bg-white p-6 shadow-soft sm:flex-row sm:items-start sm:justify-between">
        <div>
          <p className="text-[11px] font-extrabold uppercase tracking-normal text-saffron">SWARAJ Admin</p>
          <h1 className="mt-2 text-4xl font-black leading-tight tracking-normal text-navy">{title}</h1>
          <p className="mt-2 max-w-2xl text-slate-600">{description}</p>
        </div>
        {fields.length > 0 ? (
          <Button
            onClick={() => {
              setEditing(null);
              setFormOpen((open) => !open);
            }}
          >
            <Plus size={17} />
            {formOpen ? "Close" : `Add ${title}`}
          </Button>
        ) : null}
      </div>
      {formOpen && fields.length > 0 ? (
        <Card>
          <form className="grid gap-4 md:grid-cols-2" onSubmit={submit}>
            {fields.map((field) => (
              <label key={field.key} className="block text-xs font-extrabold uppercase tracking-normal text-slate-500">
                {field.label}
                {field.type === "textarea" || field.type === "json" ? (
                  <Textarea name={field.key} required={field.required} defaultValue={formatDefault(editing?.[field.key], field.type)} className="mt-1" />
                ) : field.type === "boolean" ? (
                  <select name={field.key} defaultValue={String(editing?.[field.key] ?? false)} className="mt-2 h-10 w-full rounded-lg border border-[#d8d1c7] bg-white px-3 py-2 text-sm font-semibold normal-case tracking-normal text-navy outline-none focus:border-saffron focus:ring-2 focus:ring-orange-100">
                    <option value="false">False</option>
                    <option value="true">True</option>
                  </select>
                ) : (
                  <Input name={field.key} type={field.type ?? "text"} required={field.required} defaultValue={formatDefault(editing?.[field.key], field.type)} className="mt-2" />
                )}
              </label>
            ))}
            {errorMessage ? <p className="md:col-span-2 rounded-lg bg-red-50 p-3 text-sm text-red-700">{errorMessage}</p> : null}
            <div className="md:col-span-2 flex justify-end gap-2">
              <Button type="button" variant="ghost" onClick={() => { setEditing(null); setFormOpen(false); }}>Cancel</Button>
              <Button disabled={saveMutation.isPending}>{saveMutation.isPending ? "Saving..." : "Save"}</Button>
            </div>
          </form>
        </Card>
      ) : null}
      {isLoading ? <Skeleton className="h-80" /> : null}
      {error ? <Card className="text-red-700">Unable to load {title.toLowerCase()}.</Card> : null}
      {!isLoading && !error && items.length === 0 ? <EmptyState title="No records yet" body="Records will appear here once available." /> : null}
      {items.length > 0 ? (
        <Card className="overflow-x-auto !p-0">
          <table className="w-full min-w-[720px] text-left text-sm">
            <thead className="bg-[#fff8ed] text-xs uppercase text-slate-500">
              <tr>
                {columns.map((column) => <th key={String(column.key)} className="px-4 py-3 font-extrabold tracking-normal">{column.label}</th>)}
                {fields.length > 0 || deletable ? <th className="px-4 py-3">Actions</th> : null}
              </tr>
            </thead>
            <tbody className="divide-y divide-[#f0e8dd]">
              {items.map((item, index) => (
                <tr key={String(item.id ?? index)} className="hover:bg-[#fffaf2]">
                  {columns.map((column) => (
                    <td key={String(column.key)} className="px-4 py-3 font-medium text-slate-700">
                      {String(item[column.key] ?? "")}
                    </td>
                  ))}
                  {fields.length > 0 || deletable ? (
                    <td className="whitespace-nowrap px-4 py-3">
                      <div className="inline-flex gap-2">
                        {fields.length > 0 ? (
                          <Button
                            type="button"
                            variant="ghost"
                            onClick={() => {
                              setEditing(item);
                              setFormOpen(true);
                            }}
                          >
                            <Pencil size={15} />
                            Edit
                          </Button>
                        ) : null}
                        {fields.length > 0 || deletable ? (
                          <Button type="button" variant="ghost" onClick={() => item.id && deleteMutation.mutate(String(item.id))}>
                            <Trash2 size={15} />
                            Delete
                          </Button>
                        ) : null}
                      </div>
                    </td>
                  ) : null}
                </tr>
              ))}
            </tbody>
          </table>
        </Card>
      ) : null}
    </div>
  );
}

function formatDefault(value: unknown, type?: ResourceField["type"]) {
  if (value == null) return "";
  if (type === "json") return JSON.stringify(value, null, 2);
  if (type === "date") return String(value).slice(0, 10);
  return String(value);
}
