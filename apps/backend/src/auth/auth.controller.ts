import { Body, Controller, Post, UsePipes } from "@nestjs/common";
import { ApiTags } from "@nestjs/swagger";
import { ZodValidationPipe } from "../common/pipes/zod-validation.pipe";
import { adminLoginSchema } from "./auth.schemas";
import type { AdminLoginBody } from "./auth.schemas";
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
}
