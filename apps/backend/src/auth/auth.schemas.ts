import { z } from "zod";

export const sendOtpSchema = z.object({
  phone: z.string().regex(/^\+?91?[6-9]\d{9}$/, "Enter a valid Indian mobile number")
});

export const verifyOtpSchema = z.object({
  phone: z.string().regex(/^\+?91?[6-9]\d{9}$/),
  code: z.string().regex(/^\d{6}$/),
  name: z.string().min(2).max(80).optional(),
  grade: z.number().int().min(9).max(12).optional(),
  schoolId: z.string().optional(),
  language: z.enum(["en", "hi"]).optional()
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(20)
});

export const adminLoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8)
});

export type SendOtpBody = z.infer<typeof sendOtpSchema>;
export type VerifyOtpBody = z.infer<typeof verifyOtpSchema>;
export type RefreshBody = z.infer<typeof refreshSchema>;
export type AdminLoginBody = z.infer<typeof adminLoginSchema>;
