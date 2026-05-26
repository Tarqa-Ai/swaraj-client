import type { Metadata } from "next";
import "./globals.css";
import { Providers } from "@/components/providers";
import { AdminShell } from "@/components/admin-shell";

export const metadata: Metadata = {
  title: "SWARAJ Admin",
  description: "School civic education administration panel"
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>
        <Providers>
          <AdminShell>{children}</AdminShell>
        </Providers>
      </body>
    </html>
  );
}
