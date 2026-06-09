import type { NextConfig } from "next";
import path from "path";

const nextConfig: NextConfig = {
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL ?? "https://swaraj-backend-dkgn.onrender.com/api"
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
