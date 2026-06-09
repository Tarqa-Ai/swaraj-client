import { useAuthStore } from "@/store/auth";

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "https://swaraj-backend-dkgn.onrender.com/api";

let isRefreshing = false;
const refreshQueue: Array<(token: string | null) => void> = [];

async function attemptTokenRefresh(): Promise<string | null> {
  const { refreshToken, setTokens, logout } = useAuthStore.getState();
  if (!refreshToken) return null;

  try {
    const response = await fetch(`${API_URL}/auth/refresh`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ refreshToken })
    });
    if (!response.ok) {
      logout();
      return null;
    }
    const tokens = (await response.json()) as { accessToken: string; refreshToken: string };
    setTokens(tokens);
    return tokens.accessToken;
  } catch {
    logout();
    return null;
  }
}

function buildHeaders(token: string | null, extra?: HeadersInit): HeadersInit {
  return {
    "content-type": "application/json",
    ...(token ? { authorization: `Bearer ${token}` } : {}),
    ...extra
  };
}

export async function api<T>(path: string, init: RequestInit = {}): Promise<T> {
  const token = useAuthStore.getState().accessToken;

  let response = await fetch(`${API_URL}${path}`, {
    ...init,
    headers: buildHeaders(token, init.headers)
  });

  if (response.status === 401 && path !== "/auth/admin/login") {
    let newToken: string | null;

    if (isRefreshing) {
      newToken = await new Promise<string | null>((resolve) => refreshQueue.push(resolve));
    } else {
      isRefreshing = true;
      newToken = await attemptTokenRefresh();
      refreshQueue.forEach((resolve) => resolve(newToken));
      refreshQueue.length = 0;
      isRefreshing = false;
    }

    if (!newToken) {
      if (typeof window !== "undefined") window.location.replace("/login");
      throw new Error("Session expired. Please sign in again.");
    }

    response = await fetch(`${API_URL}${path}`, {
      ...init,
      headers: buildHeaders(newToken, init.headers)
    });
  }

  if (!response.ok) {
    const text = await response.text();
    throw new Error(text || `Request failed: ${response.status}`);
  }
  return response.json() as Promise<T>;
}

export function post<T>(path: string, body: unknown) {
  return api<T>(path, { method: "POST", body: JSON.stringify(body) });
}

export function patch<T>(path: string, body: unknown) {
  return api<T>(path, { method: "PATCH", body: JSON.stringify(body) });
}

export function del<T>(path: string) {
  return api<T>(path, { method: "DELETE" });
}
