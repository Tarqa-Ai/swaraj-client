import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import type { Request } from "express";
import { PrismaService } from "../../prisma/prisma.service";
import type { AuthenticatedUser } from "../decorators/current-user.decorator";

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly jwtService: JwtService,
    private readonly prisma: PrismaService
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<Request & { user?: AuthenticatedUser }>();
    const header = request.headers.authorization;
    const token = header?.startsWith("Bearer ") ? header.slice(7) : undefined;
    if (!token) throw new UnauthorizedException("Missing bearer token");

    try {
      const payload = await this.jwtService.verifyAsync<AuthenticatedUser>(token, {
        secret: process.env.JWT_ACCESS_SECRET
      });
      if (payload.role === "STUDENT") {
        const user = await this.prisma.user.findUnique({
          where: { id: payload.id },
          select: { id: true, deletedAt: true, refreshTokenHash: true }
        });
        if (!user || user.deletedAt || !user.refreshTokenHash) throw new UnauthorizedException("Invalid or expired session");
      } else if (payload.role === "ADMIN") {
        const admin = await this.prisma.adminUser.findUnique({
          where: { id: payload.id },
          select: { id: true, deletedAt: true }
        });
        if (!admin || admin.deletedAt) throw new UnauthorizedException("Invalid or expired session");
      }
      request.user = payload;
      return true;
    } catch {
      throw new UnauthorizedException("Invalid or expired token");
    }
  }
}
