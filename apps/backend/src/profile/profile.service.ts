import { Injectable, NotFoundException } from "@nestjs/common";
import { Language } from "@prisma/client";
import { getPoliticalLevel } from "@swaraj/shared-utils";
import { PrismaService } from "../prisma/prisma.service";
import type { UpdateProfileBody, CreateSchoolBody } from "./profile.schemas";

@Injectable()
export class ProfileService {
  constructor(private readonly prisma: PrismaService) {}

  async me(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        school: true,
        achievements: { include: { achievement: true } },
        moduleProgress: true,
        certificates: true
      }
    });
    if (!user) throw new NotFoundException();
    return {
      ...user,
      level: getPoliticalLevel(user.politicalIq),
      badges: user.achievements.map((item) => item.achievement.titleEn)
    };
  }

  async updateProfile(userId: string, body: UpdateProfileBody) {
    return this.prisma.user.update({
      where: { id: userId },
      data: {
        name: body.name,
        grade: body.grade,
        schoolId: body.schoolId,
        language: body.language as Language,
        onboardingCompletedAt: new Date()
      },
      include: { school: true }
    });
  }

  schools() {
    return this.prisma.school.findMany({
      where: { deletedAt: null },
      orderBy: [{ district: "asc" }, { name: "asc" }]
    });
  }

  async createSchool(body: CreateSchoolBody) {
    // Return existing school if same name + district already exists
    const existing = await this.prisma.school.findFirst({
      where: {
        name: { equals: body.name.trim(), mode: "insensitive" },
        district: { equals: body.district.trim(), mode: "insensitive" },
        deletedAt: null,
      },
    });
    if (existing) return existing;

    const slug = body.name.toLowerCase().replace(/[^a-z0-9]/g, "").slice(0, 6) || "inst";
    const suffix = Math.random().toString(36).slice(2, 8).toUpperCase();
    const code = `${slug}${suffix}`;

    return this.prisma.school.create({
      data: {
        name: body.name.trim(),
        district: body.district.trim(),
        state: body.state ?? "Rajasthan",
        code,
      },
    });
  }
}
