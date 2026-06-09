import type { Metadata } from "next";
import { Syne, DM_Sans, Space_Mono } from "next/font/google";
import "./globals.css";
import { Providers } from "@/components/providers";
import { AdminShell } from "@/components/admin-shell";

const syne = Syne({
  subsets: ["latin"],
  variable: "--font-syne",
  weight: ["600", "700", "800"]
});

const dmSans = DM_Sans({
  subsets: ["latin"],
  variable: "--font-dm-sans",
  weight: ["400", "700"]
});

const spaceMono = Space_Mono({
  subsets: ["latin"],
  variable: "--font-space-mono",
  weight: ["400", "700"]
});

export const metadata: Metadata = {
  title: "SWARAJ | Civic Learning & Leadership Platform",
  description: "Empowering Grade 9–12 students to become informed, active citizens through structured civic exploration and AI evaluations."
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={`${syne.variable} ${dmSans.variable} ${spaceMono.variable}`}>
      <body>
        <Providers>
          <AdminShell>{children}</AdminShell>
        </Providers>
      </body>
    </html>
  );
}
