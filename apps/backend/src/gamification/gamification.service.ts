import { Injectable } from "@nestjs/common";
import { PoliticalIQReason, Prisma } from "@prisma/client";
import { BADGES } from "@swaraj/shared-utils";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class GamificationService {
  constructor(private readonly prisma: PrismaService) {}

  async award(userId: string, points: number, reason: PoliticalIQReason, metadata?: Prisma.InputJsonObject) {
    if (points <= 0) return;
    await this.prisma.$transaction([
      this.prisma.politicalIQLog.create({ data: { userId, points, reason, metadata } }),
      this.prisma.user.update({ where: { id: userId }, data: { politicalIq: { increment: points } } })
    ]);
    await this.evaluateAchievements(userId);
  }

  async evaluateAchievements(userId: string) {
    const [modules, debateCount, challenges, user] = await Promise.all([
      this.prisma.moduleProgress.count({ where: { userId } }),
      this.prisma.debateResponse.count({ where: { userId } }),
      this.prisma.dailyChallengeSubmission.count({ where: { userId } }),
      this.prisma.user.findUnique({ where: { id: userId } })
    ]);
    if (!user) return;

    const codes: string[] = [];
    if (modules >= 1) codes.push("CONSTITUTION_MASTER");
    if (debateCount >= 1) codes.push("DEBATE_CHAMPION");
    if (challenges >= 1) codes.push("CIVIC_HERO");
    if (modules >= 3 && debateCount >= 1 && challenges >= 1) codes.push("DEMOCRACY_DEFENDER");

    for (const code of codes) {
      const achievement = await this.prisma.achievement.findUnique({ where: { code } });
      if (achievement) {
        await this.prisma.userAchievement.upsert({
          where: { userId_achievementId: { userId, achievementId: achievement.id } },
          update: {},
          create: { userId, achievementId: achievement.id }
        });
      }
    }
  }

  async badgeTitles(userId: string) {
    const achievements = await this.prisma.userAchievement.findMany({
      where: { userId },
      include: { achievement: true },
      orderBy: { awardedAt: "desc" }
    });
    return achievements.map((entry) => entry.achievement.titleEn || BADGES.civicHero);
  }
}
