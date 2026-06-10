import { Body, Controller, Post, UsePipes } from "@nestjs/common";
import { ApiTags } from "@nestjs/swagger";
import { ZodValidationPipe } from "../common/pipes/zod-validation.pipe";
import { adminLoginSchema, adminGoogleLoginSchema, refreshSchema } from "./auth.schemas";
import type { AdminLoginBody, AdminGoogleLoginBody, RefreshBody } from "./auth.schemas";
import { AuthService } from "./auth.service";

@ApiTags("auth")
@Controller("auth")
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post("admin/login")
  @UsePipes(new ZodValidationPipe(adminLoginSchema))
  adminLogin(@Body() body: AdminLoginBody) {
    return this.auth.adminLogin(body);
  }

  @Post("admin/google")
  @UsePipes(new ZodValidationPipe(adminGoogleLoginSchema))
  adminGoogleLogin(@Body() body: AdminGoogleLoginBody) {
    return this.auth.adminGoogleLogin(body.idToken);
  }

  @Post("refresh")
  @UsePipes(new ZodValidationPipe(refreshSchema))
  refresh(@Body() body: RefreshBody) {
    return this.auth.refresh(body.refreshToken);
  }
}
