import { Module } from "@nestjs/common";
import { ThrottlerGuard } from "@nestjs/throttler";
import { APP_GUARD } from "@nestjs/core";
import { AuthController } from "./auth.controller";
import { AuthService } from "./auth.service";
import { EmailService } from "../common/email/email.service";

@Module({
  controllers: [AuthController],
  providers: [
    AuthService,
    EmailService,
    { provide: APP_GUARD, useClass: ThrottlerGuard }
  ],
  exports: [AuthService]
})
export class AuthModule {}
