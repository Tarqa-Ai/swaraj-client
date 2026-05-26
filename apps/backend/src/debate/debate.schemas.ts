import { z } from "zod";

export const debateResponseSchema = z.object({
  debateId: z.string().min(1),
  side: z.enum(["FOR", "AGAINST"]),
  reflection: z.string().min(30).max(800)
});

export type DebateResponseBody = z.infer<typeof debateResponseSchema>;
