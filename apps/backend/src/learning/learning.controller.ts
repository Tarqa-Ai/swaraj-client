import { Controller, Get, Param, Post, UseGuards } from "@nestjs/common";
import { CurrentUser } from "../common/decorators/current-user.decorator";
import type { AuthenticatedUser } from "../common/decorators/current-user.decorator";
import { JwtAuthGuard } from "../common/guards/jwt-auth.guard";
import { LearningService } from "./learning.service";

@Controller()
@UseGuards(JwtAuthGuard)
export class LearningController {
  constructor(private readonly learning: LearningService) {}

  @Get("dashboard")
  dashboard(@CurrentUser() user: AuthenticatedUser) {
    return this.learning.dashboard(user.id);
  }

  @Get("modules")
  modules(@CurrentUser() user: AuthenticatedUser) {
    return this.learning.modules(user.id);
  }

  @Get("modules/:id")
  moduleDetail(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    return this.learning.moduleDetail(user.id, id);
  }

  @Post("lessons/:id/complete")
  completeLesson(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    return this.learning.completeLesson(user.id, id);
  }
}
