import { Body, Controller, Post, UsePipes } from "@nestjs/common";
import { ApiTags } from "@nestjs/swagger";
import { ZodValidationPipe } from "../common/pipes/zod-validation.pipe";
import { adminLoginSchema, refreshSchema, sendOtpSchema, verifyOtpSchema } from "./auth.schemas";
import type { AdminLoginBody, RefreshBody, SendOtpBody, VerifyOtpBody } from "./auth.schemas";
import { AuthService } from "./auth.service";

@ApiTags("auth")
@Controller("auth")
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post("send-otp")
  @UsePipes(new ZodValidationPipe(sendOtpSchema))
  sendOtp(@Body() body: SendOtpBody) {
    return this.auth.sendOtp(body);
  }

  @Post("verify-otp")
  @UsePipes(new ZodValidationPipe(verifyOtpSchema))
  verifyOtp(@Body() body: VerifyOtpBody) {
    return this.auth.verifyOtp(body);
  }

  @Post("refresh")
  @UsePipes(new ZodValidationPipe(refreshSchema))
  refresh(@Body() body: RefreshBody) {
    return this.auth.refresh(body.refreshToken);
  }

  @Post("admin/login")
  @UsePipes(new ZodValidationPipe(adminLoginSchema))
  adminLogin(@Body() body: AdminLoginBody) {
    return this.auth.adminLogin(body);
  }
}
