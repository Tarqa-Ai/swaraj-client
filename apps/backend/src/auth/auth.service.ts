import { Injectable, UnauthorizedException, BadRequestException } from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { UserRole } from "@prisma/client";
import bcrypt from "bcryptjs";
import crypto from "crypto";
import { PrismaService } from "../prisma/prisma.service";
import { EmailService } from "../common/email/email.service";
import type { AdminLoginBody } from "./auth.schemas";

type GoogleTokenInfo = {
  aud: string;
  email: string;
  email_verified: string;
  exp: string;
};

interface OtpEntry {
  otp: string;
  phone: string;
  expiresAt: Date;
}

@Injectable()
export class AuthService {
  // In-memory OTP store: email → OtpEntry
  private readonly otpStore = new Map<string, OtpEntry>();

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly emailService: EmailService
  ) {}

  async sendOtp(email: string, phone: string): Promise<{ message: string }> {
    const otp = crypto.randomInt(100000, 999999).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    await this.emailService.sendOtp(email, otp);

    // Only store after successful send so a failed SMTP call doesn't leave stale OTPs.
    this.otpStore.set(email.toLowerCase(), { otp, phone, expiresAt });

    return { message: "OTP sent to your email address" };
  }

  async verifyOtp(email: string, code: string): Promise<{
    access_token: string;
    user: { id: string; email: string; name: string | null; phone: string | null; onboardingCompletedAt: Date | null; language: string };
  }> {
    const entry = this.otpStore.get(email.toLowerCase());

    if (!entry) {
      throw new BadRequestException("No OTP found for this email. Please request a new one.");
    }
    if (new Date() > entry.expiresAt) {
      this.otpStore.delete(email.toLowerCase());
      throw new BadRequestException("OTP has expired. Please request a new one.");
    }
    if (entry.otp !== code) {
      throw new UnauthorizedException("Invalid OTP. Please check and try again.");
    }

    this.otpStore.delete(email.toLowerCase());

    // Find or create user in Postgres by email or phone
    let user = await this.prisma.user.findFirst({
      where: { OR: [{ email: email.toLowerCase() }, { phone: entry.phone }] },
    });

    if (!user) {
      user = await this.prisma.user.create({
        data: { email: email.toLowerCase(), phone: entry.phone },
      });
    } else {
      const updates: Record<string, string> = {};
      if (!user.email) updates["email"] = email.toLowerCase();
      if (!user.phone) updates["phone"] = entry.phone;
      if (Object.keys(updates).length > 0) {
        user = await this.prisma.user.update({ where: { id: user.id }, data: updates });
      }
    }

    if (user.deletedAt) {
      throw new UnauthorizedException("This account has been suspended.");
    }

    // Issue a long-lived custom JWT for the student — the JwtAuthGuard accepts this via Path 2.
    const accessToken = await this.jwtService.signAsync(
      { id: user.id, role: "STUDENT" },
      { secret: process.env.JWT_ACCESS_SECRET, expiresIn: "90d" }
    );

    return {
      access_token: accessToken,
      user: {
        id: user.id,
        email: user.email ?? email,
        name: user.name,
        phone: user.phone,
        onboardingCompletedAt: user.onboardingCompletedAt,
        language: user.language,
      },
    };
  }

  async adminLogin(body: AdminLoginBody) {
    const admin = await this.prisma.adminUser.findUnique({ where: { email: body.email } });
    if (!admin || admin.deletedAt) throw new UnauthorizedException("Invalid admin credentials");
    const valid = await bcrypt.compare(body.password, admin.passwordHash);
    if (!valid) throw new UnauthorizedException("Invalid admin credentials");
    return this.issueAdminTokens(admin.id, admin.email);
  }

  async adminGoogleLogin(idToken: string) {
    const res = await fetch(`https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(idToken)}`);
    if (!res.ok) throw new UnauthorizedException("Invalid Google token");

    const info = (await res.json()) as GoogleTokenInfo;

    if (info.aud !== process.env.GOOGLE_CLIENT_ID) {
      throw new UnauthorizedException("Token audience mismatch");
    }

    if (info.email_verified !== "true") {
      throw new UnauthorizedException("Google email not verified");
    }

    const allowedEmail = process.env.ALLOWED_ADMIN_EMAIL;
    if (!allowedEmail || info.email !== allowedEmail) {
      throw new UnauthorizedException("Email not authorized for admin access");
    }

    const admin = await this.prisma.adminUser.findFirst({ where: { deletedAt: null } });
    if (!admin) throw new UnauthorizedException("No admin account configured");

    return this.issueAdminTokens(admin.id, admin.email);
  }

  async refresh(refreshToken: string) {
    let payload: { id: string; role: UserRole };
    try {
      payload = await this.jwtService.verifyAsync<{ id: string; role: UserRole }>(refreshToken, {
        secret: process.env.JWT_REFRESH_SECRET
      });
    } catch {
      throw new UnauthorizedException("Invalid refresh token");
    }
    if (payload.role !== UserRole.ADMIN) throw new UnauthorizedException("Invalid refresh token");
    const admin = await this.prisma.adminUser.findUnique({ where: { id: payload.id } });
    if (!admin || admin.deletedAt) throw new UnauthorizedException();
    return this.issueAdminTokens(admin.id, admin.email);
  }

  private async issueAdminTokens(id: string, email: string) {
    const payload = { id, email, role: UserRole.ADMIN };
    return {
      admin: await this.prisma.adminUser.findUnique({
        where: { id },
        select: { id: true, email: true, name: true }
      }),
      accessToken: await this.jwtService.signAsync(payload, {
        secret: process.env.JWT_ACCESS_SECRET,
        expiresIn: "30m"
      }),
      refreshToken: await this.jwtService.signAsync(payload, {
        secret: process.env.JWT_REFRESH_SECRET,
        expiresIn: "30d"
      })
    };
  }
}
