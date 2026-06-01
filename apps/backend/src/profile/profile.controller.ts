import { Body, Controller, Get, Patch, UseGuards, UsePipes } from "@nestjs/common";
import { CurrentUser } from "../common/decorators/current-user.decorator";
import type { AuthenticatedUser } from "../common/decorators/current-user.decorator";
import { JwtAuthGuard } from "../common/guards/jwt-auth.guard";
import { ZodValidationPipe } from "../common/pipes/zod-validation.pipe";
import { updateProfileSchema } from "./profile.schemas";
import type { UpdateProfileBody } from "./profile.schemas";
import { ProfileService } from "./profile.service";

@Controller()
export class ProfileController {
  constructor(private readonly profile: ProfileService) {}

  @Get("me")
  @UseGuards(JwtAuthGuard)
  me(@CurrentUser() user: AuthenticatedUser) {
    return this.profile.me(user.id);
  }

  @Patch("me/profile")
  @UseGuards(JwtAuthGuard)
  update(@CurrentUser() user: AuthenticatedUser, @Body(new ZodValidationPipe(updateProfileSchema)) body: UpdateProfileBody) {
    return this.profile.updateProfile(user.id, body);
  }

  @Get("schools")
  schools() {
    return this.profile.schools();
  }
}
