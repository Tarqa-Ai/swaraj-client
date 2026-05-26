import { Injectable, NotFoundException } from "@nestjs/common";
import { PoliticalIQReason } from "@prisma/client";
import { getPoliticalLevel, POLITICAL_IQ_POINTS } from "@swaraj/shared-utils";
import { GamificationService } from "../gamification/gamification.service";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class LearningService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly gamification: GamificationService
  ) {}

  async dashboard(userId: string) {
    const [user, totalModules, completedModules, badges] = await Promise.all([
      this.prisma.user.findUnique({ where: { id: userId }, include: { school: true } }),
      this.prisma.module.count({ where: { deletedAt: null } }),
      this.prisma.moduleProgress.count({ where: { userId } }),
      this.gamification.badgeTitles(userId)
    ]);
    if (!user) throw new NotFoundException();

    const rankedUsers = await this.prisma.user.findMany({
      where: { schoolId: user.schoolId, deletedAt: null },
      select: { id: true },
      orderBy: [{ politicalIq: "desc" }, { createdAt: "asc" }]
    });
    const rankIndex = rankedUsers.findIndex((entry) => entry.id === userId);
    const nextModule = await this.prisma.module.findFirst({
      where: { deletedAt: null, progress: { none: { userId } } },
      orderBy: { order: "asc" }
    });

    return {
      politicalIq: user.politicalIq,
      level: getPoliticalLevel(user.politicalIq),
      streakCount: user.streakCount,
      leaderboardRank: rankIndex >= 0 ? rankIndex + 1 : null,
      completedModules,
      totalModules,
      badges,
      nextModuleId: nextModule?.id
    };
  }

  async modules(userId: string) {
    const modules = await this.prisma.module.findMany({
      where: { deletedAt: null },
      include: {
        lessons: { where: { deletedAt: null }, orderBy: { order: "asc" } },
        quizzes: { where: { deletedAt: null }, include: { questions: { where: { deletedAt: null } } } },
        progress: { where: { userId } }
      },
      orderBy: { order: "asc" }
    });
    return modules.map((module) => ({
      ...module,
      completed: module.progress.length > 0,
      lessonCount: module.lessons.length,
      quizCount: module.quizzes.length
    }));
  }

  async moduleDetail(userId: string, id: string) {
    const module = await this.prisma.module.findFirst({
      where: { id, deletedAt: null },
      include: {
        lessons: {
          where: { deletedAt: null },
          orderBy: { order: "asc" },
          include: { progress: { where: { userId } } }
        },
        quizzes: {
          where: { deletedAt: null },
          include: { questions: { where: { deletedAt: null }, orderBy: { order: "asc" } } }
        },
        progress: { where: { userId } }
      }
    });
    if (!module) throw new NotFoundException("Module not found");
    return {
      ...module,
      completed: module.progress.length > 0,
      lessons: module.lessons.map((lesson) => ({ ...lesson, completed: lesson.progress.length > 0 }))
    };
  }

  async completeLesson(userId: string, lessonId: string) {
    const lesson = await this.prisma.lesson.findFirst({ where: { id: lessonId, deletedAt: null } });
    if (!lesson) throw new NotFoundException("Lesson not found");

    const created = await this.prisma.lessonProgress.upsert({
      where: { userId_lessonId: { userId, lessonId } },
      update: {},
      create: { userId, lessonId }
    });

    const existingLogs = await this.prisma.politicalIQLog.count({
      where: { userId, reason: PoliticalIQReason.LESSON_COMPLETION, metadata: { path: ["lessonId"], equals: lessonId } }
    });
    if (existingLogs === 0) {
      await this.gamification.award(userId, POLITICAL_IQ_POINTS.lessonCompletion, PoliticalIQReason.LESSON_COMPLETION, { lessonId });
    }

    const [totalLessons, completedLessons, moduleProgress] = await Promise.all([
      this.prisma.lesson.count({ where: { moduleId: lesson.moduleId, deletedAt: null } }),
      this.prisma.lessonProgress.count({ where: { userId, lesson: { moduleId: lesson.moduleId, deletedAt: null } } }),
      this.prisma.moduleProgress.findUnique({ where: { userId_moduleId: { userId, moduleId: lesson.moduleId } } })
    ]);

    if (completedLessons >= totalLessons && !moduleProgress) {
      await this.prisma.moduleProgress.create({ data: { userId, moduleId: lesson.moduleId } });
      await this.gamification.award(userId, POLITICAL_IQ_POINTS.moduleCompletion, PoliticalIQReason.MODULE_COMPLETION, {
        moduleId: lesson.moduleId
      });
    }

    return created;
  }
}
