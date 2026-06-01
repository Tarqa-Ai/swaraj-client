import { Injectable } from "@nestjs/common";
import { ChallengeCategory, Language, LessonType, Prisma, QuizQuestionType } from "@prisma/client";
import { pagination } from "../common/pagination";
import { PrismaService } from "../prisma/prisma.service";
import type { AchievementBody, ChallengeBody, DebateBody, LessonBody, ModuleBody, QuizBody, QuizQuestionBody, SchoolBody, StudentUpdateBody } from "./admin.schemas";

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  async analytics() {
    const [totalUsers, activeUsers, totalModules, totalLessons, totalQuizzes, totalQuestions, dailyChallenges, activeDebates, completions, avgIq, debates, schools] = await Promise.all([
      this.prisma.user.count({ where: { deletedAt: null } }),
      this.prisma.user.count({ where: { deletedAt: null, updatedAt: { gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) } } }),
      this.prisma.module.count({ where: { deletedAt: null } }),
      this.prisma.lesson.count({ where: { deletedAt: null } }),
      this.prisma.quiz.count({ where: { deletedAt: null } }),
      this.prisma.quizQuestion.count({ where: { deletedAt: null } }),
      this.prisma.dailyChallenge.count({ where: { deletedAt: null } }),
      this.prisma.debate.count({ where: { deletedAt: null, isActive: true } }),
      this.prisma.moduleProgress.count(),
      this.prisma.user.aggregate({ _avg: { politicalIq: true }, where: { deletedAt: null } }),
      this.prisma.debateResponse.count(),
      this.prisma.school.findMany({ include: { _count: { select: { users: true } } }, take: 5 })
    ]);
    return {
      totalUsers,
      activeUsers,
      totalModules,
      totalLessons,
      totalQuizzes,
      totalQuestions,
      dailyChallenges,
      activeDebates,
      completionPercent: totalUsers && totalModules ? Math.round((completions / (totalUsers * totalModules)) * 100) : 0,
      averagePoliticalIq: Math.round(avgIq._avg.politicalIq ?? 0),
      debateParticipation: debates,
      topSchools: schools.map((school) => ({ id: school.id, name: school.name, students: school._count.users }))
    };
  }

  listStudents(query: Record<string, unknown>) {
    const { page, limit, skip } = pagination(query);
    return this.paginated(
      this.prisma.user.findMany({ where: { role: "STUDENT", deletedAt: null }, include: { school: true }, orderBy: { updatedAt: "desc" }, skip, take: limit }),
      this.prisma.user.count({ where: { role: "STUDENT", deletedAt: null } }),
      page,
      limit
    );
  }

  updateStudent(id: string, body: StudentUpdateBody) {
    return this.prisma.user.update({
      where: { id },
      data: {
        ...body,
        language: body.language as Language | undefined
      },
      include: { school: true }
    });
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

  updateSchool(id: string, body: Partial<SchoolBody>) {
    return this.prisma.school.update({ where: { id }, data: body });
  }

  deleteSchool(id: string) {
    return this.prisma.school.update({ where: { id }, data: { deletedAt: new Date() } });
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

  updateModule(id: string, body: Partial<ModuleBody>) {
    return this.prisma.module.update({ where: { id }, data: body });
  }

  deleteModule(id: string) {
    return this.prisma.module.update({ where: { id }, data: { deletedAt: new Date() } });
  }

  listLessons() {
    return this.prisma.lesson.findMany({
      where: { deletedAt: null },
      include: { module: true },
      orderBy: [{ module: { order: "asc" } }, { order: "asc" }]
    });
  }

  createLesson(body: LessonBody) {
    return this.prisma.lesson.create({ data: { ...body, type: body.type as LessonType } });
  }

  updateLesson(id: string, body: Partial<LessonBody>) {
    return this.prisma.lesson.update({ where: { id }, data: { ...body, type: body.type as LessonType | undefined } });
  }

  deleteLesson(id: string) {
    return this.prisma.lesson.update({ where: { id }, data: { deletedAt: new Date() } });
  }

  listChallenges() {
    return this.prisma.dailyChallenge.findMany({ where: { deletedAt: null }, orderBy: { challengeDate: "desc" } });
  }

  createChallenge(body: ChallengeBody) {
    return this.prisma.dailyChallenge.create({ data: { ...body, category: body.category as ChallengeCategory } });
  }

  updateChallenge(id: string, body: Partial<ChallengeBody>) {
    return this.prisma.dailyChallenge.update({
      where: { id },
      data: { ...body, category: body.category as ChallengeCategory | undefined }
    });
  }

  deleteChallenge(id: string) {
    return this.prisma.dailyChallenge.update({ where: { id }, data: { deletedAt: new Date() } });
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

  async updateDebate(id: string, body: Partial<DebateBody>) {
    if (body.isActive) {
      await this.prisma.debate.updateMany({ where: { isActive: true, id: { not: id } }, data: { isActive: false } });
    }
    return this.prisma.debate.update({ where: { id }, data: body });
  }

  deleteDebate(id: string) {
    return this.prisma.debate.update({ where: { id }, data: { deletedAt: new Date(), isActive: false } });
  }

  listQuizzes() {
    return this.prisma.quiz.findMany({
      where: { deletedAt: null },
      include: { module: true, questions: { where: { deletedAt: null }, orderBy: { order: "asc" } } },
      orderBy: { createdAt: "desc" }
    });
  }

  createQuiz(body: QuizBody) {
    return this.prisma.quiz.create({ data: body });
  }

  updateQuiz(id: string, body: Partial<QuizBody>) {
    return this.prisma.quiz.update({ where: { id }, data: body });
  }

  deleteQuiz(id: string) {
    return this.prisma.quiz.update({ where: { id }, data: { deletedAt: new Date() } });
  }

  listQuizQuestions() {
    return this.prisma.quizQuestion.findMany({
      where: { deletedAt: null },
      include: { quiz: true },
      orderBy: [{ quizId: "asc" }, { order: "asc" }]
    });
  }

  createQuizQuestion(body: QuizQuestionBody) {
    return this.prisma.quizQuestion.create({
      data: { ...body, type: body.type as QuizQuestionType, options: body.options as Prisma.InputJsonValue, answer: body.answer as Prisma.InputJsonValue }
    });
  }

  updateQuizQuestion(id: string, body: Partial<QuizQuestionBody>) {
    return this.prisma.quizQuestion.update({
      where: { id },
      data: {
        ...body,
        type: body.type as QuizQuestionType | undefined,
        options: body.options as Prisma.InputJsonValue | undefined,
        answer: body.answer as Prisma.InputJsonValue | undefined
      }
    });
  }

  deleteQuizQuestion(id: string) {
    return this.prisma.quizQuestion.update({ where: { id }, data: { deletedAt: new Date() } });
  }

  leaderboard() {
    return this.prisma.user.findMany({
      where: { role: "STUDENT", deletedAt: null },
      select: { id: true, name: true, grade: true, politicalIq: true, streakCount: true, school: true },
      orderBy: [{ politicalIq: "desc" }, { createdAt: "asc" }],
      take: 100
    });
  }

  certificates() {
    return this.prisma.certificate.findMany({
      include: { user: { select: { id: true, name: true, phone: true, school: true } } },
      orderBy: { issuedAt: "desc" },
      take: 100
    });
  }

  deleteStudent(id: string) {
    return this.prisma.user.update({ where: { id }, data: { deletedAt: new Date(), refreshTokenHash: null } });
  }

  listAchievements() {
    return this.prisma.achievement.findMany({ where: { deletedAt: null }, orderBy: { code: "asc" } });
  }

  createAchievement(body: AchievementBody) {
    return this.prisma.achievement.create({ data: body });
  }

  updateAchievement(id: string, body: Partial<AchievementBody>) {
    return this.prisma.achievement.update({ where: { id }, data: body });
  }

  deleteAchievement(id: string) {
    return this.prisma.achievement.update({ where: { id }, data: { deletedAt: new Date() } });
  }

  async exports() {
    const [students, schools, modules, certificates] = await Promise.all([
      this.prisma.user.count({ where: { role: "STUDENT", deletedAt: null } }),
      this.prisma.school.count({ where: { deletedAt: null } }),
      this.prisma.module.count({ where: { deletedAt: null } }),
      this.prisma.certificate.count()
    ]);
    return [{ generatedAt: new Date().toISOString(), students, schools, modules, certificates }];
  }

  private async paginated<T>(itemsPromise: Promise<T[]>, totalPromise: Promise<number>, page: number, limit: number) {
    const [items, total] = await Promise.all([itemsPromise, totalPromise]);
    return { items, page, limit, total };
  }
}
