import type { PoliticalLevel } from "@swaraj/shared-types";

export const POLITICAL_IQ_POINTS = {
  lessonCompletion: 10,
  moduleCompletion: 50,
  debateParticipation: 35,
  dailyChallengeParticipation: 20,
  dailyChallengePerfect: 20,
  streakMilestone: 25
} as const;

export const LEVEL_THRESHOLDS: Array<{ level: PoliticalLevel; min: number }> = [
  { level: "Citizen", min: 0 },
  { level: "Volunteer", min: 250 },
  { level: "Leader", min: 700 },
  { level: "Young Minister", min: 1200 }
];

export const BADGES = {
  constitutionMaster: "Constitution Master",
  debateChampion: "Debate Champion",
  civicHero: "Civic Hero",
  democracyDefender: "Democracy Defender"
} as const;

export function getPoliticalLevel(points: number): PoliticalLevel {
  return [...LEVEL_THRESHOLDS].reverse().find((threshold) => points >= threshold.min)?.level ?? "Citizen";
}

export function scoreQuiz(correct: number, total: number): number {
  if (total <= 0) return 0;
  const accuracy = correct / total;
  return Math.round(accuracy * 100);
}

export function clampPage(input: unknown): number {
  const parsed = Number(input);
  return Number.isFinite(parsed) && parsed > 0 ? Math.floor(parsed) : 1;
}

export function clampLimit(input: unknown, max = 50): number {
  const parsed = Number(input);
  if (!Number.isFinite(parsed) || parsed <= 0) return 20;
  return Math.min(Math.floor(parsed), max);
}
