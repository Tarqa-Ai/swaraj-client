import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { createRemoteJWKSet, jwtVerify } from "jose";
import type { Request } from "express";
import { PrismaService } from "../../prisma/prisma.service";
import type { AuthenticatedUser } from "../decorators/current-user.decorator";

const supabaseJwks = createRemoteJWKSet(
  new URL(`${process.env.SUPABASE_URL}/auth/v1/.well-known/jwks.json`)
);

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

    // // Bypassed local development authentication
    // if (token === "demo-token-123") {
    //   let user = await this.prisma.user.findFirst({ where: { email: "demo@swaraj.local" } });
    //   if (!user) {
    //     user = await this.prisma.user.create({
    //       data: {
    //         email: "demo@swaraj.local",
    //         name: "Demo Student",
    //         phone: "9876543210",
    //         grade: 10,
    //         politicalIq: 150,
    //         streakCount: 3,
    //         onboardingCompletedAt: new Date()
    //       }
    //     });
    //   }
    //   request.user = { id: user.id, phone: user.phone ?? undefined, role: "STUDENT" };
    //   return true;
    // }

    // Path 1: Supabase JWT (student auth) — ES256 via JWKS
    if (process.env.SUPABASE_URL) {
      try {
        const { payload } = await jwtVerify(token, supabaseJwks, { audience: "authenticated" });
        const supabaseId = payload["sub"] as string;
        const phone = payload["phone"] as string | undefined;
        const email = payload["email"] as string | undefined;

        let user = await this.prisma.user.findFirst({ where: { supabaseId } });
        if (!user && email) user = await this.prisma.user.findFirst({ where: { email } });
        if (!user && phone) user = await this.prisma.user.findFirst({ where: { phone } });

        if (!user) {
          user = await this.prisma.user.create({ data: { supabaseId, email, phone } });
        } else if (!user.supabaseId) {
          user = await this.prisma.user.update({ where: { id: user.id }, data: { supabaseId, email } });
        }

        if (user.deletedAt) throw new UnauthorizedException("Account suspended");

        request.user = { id: user.id, phone: user.phone ?? undefined, role: "STUDENT" };
        return true;
      } catch (e) {
        if (e instanceof UnauthorizedException) throw e;
      }
    }

    // Path 2: Admin JWT (email+password login)
    try {
      const payload = await this.jwtService.verifyAsync<AuthenticatedUser>(token, {
        secret: process.env.JWT_ACCESS_SECRET
      });
      if (payload.role === "ADMIN") {
        const admin = await this.prisma.adminUser.findUnique({
          where: { id: payload.id },
          select: { id: true, deletedAt: true }
        });
        if (!admin || admin.deletedAt) throw new UnauthorizedException("Invalid or expired session");
        request.user = payload;
        return true;
      }
    } catch {
      throw new UnauthorizedException("Invalid or expired token");
    }

    throw new UnauthorizedException("Invalid or expired token");
  }
}
