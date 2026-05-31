import clsx from "clsx";

export function Button(props: React.ButtonHTMLAttributes<HTMLButtonElement> & { variant?: "primary" | "secondary" | "ghost" }) {
  const { className, variant = "primary", ...rest } = props;
  return (
    <button
      className={clsx(
        "inline-flex items-center justify-center gap-2 rounded-lg px-4 py-2 text-sm font-semibold transition focus:outline-none focus:ring-2 focus:ring-saffron disabled:cursor-not-allowed disabled:opacity-60",
        variant === "primary" && "bg-navy text-white hover:bg-[#12345d]",
        variant === "secondary" && "bg-saffron text-white hover:bg-[#d9781f]",
        variant === "ghost" && "bg-transparent text-navy hover:bg-slate-100",
        className
      )}
      {...rest}
    />
  );
}

export function Card({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={clsx("rounded-xl border border-slate-200 bg-white p-5 shadow-soft", className)} {...props} />;
}

export function Input(props: React.InputHTMLAttributes<HTMLInputElement>) {
  return <input className="w-full rounded-lg border border-slate-300 px-3 py-2 outline-none focus:border-saffron focus:ring-2 focus:ring-orange-100" {...props} />;
}

export function Textarea(props: React.TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return <textarea className="min-h-28 w-full rounded-lg border border-slate-300 px-3 py-2 outline-none focus:border-saffron focus:ring-2 focus:ring-orange-100" {...props} />;
}

export function Skeleton({ className }: { className?: string }) {
  return <div className={clsx("animate-pulse rounded-lg bg-slate-200", className)} />;
}

export function EmptyState({ title, body }: { title: string; body: string }) {
  return (
    <div className="rounded-xl border border-dashed border-slate-300 bg-white p-8 text-center">
      <p className="font-semibold text-navy">{title}</p>
      <p className="mt-2 text-sm text-slate-600">{body}</p>
    </div>
  );
}
