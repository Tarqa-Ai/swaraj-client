import { ConflictException, Injectable, NotFoundException } from "@nestjs/common";
import { DebateSide, PoliticalIQReason } from "@prisma/client";
import { POLITICAL_IQ_POINTS } from "@swaraj/shared-utils";
import { GamificationService } from "../gamification/gamification.service";
import { PrismaService } from "../prisma/prisma.service";
import type { DebateResponseBody } from "./debate.schemas";

@Injectable()
export class DebateService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly gamification: GamificationService
  ) {}

  async current(userId: string) {
    const debate = await this.prisma.debate.findFirst({
      where: { isActive: true, deletedAt: null },
      include: { responses: { where: { userId } } }
    });
    if (!debate) throw new NotFoundException("No active debate");
    return { ...debate, responded: debate.responses.length > 0 };
  }

  async respond(userId: string, body: DebateResponseBody) {
    const debate = await this.prisma.debate.findFirst({ where: { id: body.debateId, isActive: true, deletedAt: null } });
    if (!debate) throw new NotFoundException("Active debate not found");

    const existing = await this.prisma.debateResponse.findUnique({
      where: { userId_debateId: { userId, debateId: body.debateId } }
    });
    if (existing) throw new ConflictException("Debate already completed");

    const response = await this.prisma.debateResponse.create({
      data: {
        userId,
        debateId: body.debateId,
        side: body.side as DebateSide,
        reflection: sanitize(body.reflection)
      }
    });
    await this.gamification.award(userId, POLITICAL_IQ_POINTS.debateParticipation, PoliticalIQReason.DEBATE, {
      debateId: body.debateId,
      responseId: response.id
    });
    return response;
  }
}

function sanitize(input: string) {
  return input.replace(/[<>]/g, "").trim();
}
