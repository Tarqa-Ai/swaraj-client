import { Module } from "@nestjs/common";
import { ThrottlerGuard } from "@nestjs/throttler";
import { APP_GUARD } from "@nestjs/core";
import { AuthController } from "./auth.controller";
import { AuthService } from "./auth.service";
import { Msg91OtpProvider, OtpProvider } from "./otp.provider";

@Module({
  controllers: [AuthController],
  providers: [
    AuthService,
    { provide: OtpProvider, useClass: Msg91OtpProvider },
    { provide: APP_GUARD, useClass: ThrottlerGuard }
  ],
  exports: [AuthService]
})
export class AuthModule {}
