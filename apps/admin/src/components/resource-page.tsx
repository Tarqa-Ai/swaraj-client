"use client";

import type { ReactNode } from "react";
import { FormEvent, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Pencil, Plus, Trash2 } from "lucide-react";
import { api, del, patch, post } from "@/lib/api";
import { Button, Card, EmptyState, Input, Skeleton, Textarea } from "./ui";

type ResourcePageProps<T extends Record<string, unknown>> = {
  title: string;
  description: string;
  endpoint: string;
  columns: Array<{ key: string; label: string; render?: (item: T) => ReactNode }>;
  fields?: ResourceField[];
  deletable?: boolean;
};

type ResourceField = {
  key: string;
  label: string;
  type?: "text" | "number" | "date" | "textarea" | "json" | "boolean" | "select";
  required?: boolean;
  help?: string;
  placeholder?: string;
  fullWidth?: boolean;
  options?: Array<{ label: string; value: string }>;
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
    setErrorMessage(null);
    const form = new FormData(event.currentTarget);
    const body: Record<string, unknown> = {};

    for (const field of fields) {
      const raw = form.get(field.key)?.toString() ?? "";
      if (raw.trim() === "") continue;

      if (field.type === "number") {
        body[field.key] = Number(raw);
        continue;
      }
      if (field.type === "boolean") {
        body[field.key] = raw === "true";
        continue;
      }
      if (field.type === "json") {
        try {
          body[field.key] = JSON.parse(raw);
        } catch {
          setErrorMessage(`${field.label} must be valid JSON.`);
          return;
        }
        continue;
      }
      body[field.key] = raw;
    }

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
              <label key={field.key} className={`block text-xs font-extrabold uppercase tracking-normal text-slate-500 ${field.fullWidth ? "md:col-span-2" : ""}`}>
                {field.label}
                {field.type === "textarea" || field.type === "json" ? (
                  <Textarea
                    name={field.key}
                    required={field.required}
                    defaultValue={formatDefault(editing?.[field.key], field.type)}
                    placeholder={field.placeholder}
                    className={field.type === "json" ? "mt-2 min-h-36 font-mono text-xs normal-case tracking-normal" : "mt-2"}
                  />
                ) : field.type === "boolean" ? (
                  <select name={field.key} defaultValue={String(editing?.[field.key] ?? false)} className="mt-2 h-10 w-full rounded-lg border border-[#d8d1c7] bg-white px-3 py-2 text-sm font-semibold normal-case tracking-normal text-navy outline-none focus:border-saffron focus:ring-2 focus:ring-orange-100">
                    <option value="false">No</option>
                    <option value="true">Yes</option>
                  </select>
                ) : field.type === "select" ? (
                  <select
                    name={field.key}
                    required={field.required}
                    defaultValue={formatDefault(editing?.[field.key], field.type)}
                    className="mt-2 h-10 w-full rounded-lg border border-[#d8d1c7] bg-white px-3 py-2 text-sm font-semibold normal-case tracking-normal text-navy outline-none focus:border-saffron focus:ring-2 focus:ring-orange-100"
                  >
                    <option value="">Select {field.label.toLowerCase()}</option>
                    {(field.options ?? []).map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                ) : (
                  <Input
                    name={field.key}
                    type={field.type ?? "text"}
                    required={field.required}
                    defaultValue={formatDefault(editing?.[field.key], field.type)}
                    placeholder={field.placeholder}
                    className="mt-2"
                  />
                )}
                {field.help ? <span className="mt-1 block text-[11px] font-medium normal-case leading-5 tracking-normal text-slate-500">{field.help}</span> : null}
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
                      {renderCell(item, column)}
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

function renderCell<T extends Record<string, unknown>>(item: T, column: { key: string; render?: (item: T) => ReactNode }) {
  if (column.render) return column.render(item);
  const value = item[column.key];
  if (value == null) return "";
  if (typeof value === "boolean") return value ? "Yes" : "No";
  if (typeof value === "object") return JSON.stringify(value);
  return String(value);
}

function formatDefault(value: unknown, type?: ResourceField["type"]) {
  if (value == null) return "";
  if (type === "json") return JSON.stringify(value, null, 2);
  if (type === "date") return String(value).slice(0, 10);
  return String(value);
}
