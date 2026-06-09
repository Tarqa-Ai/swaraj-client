import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        navy: "#071D36",
        saffron: "#FF9D25",
        cream: "#FBFAF6",
        ink: "#111827",
        // Swaraj Editorial System Colors
        "institutional-navy": "#0B1F3A",
        "swaraj-saffron": "#F7921A",
        "cream-paper": "#FDFBF7",
        "forest-green": "#2D4739",
        "slate-grey": "#4A5568",
        "surface-container": "#efeeea",
        "surface-container-high": "#eae8e4",
        "surface-container-highest": "#e4e2de"
      },
      fontFamily: {
        syne: ["var(--font-syne)", "sans-serif"],
        "dm-sans": ["var(--font-dm-sans)", "sans-serif"],
        "space-mono": ["var(--font-space-mono)", "monospace"]
      },
      boxShadow: {
        soft: "0 16px 40px rgba(7, 29, 54, 0.08)",
        brutal: "4px 4px 0px 0px #0B1F3A"
      }
    }
  },
  plugins: []
};

export default config;
