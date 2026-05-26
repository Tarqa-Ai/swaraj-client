import { Controller, Get, UseGuards } from "@nestjs/common";
import { CurrentUser } from "../common/decorators/current-user.decorator";
import type { AuthenticatedUser } from "../common/decorators/current-user.decorator";
import { JwtAuthGuard } from "../common/guards/jwt-auth.guard";
import { CertificateService } from "./certificate.service";

@Controller("certificate")
@UseGuards(JwtAuthGuard)
export class CertificateController {
  constructor(private readonly certificate: CertificateService) {}

  @Get("status")
  status(@CurrentUser() user: AuthenticatedUser) {
    return this.certificate.status(user.id);
  }

  @Get("download")
  download(@CurrentUser() user: AuthenticatedUser) {
    return this.certificate.download(user.id);
  }
}
