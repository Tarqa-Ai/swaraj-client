import { z } from "zod";

export const explainSchema = z.object({
  question: z.string().min(3).max(300),
  language: z.enum(["en", "hi"]).default("en")
});

export type ExplainBody = z.infer<typeof explainSchema>;
