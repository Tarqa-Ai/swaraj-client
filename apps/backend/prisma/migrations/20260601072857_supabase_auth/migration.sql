/*
  Warnings:

  - You are about to drop the column `refreshTokenHash` on the `User` table. All the data in the column will be lost.
  - You are about to drop the `OtpChallenge` table. If the table is not empty, all the data it contains will be lost.
  - A unique constraint covering the columns `[supabaseId]` on the table `User` will be added. If there are existing duplicate values, this will fail.

*/
-- DropForeignKey
ALTER TABLE "OtpChallenge" DROP CONSTRAINT "OtpChallenge_userId_fkey";

-- AlterTable
ALTER TABLE "User" DROP COLUMN "refreshTokenHash",
ADD COLUMN     "supabaseId" TEXT;

-- DropTable
DROP TABLE "OtpChallenge";

-- CreateIndex
CREATE UNIQUE INDEX "User_supabaseId_key" ON "User"("supabaseId");
