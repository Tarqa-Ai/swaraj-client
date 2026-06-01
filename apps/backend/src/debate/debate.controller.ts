import { Body, Controller, Get, Post, UseGuards } from "@nestjs/common";
import { CurrentUser } from "../common/decorators/current-user.decorator";
import type { AuthenticatedUser } from "../common/decorators/current-user.decorator";
import { JwtAuthGuard } from "../common/guards/jwt-auth.guard";
import { ZodValidationPipe } from "../common/pipes/zod-validation.pipe";
import { debateResponseSchema } from "./debate.schemas";
import type { DebateResponseBody } from "./debate.schemas";
import { DebateService } from "./debate.service";

@Controller("debate")
@UseGuards(JwtAuthGuard)
export class DebateController {
  constructor(private readonly debate: DebateService) {}

  @Get("current")
  current(@CurrentUser() user: AuthenticatedUser) {
    return this.debate.current(user.id);
  }

  @Post("respond")
  respond(@CurrentUser() user: AuthenticatedUser, @Body(new ZodValidationPipe(debateResponseSchema)) body: DebateResponseBody) {
    return this.debate.respond(user.id, body);
  }
}
