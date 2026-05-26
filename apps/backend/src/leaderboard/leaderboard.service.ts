import { Injectable, NotFoundException } from "@nestjs/common";
import { pagination } from "../common/pagination";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class LeaderboardService {
  constructor(private readonly prisma: PrismaService) {}

  async schoolLeaderboard(userId: string, query: Record<string, unknown>) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user?.schoolId) throw new NotFoundException("School is not assigned");
    const { page, limit, skip } = pagination(query);
    const where = { schoolId: String(query.schoolId ?? user.schoolId), deletedAt: null };
    const [items, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        select: {
          id: true,
          name: true,
          grade: true,
          politicalIq: true,
          streakCount: true,
          achievements: { include: { achievement: true } }
        },
        orderBy: [{ politicalIq: "desc" }, { createdAt: "asc" }],
        skip,
        take: limit
      }),
      this.prisma.user.count({ where })
    ]);

    return {
      items: items.map((item, index) => ({
        ...item,
        rank: skip + index + 1,
        badges: item.achievements.map((achievement) => achievement.achievement.titleEn)
      })),
      page,
      limit,
      total
    };
  }
}
