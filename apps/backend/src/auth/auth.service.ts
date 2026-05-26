import { BadRequestException, Injectable, UnauthorizedException } from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { Language, UserRole } from "@prisma/client";
import bcrypt from "bcryptjs";
import { randomInt } from "crypto";
import { PrismaService } from "../prisma/prisma.service";
import type { AdminLoginBody, SendOtpBody, VerifyOtpBody } from "./auth.schemas";
import { OtpProvider } from "./otp.provider";

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly otpProvider: OtpProvider
  ) {}

  async sendOtp(body: SendOtpBody) {
    const code = randomInt(100000, 999999).toString();
    const codeHash = await bcrypt.hash(code, 10);
    const user = await this.prisma.user.findUnique({ where: { phone: body.phone } });

    await this.prisma.otpChallenge.create({
      data: {
        phone: body.phone,
        userId: user?.id,
        codeHash,
        expiresAt: new Date(Date.now() + 5 * 60 * 1000)
      }
    });

    await this.otpProvider.send(body.phone, code);
    return { sent: true, expiresInSeconds: 300 };
  }

  async verifyOtp(body: VerifyOtpBody) {
    const challenge = await this.prisma.otpChallenge.findFirst({
      where: {
        phone: body.phone,
        consumedAt: null,
        expiresAt: { gt: new Date() }
      },
      orderBy: { createdAt: "desc" }
    });
    if (!challenge) throw new BadRequestException("OTP expired or not found");
    if (challenge.attempts >= 5) throw new BadRequestException("Too many OTP attempts");

    const valid = await bcrypt.compare(body.code, challenge.codeHash);
    await this.prisma.otpChallenge.update({
      where: { id: challenge.id },
      data: { attempts: { increment: 1 }, consumedAt: valid ? new Date() : null }
    });
    if (!valid) throw new UnauthorizedException("Invalid OTP");

    const user = await this.prisma.user.upsert({
      where: { phone: body.phone },
      create: {
        phone: body.phone,
        name: body.name,
        grade: body.grade,
        schoolId: body.schoolId,
        language: (body.language ?? "en") as Language,
        onboardingCompletedAt: body.name && body.grade && body.schoolId ? new Date() : null
      },
      update: {
        name: body.name,
        grade: body.grade,
        schoolId: body.schoolId,
        language: body.language as Language | undefined,
        onboardingCompletedAt: body.name && body.grade && body.schoolId ? new Date() : undefined
      }
    });

    return this.issueStudentTokens(user.id, user.phone);
  }

  async adminLogin(body: AdminLoginBody) {
    const admin = await this.prisma.adminUser.findUnique({ where: { email: body.email } });
    if (!admin || admin.deletedAt) throw new UnauthorizedException("Invalid admin credentials");
    const valid = await bcrypt.compare(body.password, admin.passwordHash);
    if (!valid) throw new UnauthorizedException("Invalid admin credentials");
    return this.issueAdminTokens(admin.id, admin.email);
  }

  async refresh(refreshToken: string) {
    const payload = await this.jwtService.verifyAsync<{ id: string; role: UserRole }>(refreshToken, {
      secret: process.env.JWT_REFRESH_SECRET
    });

    if (payload.role === UserRole.ADMIN) {
      const admin = await this.prisma.adminUser.findUnique({ where: { id: payload.id } });
      if (!admin || admin.deletedAt) throw new UnauthorizedException();
      return this.issueAdminTokens(admin.id, admin.email);
    }

    const user = await this.prisma.user.findUnique({ where: { id: payload.id } });
    if (!user || user.deletedAt) throw new UnauthorizedException();
    return this.issueStudentTokens(user.id, user.phone);
  }

  private async issueStudentTokens(id: string, phone: string) {
    const payload = { id, phone, role: UserRole.STUDENT };
    return {
      user: await this.prisma.user.findUnique({ where: { id }, include: { school: true } }),
      accessToken: await this.jwtService.signAsync(payload, {
        secret: process.env.JWT_ACCESS_SECRET,
        expiresIn: "15m"
      }),
      refreshToken: await this.jwtService.signAsync(payload, {
        secret: process.env.JWT_REFRESH_SECRET,
        expiresIn: "30d"
      })
    };
  }

  private async issueAdminTokens(id: string, email: string) {
    const payload = { id, email, role: UserRole.ADMIN };
    return {
      admin: await this.prisma.adminUser.findUnique({ where: { id }, select: { id: true, email: true, name: true } }),
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
