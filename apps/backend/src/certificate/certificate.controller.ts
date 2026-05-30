import { Controller, Get, Param, UseGuards } from "@nestjs/common";
import { CurrentUser } from "../common/decorators/current-user.decorator";
import type { AuthenticatedUser } from "../common/decorators/current-user.decorator";
import { JwtAuthGuard } from "../common/guards/jwt-auth.guard";
import { CertificateService } from "./certificate.service";

@Controller("certificate")
export class CertificateController {
  constructor(private readonly certificate: CertificateService) {}

  @Get("status")
  @UseGuards(JwtAuthGuard)
  status(@CurrentUser() user: AuthenticatedUser) {
    return this.certificate.status(user.id);
  }

  @Get("download")
  @UseGuards(JwtAuthGuard)
  download(@CurrentUser() user: AuthenticatedUser) {
    return this.certificate.download(user.id);
  }

  @Get("verify/:code")
  verify(@Param("code") code: string) {
    return this.certificate.verify(code);
  }
}
