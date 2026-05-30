import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { JwtModule } from "@nestjs/jwt";
import { ThrottlerModule } from "@nestjs/throttler";
import { AdminModule } from "./admin/admin.module";
import { AiModule } from "./ai/ai.module";
import { AuthModule } from "./auth/auth.module";
import { CertificateModule } from "./certificate/certificate.module";
import { DailyChallengeModule } from "./daily-challenge/daily-challenge.module";
import { DebateModule } from "./debate/debate.module";
import { GamificationModule } from "./gamification/gamification.module";
import { LeaderboardModule } from "./leaderboard/leaderboard.module";
import { LearningModule } from "./learning/learning.module";
import { PrismaModule } from "./prisma/prisma.module";
import { ProfileModule } from "./profile/profile.module";
import { QuizModule } from "./quiz/quiz.module";
import { StorageModule } from "./storage/storage.module";
import { HealthController } from "./health.controller";

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ThrottlerModule.forRoot([{ ttl: 60_000, limit: 60 }]),
    JwtModule.register({ global: true }),
    PrismaModule,
    StorageModule,
    GamificationModule,
    AuthModule,
    ProfileModule,
    LearningModule,
    QuizModule,
    DailyChallengeModule,
    DebateModule,
    AiModule,
    LeaderboardModule,
    CertificateModule,
    AdminModule
  ],
  controllers: [HealthController]
})
export class AppModule {}
