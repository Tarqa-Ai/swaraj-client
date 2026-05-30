import { ConflictException } from "@nestjs/common";
import { DailyChallengeService } from "./daily-challenge.service";

describe("DailyChallengeService", () => {
  const prisma = {
    dailyChallenge: { findFirst: jest.fn() },
    dailyChallengeSubmission: { findUnique: jest.fn(), create: jest.fn() },
    user: { findUnique: jest.fn(), update: jest.fn() }
  };
  const gamification = { award: jest.fn() };

  beforeEach(() => jest.clearAllMocks());

  it("returns score, IQ earned, and streak after submission", async () => {
    prisma.dailyChallenge.findFirst.mockResolvedValue({
      id: "challenge-1",
      questions: [{ id: "q1", answer: "A", explanationEn: "A", explanationHi: "A" }]
    });
    prisma.dailyChallengeSubmission.findUnique.mockResolvedValue(null);
    prisma.dailyChallengeSubmission.create.mockResolvedValue({ id: "submission-1" });
    prisma.user.findUnique.mockResolvedValueOnce({ streakCount: 0, lastChallengeDate: null }).mockResolvedValueOnce({ streakCount: 1 });
    prisma.user.update.mockResolvedValue({});

    const service = new DailyChallengeService(prisma as never, gamification as never);
    const result = await service.submit("user-1", { challengeId: "challenge-1", answers: { q1: "A" } });

    expect(result.score).toBe(100);
    expect(result.iqEarned).toBe(40);
    expect(result.streakCount).toBe(1);
  });

  it("rejects duplicate submissions", async () => {
    prisma.dailyChallenge.findFirst.mockResolvedValue({ id: "challenge-1", questions: [] });
    prisma.dailyChallengeSubmission.findUnique.mockResolvedValue({ id: "existing" });

    const service = new DailyChallengeService(prisma as never, gamification as never);
    await expect(service.submit("user-1", { challengeId: "challenge-1", answers: {} })).rejects.toBeInstanceOf(ConflictException);
  });
});
