import { Injectable, NotFoundException } from "@nestjs/common";
import { PoliticalIQReason } from "@prisma/client";
import { scoreQuiz } from "@swaraj/shared-utils";
import { GamificationService } from "../gamification/gamification.service";
import { PrismaService } from "../prisma/prisma.service";
import type { QuizSubmitBody } from "./quiz.schemas";

@Injectable()
export class QuizService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly gamification: GamificationService
  ) {}

  async submit(userId: string, body: QuizSubmitBody) {
    const quiz = await this.prisma.quiz.findFirst({
      where: { id: body.quizId, deletedAt: null },
      include: { questions: { where: { deletedAt: null }, orderBy: { order: "asc" } } }
    });
    if (!quiz) throw new NotFoundException("Quiz not found");

    const results = quiz.questions.map((question) => {
      const submitted = body.answers[question.id];
      const correct = JSON.stringify(submitted) === JSON.stringify(question.answer);
      return {
        questionId: question.id,
        correct,
        submitted,
        answer: question.answer,
        explanationEn: question.explanationEn,
        explanationHi: question.explanationHi
      };
    });
    const correct = results.filter((result) => result.correct).length;
    const total = quiz.questions.length;
    const score = scoreQuiz(correct, total);

    const submission = await this.prisma.quizSubmission.create({
      data: {
        userId,
        quizId: quiz.id,
        answers: body.answers,
        score,
        correct,
        total
      }
    });

    await this.gamification.award(userId, score, PoliticalIQReason.QUIZ_SCORE, { quizId: quiz.id, submissionId: submission.id });
    return { submission, results };
  }
}
