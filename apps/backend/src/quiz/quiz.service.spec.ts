import { ConflictException } from "@nestjs/common";
import { QuizService } from "./quiz.service";

describe("QuizService", () => {
  const prisma = {
    quiz: { findFirst: jest.fn() },
    quizSubmission: { findMany: jest.fn(), create: jest.fn() }
  };
  const gamification = { award: jest.fn() };

  beforeEach(() => jest.clearAllMocks());

  it("awards only the score improvement over the previous best attempt", async () => {
    prisma.quiz.findFirst.mockResolvedValue({
      id: "quiz-1",
      questions: [{ id: "q1", answer: "A", explanationEn: "Because A", explanationHi: "A", order: 1 }]
    });
    prisma.quizSubmission.findMany.mockResolvedValue([{ score: 50 }]);
    prisma.quizSubmission.create.mockResolvedValue({ id: "submission-1" });

    const service = new QuizService(prisma as never, gamification as never);
    const result = await service.submit("user-1", { quizId: "quiz-1", answers: { q1: "A" } });

    expect(result.iqEarned).toBe(50);
    expect(gamification.award).toHaveBeenCalledWith("user-1", 50, "QUIZ_SCORE", { quizId: "quiz-1", submissionId: "submission-1" });
  });

  it("blocks attempts after three submissions", async () => {
    prisma.quiz.findFirst.mockResolvedValue({ id: "quiz-1", questions: [] });
    prisma.quizSubmission.findMany.mockResolvedValue([{ score: 10 }, { score: 20 }, { score: 30 }]);

    const service = new QuizService(prisma as never, gamification as never);
    await expect(service.submit("user-1", { quizId: "quiz-1", answers: {} })).rejects.toBeInstanceOf(ConflictException);
  });
});
