import { Injectable, NotFoundException } from "@nestjs/common";
import PDFDocument from "pdfkit";
import { randomBytes } from "node:crypto";
import { FileStorageService } from "../storage/storage.service";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class CertificateService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: FileStorageService
  ) {}

  async status(userId: string) {
    const [totalModules, completedModules, challenges, debates, certificate] = await Promise.all([
      this.prisma.module.count({ where: { deletedAt: null } }),
      this.prisma.moduleProgress.count({ where: { userId } }),
      this.prisma.dailyChallengeSubmission.count({ where: { userId } }),
      this.prisma.debateResponse.count({ where: { userId } }),
      this.prisma.certificate.findFirst({ where: { userId }, orderBy: { issuedAt: "desc" } })
    ]);
    const eligible = completedModules >= totalModules && challenges >= 1 && debates >= 1;
    return { eligible, totalModules, completedModules, challenges, debates, certificate };
  }

  async download(userId: string) {
    const status = await this.status(userId);
    if (!status.eligible) return status;
    if (status.certificate) return status.certificate;

    const user = await this.prisma.user.findUnique({ where: { id: userId }, include: { school: true } });
    if (!user) throw new NotFoundException();
    const verificationCode = randomBytes(9).toString("base64url");
    const pdf = await this.createPdf(user.name ?? "Student", user.school?.name ?? "SWARAJ School", verificationCode);
    const key = `certificates/${userId}/${verificationCode}.pdf`;
    const certificateUrl = await this.storage.put(key, pdf, "application/pdf");

    return this.prisma.certificate.create({
      data: {
        userId,
        title: "Certified Young Civic Leader",
        certificateUrl,
        verificationCode
      }
    });
  }

  async verify(code: string) {
    const certificate = await this.prisma.certificate.findUnique({
      where: { verificationCode: code },
      include: { user: { include: { school: true } } }
    });
    if (!certificate) throw new NotFoundException("Certificate not found");
    return {
      status: "valid",
      verificationCode: certificate.verificationCode,
      title: certificate.title,
      student: {
        id: certificate.user.id,
        name: certificate.user.name,
        school: certificate.user.school?.name ?? null
      },
      issuedAt: certificate.issuedAt
    };
  }

  private async createPdf(studentName: string, schoolName: string, verificationCode: string) {
    return new Promise<Buffer>((resolve) => {
      const doc = new PDFDocument({ size: "A4", layout: "landscape", margin: 48 });
      const chunks: Buffer[] = [];
      doc.on("data", (chunk: Buffer) => chunks.push(chunk));
      doc.on("end", () => resolve(Buffer.concat(chunks)));

      doc.rect(24, 24, 794, 547).lineWidth(3).stroke("#0B1F3A");
      doc.rect(38, 38, 766, 519).lineWidth(1).stroke("#F28C28");
      doc.fillColor("#0B1F3A").fontSize(32).text("SWARAJ", { align: "center" });
      doc.moveDown(0.5);
      doc.fillColor("#F28C28").fontSize(26).text("Certified Young Civic Leader", { align: "center" });
      doc.moveDown(1.4);
      doc.fillColor("#111827").fontSize(16).text("This certificate is proudly awarded to", { align: "center" });
      doc.moveDown(0.5);
      doc.fillColor("#0B1F3A").fontSize(34).text(studentName, { align: "center" });
      doc.moveDown(0.5);
      doc.fillColor("#374151").fontSize(16).text(`from ${schoolName}`, { align: "center" });
      doc.moveDown(1);
      doc.fontSize(14).text("for completing the core civic learning journey in constitutional literacy, democratic participation, and responsible citizenship.", {
        align: "center"
      });
      doc.moveDown(2);
      doc.fontSize(11).fillColor("#6B7280").text(`Verification Code: ${verificationCode}`, { align: "center" });
      doc.end();
    });
  }
}
