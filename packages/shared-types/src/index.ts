export type Language = "en" | "hi";
export type UserRole = "STUDENT" | "ADMIN";
export type Grade = 9 | 10 | 11 | 12;
export type LessonType = "TEXT" | "IMAGE" | "INFOGRAPHIC";
export type QuizQuestionType = "MCQ" | "TRUE_FALSE" | "MATCH_COLUMN";
export type DebateSide = "FOR" | "AGAINST";
export type ChallengeCategory = "INDIA_TODAY" | "PARLIAMENT_WATCH" | "CIVIC_AWARENESS";
export type PoliticalLevel = "Citizen" | "Volunteer" | "Leader" | "Young Minister";

export interface ApiEnvelope<T> {
  data: T;
  requestId?: string;
}

export interface Paginated<T> {
  items: T[];
  page: number;
  limit: number;
  total: number;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface StudentProfile {
  id: string;
  name: string | null;
  phone: string;
  grade: Grade | null;
  language: Language;
  politicalIq: number;
  streakCount: number;
  school?: {
    id: string;
    name: string;
    district: string;
  } | null;
}

export interface DashboardSummary {
  politicalIq: number;
  level: PoliticalLevel;
  streakCount: number;
  leaderboardRank: number | null;
  completedModules: number;
  totalModules: number;
  badges: string[];
  nextModuleId?: string;
}
