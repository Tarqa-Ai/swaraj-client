import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        navy: "#071D36",
        saffron: "#FF9D25",
        cream: "#FBFAF6",
        ink: "#111827"
      },
      boxShadow: {
        soft: "0 16px 40px rgba(7, 29, 54, 0.08)"
      }
    }
  },
  plugins: []
};

export default config;
