import { z } from "zod";

export const dailyChallengeSubmitSchema = z.object({
  challengeId: z.string().min(1),
  answers: z.record(z.string())
});

export type DailyChallengeSubmitBody = z.infer<typeof dailyChallengeSubmitSchema>;
