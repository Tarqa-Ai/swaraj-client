/**
 * reset.ts — wipe all rows from every table in dependency order, then exit.
 * Run with: tsx prisma/reset.ts
 * Follow with: tsx prisma/seed.ts
 */
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  console.log("⏳ Wiping all data...");

  // User-owned leaf records (cascade would handle these, but explicit is safer)
  await prisma.politicalIQLog.deleteMany();
  await prisma.userAchievement.deleteMany();
  await prisma.certificate.deleteMany();
  await prisma.lessonProgress.deleteMany();
  await prisma.moduleProgress.deleteMany();
  await prisma.quizSubmission.deleteMany();
  await prisma.dailyChallengeSubmission.deleteMany();
  await prisma.debateResponse.deleteMany();

  // Users (no FK deps remaining)
  const { count: users } = await prisma.user.deleteMany();
  console.log(`  deleted ${users} user(s)`);

  // Content
  await prisma.quizQuestion.deleteMany();
  await prisma.quiz.deleteMany();
  const { count: lessons } = await prisma.lesson.deleteMany();
  const { count: modules } = await prisma.module.deleteMany();
  console.log(`  deleted ${modules} module(s), ${lessons} lesson(s)`);

  const { count: challenges } = await prisma.dailyChallenge.deleteMany();
  console.log(`  deleted ${challenges} daily challenge(s)`);

  const { count: debates } = await prisma.debate.deleteMany();
  console.log(`  deleted ${debates} debate(s)`);

  await prisma.achievement.deleteMany();
  await prisma.mediaAsset.deleteMany();

  // Admin + Schools
  const { count: admins } = await prisma.adminUser.deleteMany();
  const { count: schools } = await prisma.school.deleteMany();
  console.log(`  deleted ${admins} admin(s), ${schools} school(s)`);

  console.log("✅ Database wiped. Run `tsx prisma/seed.ts` to re-seed.");
}

main()
  .finally(() => prisma.$disconnect())
  .catch((e) => {
    console.error(e);
    prisma.$disconnect();
    process.exit(1);
  });
