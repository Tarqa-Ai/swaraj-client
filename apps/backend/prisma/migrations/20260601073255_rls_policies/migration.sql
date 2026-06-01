-- Create explicit deny-all policies on all public tables to satisfy Supabase "RLS Enabled No Policy" linter check and completely secure PostgREST access.

CREATE POLICY "deny_all" ON "AdminUser" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "MediaAsset" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "School" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "Module" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "Lesson" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "LessonProgress" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "ModuleProgress" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "Quiz" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "QuizQuestion" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "QuizSubmission" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "DailyChallengeSubmission" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "DailyChallenge" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "DebateResponse" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "Debate" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "PoliticalIQLog" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "UserAchievement" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "Achievement" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "Certificate" FOR ALL USING (false);
CREATE POLICY "deny_all" ON "User" FOR ALL USING (false);

-- Safely create a policy on _prisma_migrations only if the table exists (to avoid Prisma shadow database errors)
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = '_prisma_migrations') THEN
        IF NOT EXISTS (SELECT FROM pg_policies WHERE schemaname = 'public' AND tablename = '_prisma_migrations' AND policyname = 'deny_all') THEN
            CREATE POLICY "deny_all" ON "public"."_prisma_migrations" FOR ALL USING (false);
        END IF;
    END IF;
END
$$;