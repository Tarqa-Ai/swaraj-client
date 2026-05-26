import { z } from "zod";

export const quizSubmitSchema = z.object({
  quizId: z.string().min(1),
  answers: z.record(z.union([z.string(), z.boolean(), z.array(z.object({ left: z.string(), right: z.string() }))]))
});

export type QuizSubmitBody = z.infer<typeof quizSubmitSchema>;
