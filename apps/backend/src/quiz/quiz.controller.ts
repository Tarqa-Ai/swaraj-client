import { Body, Controller, Post, UseGuards, UsePipes } from "@nestjs/common";
import { CurrentUser } from "../common/decorators/current-user.decorator";
import type { AuthenticatedUser } from "../common/decorators/current-user.decorator";
import { JwtAuthGuard } from "../common/guards/jwt-auth.guard";
import { ZodValidationPipe } from "../common/pipes/zod-validation.pipe";
import { quizSubmitSchema } from "./quiz.schemas";
import type { QuizSubmitBody } from "./quiz.schemas";
import { QuizService } from "./quiz.service";

@Controller("quiz")
@UseGuards(JwtAuthGuard)
export class QuizController {
  constructor(private readonly quiz: QuizService) {}

  @Post("submit")
  submit(
    @CurrentUser() user: AuthenticatedUser,
    @Body(new ZodValidationPipe(quizSubmitSchema)) body: QuizSubmitBody
  ) {
    return this.quiz.submit(user.id, body);
  }
}
