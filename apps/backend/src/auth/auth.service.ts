import { Injectable, UnauthorizedException } from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { UserRole } from "@prisma/client";
import bcrypt from "bcryptjs";
import { PrismaService } from "../prisma/prisma.service";
import type { AdminLoginBody } from "./auth.schemas";

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService
  ) {}

  async adminLogin(body: AdminLoginBody) {
    const admin = await this.prisma.adminUser.findUnique({ where: { email: body.email } });
    if (!admin || admin.deletedAt) throw new UnauthorizedException("Invalid admin credentials");
    const valid = await bcrypt.compare(body.password, admin.passwordHash);
    if (!valid) throw new UnauthorizedException("Invalid admin credentials");
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
