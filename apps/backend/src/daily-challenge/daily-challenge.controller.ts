import { Body, Controller, Get, Post, UseGuards, UsePipes } from "@nestjs/common";
import { CurrentUser } from "../common/decorators/current-user.decorator";
import type { AuthenticatedUser } from "../common/decorators/current-user.decorator";
import { JwtAuthGuard } from "../common/guards/jwt-auth.guard";
import { ZodValidationPipe } from "../common/pipes/zod-validation.pipe";
import { dailyChallengeSubmitSchema } from "./daily-challenge.schemas";
import type { DailyChallengeSubmitBody } from "./daily-challenge.schemas";
import { DailyChallengeService } from "./daily-challenge.service";

@Controller("daily-challenge")
@UseGuards(JwtAuthGuard)
export class DailyChallengeController {
  constructor(private readonly dailyChallenge: DailyChallengeService) {}

  @Get()
  current(@CurrentUser() user: AuthenticatedUser) {
    return this.dailyChallenge.current(user.id);
  }

  @Post("submit")
  submit(
    @CurrentUser() user: AuthenticatedUser,
    @Body(new ZodValidationPipe(dailyChallengeSubmitSchema)) body: DailyChallengeSubmitBody
  ) {
    return this.dailyChallenge.submit(user.id, body);
  }

  @Get("history")
  history(@CurrentUser() user: AuthenticatedUser) {
    return this.dailyChallenge.history(user.id);
  }
}
