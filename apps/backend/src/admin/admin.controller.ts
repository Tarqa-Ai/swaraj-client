import { Body, Controller, Get, Post, Query, UseGuards, UsePipes } from "@nestjs/common";
import { AdminGuard } from "../common/guards/admin.guard";
import { JwtAuthGuard } from "../common/guards/jwt-auth.guard";
import { ZodValidationPipe } from "../common/pipes/zod-validation.pipe";
import {
  challengeSchema,
  debateSchema,
  lessonSchema,
  moduleSchema,
  schoolSchema
} from "./admin.schemas";
import type { ChallengeBody, DebateBody, LessonBody, ModuleBody, SchoolBody } from "./admin.schemas";
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

  @Get("schools")
  schools(@Query() query: Record<string, unknown>) {
    return this.admin.listSchools(query);
  }

  @Post("schools")
  @UsePipes(new ZodValidationPipe(schoolSchema))
  createSchool(@Body() body: SchoolBody) {
    return this.admin.createSchool(body);
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

  @Post("lessons")
  @UsePipes(new ZodValidationPipe(lessonSchema))
  createLesson(@Body() body: LessonBody) {
    return this.admin.createLesson(body);
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

  @Get("debates")
  debates() {
    return this.admin.listDebates();
  }

  @Post("debates")
  @UsePipes(new ZodValidationPipe(debateSchema))
  createDebate(@Body() body: DebateBody) {
    return this.admin.createDebate(body);
  }
}
