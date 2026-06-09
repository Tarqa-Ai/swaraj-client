import type { MetadataRoute } from "next";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: "/",
      disallow: [
        "/dashboard",
        "/login",
        "/students",
        "/modules",
        "/lessons",
        "/quizzes",
        "/quiz-questions",
        "/challenges",
        "/debates",
        "/leaderboard",
        "/certificates",
        "/achievements",
        "/schools",
        "/exports"
      ]
    }
  };
}
