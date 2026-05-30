import { Body, Controller, Delete, Get, Param, Patch, Post, Query, UseGuards, UsePipes } from "@nestjs/common";
import { AdminGuard } from "../common/guards/admin.guard";
import { JwtAuthGuard } from "../common/guards/jwt-auth.guard";
import { ZodValidationPipe } from "../common/pipes/zod-validation.pipe";
import {
  achievementSchema,
  challengeSchema,
  debateSchema,
  lessonSchema,
  moduleSchema,
  partialAchievementSchema,
  partialChallengeSchema,
  partialDebateSchema,
  partialLessonSchema,
  partialModuleSchema,
  partialQuizQuestionSchema,
  partialQuizSchema,
  partialSchoolSchema,
  quizQuestionSchema,
  quizSchema,
  schoolSchema
} from "./admin.schemas";
import type { AchievementBody, ChallengeBody, DebateBody, LessonBody, ModuleBody, QuizBody, QuizQuestionBody, SchoolBody } from "./admin.schemas";
import { AdminService } from "./admin.service";

@Controller("admin")
@UseGuards(JwtAuthGuard, AdminGuard)
export class AdminController {
  constructor(private readonly admin: AdminService) {}

  @Get("analytics")
  analytics() {
    return this.admin.analytics();
  }

  @Get("students")
  students(@Query() query: Record<string, unknown>) {
    return this.admin.listStudents(query);
  }

  @Delete("students/:id")
  deleteStudent(@Param("id") id: string) {
    return this.admin.deleteStudent(id);
  }

  @Get("schools")
  schools(@Query() query: Record<string, unknown>) {
    return this.admin.listSchools(query);
  }

  @Post("schools")
  @UsePipes(new ZodValidationPipe(schoolSchema))
  createSchool(@Body() body: SchoolBody) {
    return this.admin.createSchool(body);
  }

  @Patch("schools/:id")
  @UsePipes(new ZodValidationPipe(partialSchoolSchema))
  updateSchool(@Param("id") id: string, @Body() body: Partial<SchoolBody>) {
    return this.admin.updateSchool(id, body);
  }

  @Delete("schools/:id")
  deleteSchool(@Param("id") id: string) {
    return this.admin.deleteSchool(id);
  }

  @Get("modules")
  modules() {
    return this.admin.listModules();
  }

  @Post("modules")
  @UsePipes(new ZodValidationPipe(moduleSchema))
  createModule(@Body() body: ModuleBody) {
    return this.admin.createModule(body);
  }

  @Patch("modules/:id")
  @UsePipes(new ZodValidationPipe(partialModuleSchema))
  updateModule(@Param("id") id: string, @Body() body: Partial<ModuleBody>) {
    return this.admin.updateModule(id, body);
  }

  @Delete("modules/:id")
  deleteModule(@Param("id") id: string) {
    return this.admin.deleteModule(id);
  }

  @Get("lessons")
  lessons() {
    return this.admin.listLessons();
  }

  @Post("lessons")
  @UsePipes(new ZodValidationPipe(lessonSchema))
  createLesson(@Body() body: LessonBody) {
    return this.admin.createLesson(body);
  }

  @Patch("lessons/:id")
  @UsePipes(new ZodValidationPipe(partialLessonSchema))
  updateLesson(@Param("id") id: string, @Body() body: Partial<LessonBody>) {
    return this.admin.updateLesson(id, body);
  }

  @Delete("lessons/:id")
  deleteLesson(@Param("id") id: string) {
    return this.admin.deleteLesson(id);
  }

  @Get("daily-challenges")
  challenges() {
    return this.admin.listChallenges();
  }

  @Post("daily-challenges")
  @UsePipes(new ZodValidationPipe(challengeSchema))
  createChallenge(@Body() body: ChallengeBody) {
    return this.admin.createChallenge(body);
  }

  @Patch("daily-challenges/:id")
  @UsePipes(new ZodValidationPipe(partialChallengeSchema))
  updateChallenge(@Param("id") id: string, @Body() body: Partial<ChallengeBody>) {
    return this.admin.updateChallenge(id, body);
  }

  @Delete("daily-challenges/:id")
  deleteChallenge(@Param("id") id: string) {
    return this.admin.deleteChallenge(id);
  }

  @Get("debates")
  debates() {
    return this.admin.listDebates();
  }

  @Post("debates")
  @UsePipes(new ZodValidationPipe(debateSchema))
  createDebate(@Body() body: DebateBody) {
    return this.admin.createDebate(body);
  }

  @Patch("debates/:id")
  @UsePipes(new ZodValidationPipe(partialDebateSchema))
  updateDebate(@Param("id") id: string, @Body() body: Partial<DebateBody>) {
    return this.admin.updateDebate(id, body);
  }

  @Delete("debates/:id")
  deleteDebate(@Param("id") id: string) {
    return this.admin.deleteDebate(id);
  }

  @Get("quizzes")
  quizzes() {
    return this.admin.listQuizzes();
  }

  @Post("quizzes")
  @UsePipes(new ZodValidationPipe(quizSchema))
  createQuiz(@Body() body: QuizBody) {
    return this.admin.createQuiz(body);
  }

  @Patch("quizzes/:id")
  @UsePipes(new ZodValidationPipe(partialQuizSchema))
  updateQuiz(@Param("id") id: string, @Body() body: Partial<QuizBody>) {
    return this.admin.updateQuiz(id, body);
  }

  @Delete("quizzes/:id")
  deleteQuiz(@Param("id") id: string) {
    return this.admin.deleteQuiz(id);
  }

  @Get("quiz-questions")
  quizQuestions() {
    return this.admin.listQuizQuestions();
  }

  @Post("quiz-questions")
  @UsePipes(new ZodValidationPipe(quizQuestionSchema))
  createQuizQuestion(@Body() body: QuizQuestionBody) {
    return this.admin.createQuizQuestion(body);
  }

  @Patch("quiz-questions/:id")
  @UsePipes(new ZodValidationPipe(partialQuizQuestionSchema))
  updateQuizQuestion(@Param("id") id: string, @Body() body: Partial<QuizQuestionBody>) {
    return this.admin.updateQuizQuestion(id, body);
  }

  @Delete("quiz-questions/:id")
  deleteQuizQuestion(@Param("id") id: string) {
    return this.admin.deleteQuizQuestion(id);
  }

  @Get("achievements")
  achievements() {
    return this.admin.listAchievements();
  }

  @Post("achievements")
  @UsePipes(new ZodValidationPipe(achievementSchema))
  createAchievement(@Body() body: AchievementBody) {
    return this.admin.createAchievement(body);
  }

  @Patch("achievements/:id")
  @UsePipes(new ZodValidationPipe(partialAchievementSchema))
  updateAchievement(@Param("id") id: string, @Body() body: Partial<AchievementBody>) {
    return this.admin.updateAchievement(id, body);
  }

  @Delete("achievements/:id")
  deleteAchievement(@Param("id") id: string) {
    return this.admin.deleteAchievement(id);
  }

  @Get("leaderboard")
  leaderboard() {
    return this.admin.leaderboard();
  }

  @Get("certificates")
  certificates() {
    return this.admin.certificates();
  }

  @Get("exports")
  exports() {
    return this.admin.exports();
  }
}
