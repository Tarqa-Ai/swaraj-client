import { z } from "zod";

export const adminLoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8)
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(20)
});

export type AdminLoginBody = z.infer<typeof adminLoginSchema>;
export type RefreshBody = z.infer<typeof refreshSchema>;
