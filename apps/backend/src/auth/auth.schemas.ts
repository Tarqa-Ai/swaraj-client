import { z } from "zod";

export const adminLoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8)
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(20)
});

export const adminGoogleLoginSchema = z.object({
  idToken: z.string().min(10)
});

export const sendOtpSchema = z.object({
  email: z.string().email(),
  phone: z.string().regex(/^[6-9]\d{9}$/, "Must be a valid 10-digit Indian mobile number"),
});

export const verifyOtpSchema = z.object({
  email: z.string().email(),
  code: z.string().length(6),
});

export type AdminLoginBody = z.infer<typeof adminLoginSchema>;
export type RefreshBody = z.infer<typeof refreshSchema>;
export type AdminGoogleLoginBody = z.infer<typeof adminGoogleLoginSchema>;
export type SendOtpBody = z.infer<typeof sendOtpSchema>;
export type VerifyOtpBody = z.infer<typeof verifyOtpSchema>;
