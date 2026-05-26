import { Injectable, NotFoundException } from "@nestjs/common";
import { Language } from "@prisma/client";
import { getPoliticalLevel } from "@swaraj/shared-utils";
import { PrismaService } from "../prisma/prisma.service";
import type { UpdateProfileBody } from "./profile.schemas";

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
}
