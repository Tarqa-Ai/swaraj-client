import { auth } from "@/auth";
import { NextResponse } from "next/server";

export async function GET() {
  const session = await auth();

  if (!session?.user?.email) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  if (!session.googleIdToken) {
    return NextResponse.json({ error: "No Google ID token in session" }, { status: 401 });
  }

  const backendUrl = process.env.BACKEND_URL ?? process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:4000/api";

  try {
    const res = await fetch(`${backendUrl}/auth/admin/google`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ idToken: session.googleIdToken })
    });

    if (!res.ok) {
      const text = await res.text();
      return NextResponse.json({ error: text || "Backend auth failed" }, { status: res.status });
    }

    return NextResponse.json(await res.json());
  } catch {
    return NextResponse.json({ error: "Backend unreachable" }, { status: 503 });
  }
}
