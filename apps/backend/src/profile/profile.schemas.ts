import { z } from "zod";

export const updateProfileSchema = z.object({
  name: z.string().min(2).max(80),
  grade: z.number().int().min(9).max(12),
  schoolId: z.string().min(1),
  language: z.enum(["en", "hi"])
});

export type UpdateProfileBody = z.infer<typeof updateProfileSchema>;

export const createSchoolSchema = z.object({
  name: z.string().min(3).max(200),
  district: z.string().min(2).max(100),
  state: z.string().min(2).max(100).optional().default("Rajasthan"),
});

export type CreateSchoolBody = z.infer<typeof createSchoolSchema>;
