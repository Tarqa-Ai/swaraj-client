import clsx from "clsx";
import { Shield } from "lucide-react";

export function Button(props: React.ButtonHTMLAttributes<HTMLButtonElement> & { variant?: "primary" | "secondary" | "ghost" }) {
  const { className, variant = "primary", ...rest } = props;
  return (
    <button
      className={clsx(
        "inline-flex min-h-10 items-center justify-center gap-2 rounded-lg px-4 py-2 text-sm font-extrabold tracking-normal transition focus:outline-none focus:ring-2 focus:ring-saffron/30 disabled:cursor-not-allowed disabled:opacity-60",
        variant === "primary" && "bg-navy text-white shadow-[0_12px_24px_rgba(7,29,54,0.16)] hover:bg-[#102f55]",
        variant === "secondary" && "bg-saffron text-navy shadow-[0_12px_24px_rgba(255,157,37,0.24)] hover:bg-[#f08d15]",
        variant === "ghost" && "bg-transparent text-navy hover:bg-[#fff4e5]",
        className
      )}
      {...rest}
    />
  );
}

export function Card({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={clsx("rounded-lg border border-[#e8e1d6] bg-white p-5 shadow-soft", className)} {...props} />;
}

export function Input({ className, ...props }: React.InputHTMLAttributes<HTMLInputElement>) {
  return (
    <input
      className={clsx("w-full rounded-lg border border-[#d8d1c7] bg-white px-3 py-2 text-navy outline-none transition placeholder:text-slate-400 focus:border-saffron focus:ring-2 focus:ring-orange-100", className)}
      {...props}
    />
  );
}

export function Textarea({ className, ...props }: React.TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return (
    <textarea
      className={clsx("min-h-28 w-full rounded-lg border border-[#d8d1c7] bg-white px-3 py-2 text-navy outline-none transition placeholder:text-slate-400 focus:border-saffron focus:ring-2 focus:ring-orange-100", className)}
      {...props}
    />
  );
}

export function Skeleton({ className }: { className?: string }) {
  return <div className={clsx("animate-pulse rounded-lg bg-[#eee6db]", className)} />;
}

export function EmptyState({ title, body }: { title: string; body: string }) {
  return (
    <div className="rounded-lg border border-dashed border-[#d8d1c7] bg-white p-8 text-center">
      <p className="font-semibold text-navy">{title}</p>
      <p className="mt-2 text-sm text-slate-600">{body}</p>
    </div>
  );
}

export function SwarajLogo({ compact = false }: { compact?: boolean }) {
  return (
    <div className="flex items-center gap-3">
      <div className="grid h-12 w-12 place-items-center rounded-lg bg-navy text-saffron shadow-[0_14px_32px_rgba(7,29,54,0.2)]">
        <Shield size={24} fill="currentColor" strokeWidth={1.8} />
      </div>
      {!compact ? (
        <div>
          <p className="text-3xl font-black leading-none tracking-normal text-navy">SWARAJ</p>
          <p className="mt-1 text-[10px] font-extrabold uppercase tracking-normal text-saffron">Civic learning</p>
        </div>
      ) : null}
    </div>
  );
}
