import React from "react";
import Link from "next/link";
import { ArrowLeft, FileText } from "lucide-react";

export default function TermsOfServicePage() {
  return (
    <div className="min-h-screen bg-slate-50 text-slate-900 font-dm-sans selection:bg-slate-200">
      
      {/* Premium Minimal Header */}
      <header className="bg-white/80 backdrop-blur-md sticky top-0 z-50 border-b border-slate-100 px-6 py-4">
        <div className="mx-auto flex max-w-4xl items-center justify-between">
          <Link href="/" className="flex items-center gap-2 text-slate-500 hover:text-slate-900 transition font-medium text-sm">
            <ArrowLeft size={16} /> Back to Home
          </Link>
          <div className="flex items-center gap-2">
            <FileText size={16} className="text-slate-400" />
            <span className="font-syne text-sm font-bold tracking-tight text-slate-900">Legal</span>
          </div>
        </div>
      </header>

      <main className="max-w-4xl mx-auto px-6 py-16 md:py-24">
        <div className="bg-white border border-slate-200 shadow-sm rounded-3xl p-8 md:p-16">
          <div className="mb-12 border-b border-slate-100 pb-8">
            <h1 className="font-syne text-4xl md:text-5xl font-bold tracking-tight text-slate-900">Terms of Service</h1>
            <p className="mt-4 text-slate-500 font-medium">Last Updated: June 10, 2026</p>
          </div>

          <div className="space-y-10 text-slate-700 leading-relaxed font-dm-sans text-[15px]">
            
            <section className="space-y-4">
              <h2 className="font-syne text-2xl font-bold text-slate-900">1. Acceptance of Terms</h2>
              <p>
                By accessing or using the Swaraj application and website (collectively, the "Service"), you agree to be bound by these Terms of Service. If you do not agree to all the terms and conditions, you must not use the Service.
              </p>
              <p>
                The Service is a personal project operated by <strong>Siddharth Sharma</strong>. It is provided for educational and informational purposes, primarily targeting students to learn about civic duties and constitutional rights.
              </p>
            </section>

            <section className="space-y-4">
              <h2 className="font-syne text-2xl font-bold text-slate-900">2. Eligibility and Account Registration</h2>
              <p>
                To use certain features of the Service, you must register for an account using your mobile phone number.
              </p>
              <ul className="list-disc pl-5 space-y-2 text-slate-600">
                <li>If you are under the age of 18, you represent that you have the consent of a parent or legal guardian to use the Service.</li>
                <li>You are responsible for maintaining the confidentiality of your login credentials (OTP) and for all activities that occur under your account.</li>
                <li>You agree to provide accurate and complete information when creating your profile.</li>
              </ul>
            </section>

            <section className="space-y-4">
              <h2 className="font-syne text-2xl font-bold text-slate-900">3. User Conduct</h2>
              <p>When participating in the Debate Arena, submitting Daily Challenges, or otherwise interacting with the Service, you agree not to:</p>
              <ul className="list-disc pl-5 space-y-2 text-slate-600">
                <li>Submit content that is abusive, harassing, defamatory, or hateful.</li>
                <li>Impersonate any person or entity or falsely state your affiliation with a person or entity.</li>
                <li>Use the Service for any illegal or unauthorized purpose.</li>
                <li>Attempt to bypass or manipulate the AI grading system or leaderboards.</li>
              </ul>
              <p>We reserve the right to suspend or terminate your account if you violate these rules.</p>
            </section>

            <section className="space-y-4">
              <h2 className="font-syne text-2xl font-bold text-slate-900">4. Intellectual Property</h2>
              <p>
                The Service and its original content (excluding user-provided content), features, and functionality are and will remain the exclusive property of Siddharth Sharma. The Service is protected by copyright and other intellectual property laws.
              </p>
              <p>
                By submitting content (like debate arguments or challenge answers), you grant us a non-exclusive right to use and display that content within the platform for educational purposes.
              </p>
            </section>

            <section className="space-y-4">
              <h2 className="font-syne text-2xl font-bold text-slate-900">5. Limitation of Liability</h2>
              <div className="bg-slate-50 border border-slate-100 p-5 rounded-2xl">
                <p className="font-bold text-slate-900 mb-2">Disclaimer of Warranties</p>
                <p>
                  The Service is provided on an "AS IS" and "AS AVAILABLE" basis. We make no warranties, expressed or implied, regarding the accuracy, reliability, or availability of the Service. The AI evaluations are generated by third-party APIs (Google Gemini) and should not be considered formal legal or academic advice.
                </p>
                <p className="mt-3">
                  In no event shall Siddharth Sharma be liable for any indirect, incidental, special, consequential, or punitive damages arising out of your use of or inability to use the Service.
                </p>
              </div>
            </section>

            <section className="space-y-4">
              <h2 className="font-syne text-2xl font-bold text-slate-900">6. Modifications to the Service</h2>
              <p>
                We reserve the right to modify or discontinue, temporarily or permanently, the Service (or any part thereof) with or without notice. We shall not be liable to you or to any third party for any modification, suspension, or discontinuance of the Service.
              </p>
            </section>

            <section className="space-y-4">
              <h2 className="font-syne text-2xl font-bold text-slate-900">7. Contact Information</h2>
              <p>If you have any questions about these Terms, please contact:</p>
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
