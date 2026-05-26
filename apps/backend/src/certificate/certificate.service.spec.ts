import { CertificateService } from "./certificate.service";

describe("CertificateService", () => {
  it("marks a student eligible after modules, challenge, and debate are complete", async () => {
    const prisma = {
      module: { count: jest.fn().mockResolvedValue(3) },
      moduleProgress: { count: jest.fn().mockResolvedValue(3) },
      dailyChallengeSubmission: { count: jest.fn().mockResolvedValue(1) },
      debateResponse: { count: jest.fn().mockResolvedValue(1) },
      certificate: { findFirst: jest.fn().mockResolvedValue(null) }
    };
    const storage = { put: jest.fn() };
    const service = new CertificateService(prisma as never, storage as never);
    await expect(service.status("user-1")).resolves.toMatchObject({ eligible: true });
  });
});
