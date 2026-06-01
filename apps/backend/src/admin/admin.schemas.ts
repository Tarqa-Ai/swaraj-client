import { z } from "zod";

export const studentUpdateSchema = z.object({
  name: z.string().min(2).optional(),
  phone: z.string().min(10).optional(),
  grade: z.coerce.number().int().min(9).max(12).optional(),
  language: z.enum(["en", "hi"]).optional(),
  schoolId: z.string().optional(),
  politicalIq: z.coerce.number().int().min(0).max(100).optional(),
  streakCount: z.coerce.number().int().min(0).optional()
});

export const schoolSchema = z.object({
  name: z.string().min(2),
  district: z.string().min(2),
  state: z.string().default("Rajasthan"),
  code: z.string().min(3)
});

export const moduleSchema = z.object({
  slug: z.string().min(3),
  titleEn: z.string().min(2),
  titleHi: z.string().min(2),
  descriptionEn: z.string().min(2),
  descriptionHi: z.string().min(2),
  illustrationUrl: z.string().url().optional(),
  order: z.number().int().positive(),
  estimatedMinutes: z.number().int().positive().default(15)
});

export const lessonSchema = z.object({
  moduleId: z.string(),
  type: z.enum(["TEXT", "IMAGE", "INFOGRAPHIC"]),
  titleEn: z.string().min(2),
  titleHi: z.string().min(2),
  bodyEn: z.string().min(2),
  bodyHi: z.string().min(2),
  mediaUrl: z.string().url().optional(),
  order: z.number().int().positive()
});

export const debateSchema = z.object({
  topicEn: z.string().min(5),
  topicHi: z.string().min(5),
  forSummaryEn: z.string().min(10),
  forSummaryHi: z.string().min(10),
  againstSummaryEn: z.string().min(10),
  againstSummaryHi: z.string().min(10),
  isActive: z.boolean().default(false)
});

export const challengeSchema = z.object({
  challengeDate: z.coerce.date(),
  category: z.enum(["INDIA_TODAY", "PARLIAMENT_WATCH", "CIVIC_AWARENESS"]),
  questions: z.array(
    z.object({
      id: z.string(),
      promptEn: z.string(),
      promptHi: z.string(),
      options: z.array(z.string()).min(2),
      answer: z.string(),
      explanationEn: z.string(),
      explanationHi: z.string()
    })
  ).length(3)
});

export const quizSchema = z.object({
  moduleId: z.string().min(1),
  titleEn: z.string().min(2),
  titleHi: z.string().min(2)
});

export const quizQuestionSchema = z.object({
  quizId: z.string().min(1),
  type: z.enum(["MCQ", "TRUE_FALSE", "MATCH_COLUMN"]),
  promptEn: z.string().min(2),
  promptHi: z.string().min(2),
  options: z.unknown(),
  answer: z.unknown(),
  explanationEn: z.string().min(2),
  explanationHi: z.string().min(2),
  order: z.number().int().positive()
});

export const achievementSchema = z.object({
  code: z.string().min(3).regex(/^[A-Z_]+$/, "Code must be uppercase with underscores only"),
  titleEn: z.string().min(2),
  titleHi: z.string().min(2),
  descriptionEn: z.string().min(2),
  descriptionHi: z.string().min(2),
  icon: z.string().min(1)
});

export const partialSchoolSchema = schoolSchema.partial();
export const partialModuleSchema = moduleSchema.partial();
export const partialLessonSchema = lessonSchema.partial();
export const partialDebateSchema = debateSchema.partial();
export const partialChallengeSchema = challengeSchema.partial();
export const partialQuizSchema = quizSchema.partial();
export const partialQuizQuestionSchema = quizQuestionSchema.partial();
export const partialAchievementSchema = achievementSchema.partial();

export type StudentUpdateBody = z.infer<typeof studentUpdateSchema>;
export type SchoolBody = z.infer<typeof schoolSchema>;
export type ModuleBody = z.infer<typeof moduleSchema>;
export type LessonBody = z.infer<typeof lessonSchema>;
export type DebateBody = z.infer<typeof debateSchema>;
export type ChallengeBody = z.infer<typeof challengeSchema>;
export type QuizBody = z.infer<typeof quizSchema>;
export type QuizQuestionBody = z.infer<typeof quizQuestionSchema>;
export type AchievementBody = z.infer<typeof achievementSchema>;
