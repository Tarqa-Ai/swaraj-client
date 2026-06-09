import React from "react";
import Link from "next/link";
import { ArrowLeft, Shield } from "lucide-react";

export default function PrivacyPolicyPage() {
  return (
    <div className="min-h-screen bg-slate-50 text-slate-900 font-dm-sans selection:bg-slate-200">
      
      {/* Premium Minimal Header */}
      <header className="bg-white/80 backdrop-blur-md sticky top-0 z-50 border-b border-slate-100 px-6 py-4">
        <div className="mx-auto flex max-w-4xl items-center justify-between">
          <Link href="/" className="flex items-center gap-2 text-slate-500 hover:text-slate-900 transition font-medium text-sm">
            <ArrowLeft size={16} /> Back to Home
          </Link>
          <div className="flex items-center gap-2">
            <Shield size={16} className="text-slate-400" />
            <span className="font-syne text-sm font-bold tracking-tight text-slate-900">Legal</span>
          </div>
        </div>
      </header>

      <main className="max-w-4xl mx-auto px-6 py-16 md:py-24">
        <div className="bg-white border border-slate-200 shadow-sm rounded-3xl p-8 md:p-16">
          <div className="mb-12 border-b border-slate-100 pb-8">
            <h1 className="font-syne text-4xl md:text-5xl font-bold tracking-tight text-slate-900">Privacy Policy</h1>
            <p className="mt-4 text-slate-500 font-medium">Last Updated: June 10, 2026</p>
          </div>

          <div className="space-y-10 text-slate-700 leading-relaxed font-dm-sans text-[15px]">
            
            <section className="space-y-4">
              <h2 className="font-syne text-2xl font-bold text-slate-900">1. Introduction</h2>
              <p>
                Welcome to <strong>Swaraj</strong>, a civic education platform designed to empower students to understand their constitutional rights and local governance. This Privacy Policy outlines how <strong>Siddharth Sharma</strong> (the "App Owner", "we", "us", or "our") collects, uses, and protects your personal information across our mobile application (Android/iOS) and web dashboard.
              </p>
              <p>
                By using the Swaraj application, you agree to the collection and use of information in accordance with this policy. This policy is designed to comply with the <strong>Digital Personal Data Protection Act, 2023 (India)</strong>, as well as the developer guidelines of the <strong>Apple App Store</strong> and <strong>Google Play Store</strong>.
              </p>
            </section>

            <section className="space-y-4">
              <h2 className="font-syne text-2xl font-bold text-slate-900">2. Information We Collect</h2>
              <p>To provide our educational services and maintain academic leaderboards, we collect the following types of information:</p>
              <ul className="list-disc pl-5 space-y-2 text-slate-600">
                <li><strong>Personal Identifiers:</strong> Your mobile phone number (used for secure OTP login), full name, and grade level.</li>
                <li><strong>Educational Data:</strong> Quiz scores, civic literacy metrics, and completed modules.</li>
                <li><strong>User-Generated Content:</strong> Text answers submitted to Daily Challenges and comments posted in the Debate Arena.</li>
                <li><strong>Usage Data:</strong> Automatically collected data such as device type, operating system version, and application interaction logs to improve app stability.</li>
              </ul>
            </section>

            <section className="space-y-4">
              <h2 className="font-syne text-2xl font-bold text-slate-900">3. How We Use Your Information</h2>
              <p>We use the collected data strictly for educational and functional purposes:</p>
              <ul className="list-disc pl-5 space-y-2 text-slate-600">
                <li>To authenticate your identity and maintain a secure session.</li>
                <li>To evaluate your civic knowledge and assign scores using automated AI graders.</li>
                <li>To generate official digital certificates of achievement based on your performance.</li>
                <li>To maintain localized leaderboards (School and Regional levels).</li>
              </ul>
            </section>

            <section className="space-y-4">
              <h2 className="font-syne text-2xl font-bold text-slate-900">4. Third-Party Services</h2>
              <p>We do not sell your personal data. We utilize trusted third-party infrastructure providers to operate the platform securely:</p>
              <div className="bg-slate-50 border border-slate-100 p-5 rounded-2xl space-y-3">
                <p><strong>Supabase:</strong> We use Supabase for database hosting, secure file storage (for certificates), and Phone OTP authentication. Your data is encrypted at rest and in transit.</p>
                <p><strong>Google Gemini AI:</strong> When you submit a Daily Challenge, your text response is processed by the Google Gemini API to provide an educational evaluation. <em>Your name and phone number are never sent to the AI.</em> Data sent to the Gemini API via our backend is not used by Google to train their baseline models.</p>
              </div>
            </section>

            <section className="space-y-4">
              <h2 className="font-syne text-2xl font-bold text-slate-900">5. Children's Privacy & Parental Consent</h2>
              <p>
                Swaraj is designed for students in Grades 9 through 12. Depending on your jurisdiction, you may be considered a minor (e.g., under 18 years of age in India under the DPDP Act).
              </p>
              <p>
                <strong>If you are under 18 years of age:</strong> You must have verifiable consent from a parent or legal guardian to register and use this application. By entering your OTP and creating an account, you confirm that you have obtained such consent.
              </p>
              <p>
                We do not knowingly collect personal information from children under the age of 13 without parental consent. If we become aware that we have collected personal data from a child under 13 without verification, we will take steps to remove that information from our servers immediately.
              </p>
            </section>

            <section className="space-y-4">
              <h2 className="font-syne text-2xl font-bold text-slate-900">6. Data Retention and Account Deletion</h2>
              <p>
                You have the right to access, modify, or permanently delete your personal information at any time. We retain your educational records only as long as your account remains active.
              </p>
              <div className="bg-slate-900 text-white p-6 rounded-2xl space-y-2 mt-4">
                <h3 className="font-syne text-lg font-semibold">How to request data deletion:</h3>
                <ol className="list-decimal pl-5 space-y-1 text-slate-300">
                  <li>Navigate to your Profile Settings inside the Swaraj mobile app and select "Delete Account."</li>
                  <li>Alternatively, send an email to <strong>privacy@swaraj.org.in</strong> from your registered email address or referencing your registered phone number, stating your request to delete your account.</li>
                </ol>
                <p className="text-sm text-slate-400 mt-2">Upon receiving a deletion request, all your personal identifiers, quiz scores, and user-generated content will be permanently removed from our databases within 14 business days.</p>
              </div>
            </section>

            <section className="space-y-4">
              <h2 className="font-syne text-2xl font-bold text-slate-900">7. Changes to This Privacy Policy</h2>
              <p>
                We may update our Privacy Policy from time to time. We will notify you of any changes by updating the "Last Updated" date at the top of this page and, where appropriate, sending a notification within the app.
              </p>
            </section>

            <section className="space-y-4">
              <h2 className="font-syne text-2xl font-bold text-slate-900">8. Contact Us</h2>
              <p>If you have any questions, concerns, or requests regarding this Privacy Policy, please contact the App Owner:</p>
              <ul className="list-none space-y-1 text-slate-600">
                <li><strong>Owner:</strong> Siddharth Sharma</li>
                <li><strong>Email:</strong> privacy@swaraj.org.in</li>
              </ul>
            </section>

          </div>
        </div>
      </main>

      {/* Minimal Footer */}
      <footer className="border-t border-slate-100 bg-white py-8 px-6 text-center">
        <p className="font-dm-sans text-xs text-slate-400">
          © 2026 Siddharth Sharma. All rights reserved.
        </p>
      </footer>
    </div>
  );
}
