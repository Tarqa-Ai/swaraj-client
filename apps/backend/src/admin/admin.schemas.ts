import { z } from "zod";

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

export type SchoolBody = z.infer<typeof schoolSchema>;
export type ModuleBody = z.infer<typeof moduleSchema>;
export type LessonBody = z.infer<typeof lessonSchema>;
export type DebateBody = z.infer<typeof debateSchema>;
export type ChallengeBody = z.infer<typeof challengeSchema>;
