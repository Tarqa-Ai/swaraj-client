import { ConflictException, Injectable, NotFoundException } from "@nestjs/common";
import { PoliticalIQReason } from "@prisma/client";
import { POLITICAL_IQ_POINTS } from "@swaraj/shared-utils";
import { GamificationService } from "../gamification/gamification.service";
import { PrismaService } from "../prisma/prisma.service";
import type { DailyChallengeSubmitBody } from "./daily-challenge.schemas";

type ChallengeQuestion = {
  id: string;
  promptEn: string;
  promptHi: string;
  options: string[];
  answer: string;
  explanationEn: string;
  explanationHi: string;
};

@Injectable()
export class DailyChallengeService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly gamification: GamificationService
  ) {}

  async current(userId: string) {
    const start = startOfTodayUtc();
    const challenge =
      (await this.prisma.dailyChallenge.findFirst({
        where: { challengeDate: start, deletedAt: null },
        include: { submissions: { where: { userId } } }
      })) ??
      (await this.prisma.dailyChallenge.findFirst({
        where: { deletedAt: null },
        orderBy: { challengeDate: "desc" },
        include: { submissions: { where: { userId } } }
      }));
    if (!challenge) throw new NotFoundException("Daily challenge not found");
    return { ...challenge, completed: challenge.submissions.length > 0 };
  }

  async submit(userId: string, body: DailyChallengeSubmitBody) {
    const challenge = await this.prisma.dailyChallenge.findFirst({
      where: { id: body.challengeId, deletedAt: null }
    });
    if (!challenge) throw new NotFoundException("Daily challenge not found");

    const existing = await this.prisma.dailyChallengeSubmission.findUnique({
      where: { userId_challengeId: { userId, challengeId: body.challengeId } }
    });
    if (existing) throw new ConflictException("Challenge already submitted");

    const questions = challenge.questions as ChallengeQuestion[];
    const results = questions.map((question) => ({
      questionId: question.id,
      correct: body.answers[question.id] === question.answer,
      answer: question.answer,
      submitted: body.answers[question.id],
      explanationEn: question.explanationEn,
      explanationHi: question.explanationHi
    }));
    const correct = results.filter((result) => result.correct).length;
    const total = questions.length;
    const score = Math.round((correct / total) * 100);

    const submission = await this.prisma.dailyChallengeSubmission.create({
      data: { userId, challengeId: body.challengeId, answers: body.answers, score, correct, total }
    });

    await this.updateStreak(userId);
    const points =
      POLITICAL_IQ_POINTS.dailyChallengeParticipation +
      (correct === total ? POLITICAL_IQ_POINTS.dailyChallengePerfect : 0);
    await this.gamification.award(userId, points, PoliticalIQReason.DAILY_CHALLENGE, {
      challengeId: body.challengeId,
      submissionId: submission.id
    });

    return { submission, results };
  }

  async history(userId: string) {
    return this.prisma.dailyChallengeSubmission.findMany({
      where: { userId },
      include: { challenge: true },
      orderBy: { createdAt: "desc" },
      take: 30
    });
  }

  private async updateStreak(userId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) return;
    const today = startOfTodayUtc();
    const yesterday = new Date(today);
    yesterday.setUTCDate(yesterday.getUTCDate() - 1);
    const last = user.lastChallengeDate ? startOfDayUtc(user.lastChallengeDate) : null;
    const streakCount = last?.getTime() === yesterday.getTime() ? user.streakCount + 1 : 1;
    await this.prisma.user.update({
      where: { id: userId },
      data: { streakCount, lastChallengeDate: today }
    });
  }
}

function startOfTodayUtc() {
  return startOfDayUtc(new Date());
}

function startOfDayUtc(date: Date) {
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
}
