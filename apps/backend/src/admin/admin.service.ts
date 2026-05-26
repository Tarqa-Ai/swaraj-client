import { Injectable } from "@nestjs/common";
import { ChallengeCategory, LessonType } from "@prisma/client";
import { pagination } from "../common/pagination";
import { PrismaService } from "../prisma/prisma.service";
import type { ChallengeBody, DebateBody, LessonBody, ModuleBody, SchoolBody } from "./admin.schemas";

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  async analytics() {
    const [totalUsers, activeUsers, totalModules, completions, avgIq, debates, schools] = await Promise.all([
      this.prisma.user.count({ where: { deletedAt: null } }),
      this.prisma.user.count({ where: { deletedAt: null, updatedAt: { gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) } } }),
      this.prisma.module.count({ where: { deletedAt: null } }),
      this.prisma.moduleProgress.count(),
      this.prisma.user.aggregate({ _avg: { politicalIq: true }, where: { deletedAt: null } }),
      this.prisma.debateResponse.count(),
      this.prisma.school.findMany({ include: { _count: { select: { users: true } } }, take: 5 })
    ]);
    return {
      totalUsers,
      activeUsers,
      completionPercent: totalUsers && totalModules ? Math.round((completions / (totalUsers * totalModules)) * 100) : 0,
      averagePoliticalIq: Math.round(avgIq._avg.politicalIq ?? 0),
      debateParticipation: debates,
      topSchools: schools.map((school) => ({ id: school.id, name: school.name, students: school._count.users }))
    };
  }

  listStudents(query: Record<string, unknown>) {
    const { page, limit, skip } = pagination(query);
    return this.paginated(
      this.prisma.user.findMany({ where: { role: "STUDENT", deletedAt: null }, include: { school: true }, skip, take: limit }),
      this.prisma.user.count({ where: { role: "STUDENT", deletedAt: null } }),
      page,
      limit
    );
  }

  listSchools(query: Record<string, unknown>) {
    const { page, limit, skip } = pagination(query);
    return this.paginated(
      this.prisma.school.findMany({ where: { deletedAt: null }, skip, take: limit, orderBy: { name: "asc" } }),
      this.prisma.school.count({ where: { deletedAt: null } }),
      page,
      limit
    );
  }

  createSchool(body: SchoolBody) {
    return this.prisma.school.create({ data: body });
  }

  listModules() {
    return this.prisma.module.findMany({
      where: { deletedAt: null },
      include: { lessons: true, quizzes: true },
      orderBy: { order: "asc" }
    });
  }

  createModule(body: ModuleBody) {
    return this.prisma.module.create({ data: body });
  }

  createLesson(body: LessonBody) {
    return this.prisma.lesson.create({ data: { ...body, type: body.type as LessonType } });
  }

  listChallenges() {
    return this.prisma.dailyChallenge.findMany({ where: { deletedAt: null }, orderBy: { challengeDate: "desc" } });
  }

  createChallenge(body: ChallengeBody) {
    return this.prisma.dailyChallenge.create({ data: { ...body, category: body.category as ChallengeCategory } });
  }

  listDebates() {
    return this.prisma.debate.findMany({ where: { deletedAt: null }, orderBy: { createdAt: "desc" } });
  }

  async createDebate(body: DebateBody) {
    if (body.isActive) {
      await this.prisma.debate.updateMany({ where: { isActive: true }, data: { isActive: false } });
    }
    return this.prisma.debate.create({ data: body });
  }

  private async paginated<T>(itemsPromise: Promise<T[]>, totalPromise: Promise<number>, page: number, limit: number) {
    const [items, total] = await Promise.all([itemsPromise, totalPromise]);
    return { items, page, limit, total };
  }
}
