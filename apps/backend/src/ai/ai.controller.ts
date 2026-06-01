import { Body, Controller, Post, UseGuards, UsePipes } from "@nestjs/common";
import { Throttle } from "@nestjs/throttler";
import { CurrentUser } from "../common/decorators/current-user.decorator";
import type { AuthenticatedUser } from "../common/decorators/current-user.decorator";
import { JwtAuthGuard } from "../common/guards/jwt-auth.guard";
import { ZodValidationPipe } from "../common/pipes/zod-validation.pipe";
import { explainSchema } from "./ai.schemas";
import type { ExplainBody } from "./ai.schemas";
import { AiService } from "./ai.service";

@Controller("ai")
@UseGuards(JwtAuthGuard)
export class AiController {
  constructor(private readonly ai: AiService) {}

  @Post("explain")
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  explain(
    @CurrentUser() _user: AuthenticatedUser,
    @Body(new ZodValidationPipe(explainSchema)) body: ExplainBody
  ) {
    return this.ai.explain(body);
  }
}
