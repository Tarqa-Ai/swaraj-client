import type { NextConfig } from "next";
import path from "path";

const nextConfig: NextConfig = {
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:4000/api"
  },
  outputFileTracingRoot: path.join(__dirname, "../../"),
  async redirects() {
    return [
      {
        source: "/admin",
        destination: "/dashboard",
        permanent: true
      }
    ];
  }
};

export default nextConfig;
