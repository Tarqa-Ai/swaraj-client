"use client";

import { useQuery } from "@tanstack/react-query";
import { ExternalLink } from "lucide-react";
import { Card, EmptyState, Skeleton } from "@/components/ui";
import { api } from "@/lib/api";

type CertificateItem = {
  id: string;
  title: string;
  certificateUrl: string;
  verificationCode: string;
  issuedAt: string;
  user?: {
    name?: string | null;
    phone?: string | null;
    school?: {
      name?: string | null;
    } | null;
  } | null;
};

export default function CertificatesPage() {
  const { data = [], isLoading, error } = useQuery({
    queryKey: ["/admin/certificates"],
    queryFn: () => api<CertificateItem[]>("/admin/certificates")
  });

  return (
    <div className="space-y-6">
      <div className="rounded-lg border border-[#e8e1d6] bg-white p-6 shadow-soft">
        <p className="text-[11px] font-extrabold uppercase tracking-normal text-saffron">SWARAJ Admin</p>
        <h1 className="mt-2 text-4xl font-black leading-tight tracking-normal text-navy">Certificates</h1>
        <p className="mt-2 max-w-2xl text-slate-600">Issued Certified Young Civic Leader records from the citizen app.</p>
      </div>

      {isLoading ? <Skeleton className="h-80" /> : null}
      {error ? <Card className="text-red-700">Unable to load certificates.</Card> : null}
      {!isLoading && !error && data.length === 0 ? <EmptyState title="No certificates yet" body="Certificates will appear after eligible citizens generate them." /> : null}

      {data.length > 0 ? (
        <Card className="overflow-x-auto !p-0">
          <table className="w-full min-w-[900px] text-left text-sm">
            <thead className="bg-[#fff8ed] text-xs uppercase text-slate-500">
              <tr>
                <th className="px-4 py-3 font-extrabold tracking-normal">Citizen</th>
                <th className="px-4 py-3 font-extrabold tracking-normal">Phone</th>
                <th className="px-4 py-3 font-extrabold tracking-normal">School</th>
                <th className="px-4 py-3 font-extrabold tracking-normal">Certificate</th>
                <th className="px-4 py-3 font-extrabold tracking-normal">Verification</th>
                <th className="px-4 py-3 font-extrabold tracking-normal">Issued</th>
                <th className="px-4 py-3 font-extrabold tracking-normal">File</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#f0e8dd]">
              {data.map((certificate) => (
                <tr key={certificate.id} className="hover:bg-[#fffaf2]">
                  <td className="px-4 py-3 font-medium text-slate-700">{certificate.user?.name ?? "Unnamed citizen"}</td>
                  <td className="px-4 py-3 font-medium text-slate-700">{certificate.user?.phone ?? ""}</td>
                  <td className="px-4 py-3 font-medium text-slate-700">{certificate.user?.school?.name ?? ""}</td>
                  <td className="px-4 py-3 font-medium text-slate-700">{certificate.title}</td>
                  <td className="px-4 py-3 font-mono text-xs font-semibold text-slate-700">{certificate.verificationCode}</td>
                  <td className="px-4 py-3 font-medium text-slate-700">{formatDate(certificate.issuedAt)}</td>
                  <td className="px-4 py-3">
                    {certificate.certificateUrl.startsWith("http") ? (
                      <a className="inline-flex items-center gap-1 text-sm font-extrabold text-navy hover:text-saffron" href={certificate.certificateUrl} target="_blank" rel="noreferrer">
                        Open
                        <ExternalLink size={14} />
                      </a>
                    ) : (
                      <span className="font-mono text-xs text-slate-500">{certificate.certificateUrl}</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </Card>
      ) : null}
    </div>
  );
}

function formatDate(value: string) {
  return new Intl.DateTimeFormat("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric"
  }).format(new Date(value));
}
