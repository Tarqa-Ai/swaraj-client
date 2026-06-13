"use client";

import React, { useState } from "react";
import Link from "next/link";
import {
  Award,
  BookOpen,
  HelpCircle,
  MessageSquare,
  Smartphone,
  ArrowRight,
  Shield,
  Star,
  Users,
  CheckCircle,
  Download,
  Flame,
  Check,
  X,
  ChevronRight,
  Sparkles,
  Send,
  Compass,
  FileBadge,
  Calendar,
  Lock
} from "lucide-react";

interface CitizenProfile {
  name: string;
  grade: string;
  level: number;
  streak: number;
  serial: string;
  date: string;
  metrics: {
    constitution: number; // percentage
    localImpact: number;  // percentage
    participation: number; // percentage
  };
  badges: { name: string; desc: string; icon: string }[];
  reports: { title: string; status: string; date: string; score: string }[];
}

export default function Home() {
  // Playground State
  const [activeTab, setActiveTab] = useState<"quiz" | "ai" | "debate">("quiz");

  // Quiz State
  const [selectedQuizOption, setSelectedQuizOption] = useState<number | null>(null);
  const quizAnswered = selectedQuizOption !== null;
  const quizOptions = [
    { text: "Right to Equality", correct: false },
    { text: "Right to Freedom of Speech", correct: false },
    { text: "Right to Property", correct: true, explanation: "Initially a Fundamental Right under Article 19, the Right to Property was converted into a legal right under Article 300A by the 44th Constitutional Amendment in 1978." },
    { text: "Right to Constitutional Remedies", correct: false }
  ];

  // AI Evaluation simulator state
  const [submittedAnswer, setSubmittedAnswer] = useState("");
  const [aiResult, setAiResult] = useState<{
    score: number;
    points: string[];
    feedback: string;
  } | null>(null);
  const [isEvaluating, setIsEvaluating] = useState(false);

  const simulateAiEvaluation = () => {
    if (!submittedAnswer.trim()) return;
    setIsEvaluating(true);
    setAiResult(null);
    setTimeout(() => {
      setIsEvaluating(false);
      setAiResult({
        score: 8.5,
        points: ["Constitutional Relevance: 9/10", "Practical Action Plan: 8/10", "Local Governance Insight: 8.5/10"],
        feedback: "Excellent response. You correctly identified the Gram Panchayat as the primary executive body responsible for local water supply under the 11th Schedule. Referencing Article 21 (Right to Clean Water as part of Right to Life) adds solid legal backing."
      });
    }, 1200);
  };

  // Debate State
  const [debateVotes, setDebateVotes] = useState({ pro: 64, con: 36, voted: null as "pro" | "con" | null });
  const handleDebateVote = (side: "pro" | "con") => {
    if (debateVotes.voted) return;
    setDebateVotes({
      pro: side === "pro" ? debateVotes.pro + 1 : debateVotes.pro,
      con: side === "con" ? debateVotes.con + 1 : debateVotes.con,
      voted: side
    });
  };

  // Citizen Showcase States
  const citizenProfiles: CitizenProfile[] = [
    {
      name: "Priya Sharma",
      grade: "Grade 12",
      level: 14,
      streak: 15,
      serial: "SWJ-2026-9928",
      date: "May 24, 2026",
      metrics: { constitution: 92, localImpact: 84, participation: 78 },
      badges: [
        { name: "Preamble Scholar", desc: "Completed all Fundamental Rights lessons", icon: "📜" },
        { name: "Panchayat Voice", desc: "Submitted an AI-approved local sewage solution", icon: "🏡" },
        { name: "Debate Leader", desc: "Acquired 50+ upvotes in regional debate rooms", icon: "💬" }
      ],
      reports: [
        { title: "Reported water logging at Sector 4 Main Road", status: "Verified", date: "2 days ago", score: "8.5/10" },
        { title: "Drafted public dustbin placement layout for school", status: "Pending", date: "4 days ago", score: "Reviewing" }
      ]
    },
    {
      name: "Aditya Verma",
      grade: "Grade 10",
      level: 9,
      streak: 8,
      serial: "SWJ-2026-1045",
      date: "June 02, 2026",
      metrics: { constitution: 75, localImpact: 68, participation: 90 },
      badges: [
        { name: "Electoral Cadet", desc: "Simulated a local mock-voting chamber", icon: "🗳️" },
        { name: "First Responder", desc: "Answered 5 consecutive Daily Challenges", icon: "⚡" },
        { name: "Constitutionalist", desc: "Scored 100% on the Bill Passage quiz", icon: "⚖️" }
      ],
      reports: [
        { title: "Gram Panchayat budget audit request submission", status: "Verified", date: "1 week ago", score: "9.0/10" },
        { title: "Waste classification proposal for apartment block", status: "Verified", date: "2 weeks ago", score: "7.8/10" }
      ]
    }
  ];

  const [activeCitizenIdx, setActiveCitizenIdx] = useState(0);
  const currentCitizen = citizenProfiles[activeCitizenIdx];

  return (
    <div className="min-h-screen bg-slate-50 text-slate-900 font-dm-sans selection:bg-slate-200 relative overflow-x-hidden">

      {/* Premium Minimal Header */}
      <header className="bg-white/80 backdrop-blur-md sticky top-0 z-50 border-b border-slate-100 px-6 py-4 transition-all">
        <div className="mx-auto flex max-w-7xl items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="h-8 w-8 rounded-full bg-slate-900 flex items-center justify-center shadow-sm">
              <span className="text-white text-xs font-syne font-bold">S</span>
            </div>
            <div>
              <p className="font-syne text-lg font-bold tracking-tight text-slate-900 leading-none">SWARAJ</p>
              <p className="font-dm-sans text-[10px] text-slate-500 font-medium">Civic Learning</p>
            </div>
          </div>

          <div className="flex items-center gap-6">
            <Link
              href="#showcase"
              className="hidden md:inline-block font-dm-sans text-sm font-medium text-slate-500 hover:text-slate-900 transition"
            >
              Dashboard
            </Link>
            <Link
              href="#playground"
              className="hidden md:inline-block font-dm-sans text-sm font-medium text-slate-500 hover:text-slate-900 transition"
            >
              Interactive Demo
            </Link>
            <Link
              href="#founder"
              className="hidden md:inline-block font-dm-sans text-sm font-medium text-slate-500 hover:text-slate-900 transition"
            >
              Founder
            </Link>
            <Link
              href="#download"
              className="bg-slate-900 text-white font-dm-sans text-sm font-medium px-5 py-2.5 rounded-full hover:bg-slate-800 transition duration-300 shadow-sm"
            >
              Get the App
            </Link>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="relative px-6 py-24 md:py-32 max-w-7xl mx-auto flex flex-col items-center text-center">
        <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white border border-slate-200 shadow-sm text-slate-600 font-dm-sans text-xs font-medium mb-8">
          <Sparkles size={14} className="text-slate-400" /> Civic Education 2.0
        </div>

        <h1 className="font-syne text-5xl md:text-7xl lg:text-8xl font-bold tracking-tight text-slate-900 max-w-5xl leading-[1.1]">
          The Architecture of <br />
          <span className="text-slate-400">Democracy, Decoded.</span>
        </h1>

        <p className="mt-6 max-w-2xl text-lg text-slate-500 font-dm-sans leading-relaxed">
          Empowering Grade 9–12 students to become informed, active citizens through structured curriculum exploration, peer-to-peer debates, and AI-powered evaluation metrics.
        </p>

        <div className="mt-10 flex flex-col sm:flex-row gap-4 w-full sm:w-auto">
          <Link
            href="#download"
            className="w-full sm:w-auto bg-slate-900 text-white font-dm-sans font-medium py-3.5 px-8 rounded-full hover:bg-slate-800 transition-all shadow-md hover:shadow-lg flex items-center justify-center gap-2"
          >
            Download App <ArrowRight size={18} />
          </Link>
          <Link
            href="#showcase"
            className="w-full sm:w-auto bg-white border border-slate-200 text-slate-700 font-dm-sans font-medium py-3.5 px-8 rounded-full hover:bg-slate-50 transition-all shadow-sm"
          >
            View Dashboard
          </Link>
        </div>

        <div className="mt-20 w-full max-w-5xl rounded-3xl overflow-hidden border border-slate-200 shadow-2xl shadow-slate-200/50 relative bg-white flex justify-center items-center p-2">
          <img
            className="w-full rounded-2xl object-cover aspect-video mix-blend-multiply opacity-90"
            alt="A clean, minimalist representation of parliamentary architecture"
            src="/hero.jpg"
          />
        </div>
      </section>

      {/* The Core Platform */}
      <section className="py-24 px-6 bg-white border-y border-slate-100">
        <div className="mx-auto max-w-7xl">
          <div className="text-center mb-16">
            <h3 className="font-syne text-3xl md:text-4xl font-bold text-slate-900">The Swaraj Ecosystem</h3>
            <p className="mt-4 text-slate-500 font-dm-sans max-w-2xl mx-auto">A seamless platform connecting students, AI evaluation, and institutional oversight.</p>
          </div>

          <div className="grid gap-6 md:grid-cols-3">
            {/* Mobile Learning */}
            <div className="bg-slate-50 border border-slate-100 p-10 rounded-3xl transition-all hover:shadow-lg hover:-translate-y-1">
              <div className="h-14 w-14 bg-white rounded-2xl flex items-center justify-center border border-slate-200 shadow-sm mb-6">
                <Smartphone className="text-slate-600" size={24} />
              </div>
              <h4 className="font-syne text-xl font-semibold text-slate-900">Mobile Learning</h4>
              <p className="font-dm-sans text-sm text-slate-500 leading-relaxed mt-3">
                High-fidelity application designed for deep student engagement and bite-sized civic curriculum delivery.
              </p>
            </div>

            {/* AI Evaluation */}
            <div className="bg-slate-900 border border-slate-800 p-10 rounded-3xl transition-all hover:shadow-xl hover:-translate-y-1 shadow-md relative overflow-hidden group">
              <div className="absolute inset-0 bg-gradient-to-br from-slate-800/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity"></div>
              <div className="h-14 w-14 bg-slate-800 rounded-2xl flex items-center justify-center border border-slate-700 shadow-inner mb-6 relative z-10">
                <Sparkles className="text-white" size={24} />
              </div>
              <h4 className="font-syne text-xl font-semibold text-white relative z-10">AI Evaluation</h4>
              <p className="font-dm-sans text-sm text-slate-400 leading-relaxed mt-3 relative z-10">
                Advanced AI-powered grading system providing instant, nuanced feedback on subjective civic inquiries.
              </p>
            </div>

            {/* Admin Oversight */}
            <div className="bg-slate-50 border border-slate-100 p-10 rounded-3xl transition-all hover:shadow-lg hover:-translate-y-1">
              <div className="h-14 w-14 bg-white rounded-2xl flex items-center justify-center border border-slate-200 shadow-sm mb-6">
                <Shield className="text-slate-600" size={24} />
              </div>
              <h4 className="font-syne text-xl font-semibold text-slate-900">Admin Oversight</h4>
              <p className="font-dm-sans text-sm text-slate-500 leading-relaxed mt-3">
                Comprehensive Next.js dashboard for educators to monitor real-time class progress and civic metrics securely.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Tagline Area */}
      <section className="py-16 px-6 bg-slate-50">
        <div className="mx-auto max-w-5xl flex flex-col md:flex-row items-center justify-center gap-8 md:gap-16 text-center divide-y md:divide-y-0 md:divide-x divide-slate-200">
          <div className="pt-6 md:pt-0 md:pl-0 md:pr-16 w-full md:w-auto">
            <h5 className="font-dm-sans text-xs font-semibold text-slate-400 uppercase tracking-wider">Pillar I</h5>
            <p className="font-syne text-lg font-medium text-slate-900 mt-2">Fundamental Rights</p>
          </div>
          <div className="pt-6 md:pt-0 md:pl-16 md:pr-16 w-full md:w-auto">
            <h5 className="font-dm-sans text-xs font-semibold text-slate-400 uppercase tracking-wider">Pillar II</h5>
            <p className="font-syne text-lg font-medium text-slate-900 mt-2">Local Government</p>
          </div>
          <div className="pt-6 md:pt-0 md:pl-16 w-full md:w-auto">
            <h5 className="font-dm-sans text-xs font-semibold text-slate-400 uppercase tracking-wider">Pillar III</h5>
            <p className="font-syne text-lg font-medium text-slate-900 mt-2">Electoral Process</p>
          </div>
        </div>
      </section>

      {/* Citizen Dashboard Showcase Section */}
      <section id="showcase" className="py-24 px-6 bg-white relative">
        <div className="mx-auto max-w-7xl">
          <div className="mb-12 flex flex-col md:flex-row md:items-end justify-between gap-6">
            <div>
              <h3 className="font-syne text-3xl font-bold text-slate-900">Citizen Dashboard</h3>
              <p className="mt-2 text-slate-500 font-dm-sans">Real-time student progress and engagement metrics.</p>
            </div>

            {/* Student Profile Toggles */}
            <div className="flex bg-slate-100 p-1.5 rounded-full border border-slate-200 w-fit">
              {citizenProfiles.map((p, idx) => (
                <button
                  key={idx}
                  onClick={() => setActiveCitizenIdx(idx)}
                  className={`px-5 py-2 font-dm-sans text-sm font-medium rounded-full transition-all ${activeCitizenIdx === idx ? "bg-white text-slate-900 shadow-sm" : "text-slate-500 hover:text-slate-900"}`}
                >
                  {p.name.split(' ')[0]}
                </button>
              ))}
            </div>
          </div>

          {/* Citizen Dashboard Grid */}
          <div className="grid md:grid-cols-12 gap-6 items-stretch">

            {/* Column Left: Stats & Activity */}
            <div className="md:col-span-4 flex flex-col gap-6">

              {/* Profile Card */}
              <div className="bg-white border border-slate-200 shadow-sm rounded-3xl p-8 flex flex-col gap-6 h-full">
                <div className="flex justify-between items-start">
                  <div>
                    <h4 className="font-syne text-2xl font-bold text-slate-900">{currentCitizen.name}</h4>
                    <p className="font-dm-sans text-sm text-slate-500 mt-1">{currentCitizen.grade} · Level {currentCitizen.level}</p>
                  </div>
                  <div className="flex items-center gap-1.5 bg-slate-50 text-slate-600 px-3 py-1.5 rounded-full border border-slate-200">
                    <Flame size={14} className="text-orange-500" />
                    <span className="font-dm-sans text-xs font-bold">{currentCitizen.streak}d</span>
                  </div>
                </div>

                <div className="space-y-5">
                  {/* Metric 1 */}
                  <div>
                    <div className="flex justify-between text-xs font-medium text-slate-600 mb-2">
                      <span>Constitutional Literacy</span>
                      <span className="text-slate-900">{currentCitizen.metrics.constitution}%</span>
                    </div>
                    <div className="h-1.5 w-full bg-slate-100 rounded-full overflow-hidden">
                      <div className="h-full bg-slate-900 rounded-full" style={{ width: `${currentCitizen.metrics.constitution}%` }} />
                    </div>
                  </div>

                  {/* Metric 2 */}
                  <div>
                    <div className="flex justify-between text-xs font-medium text-slate-600 mb-2">
                      <span>Local Action Index</span>
                      <span className="text-slate-900">{currentCitizen.metrics.localImpact}%</span>
                    </div>
                    <div className="h-1.5 w-full bg-slate-100 rounded-full overflow-hidden">
                      <div className="h-full bg-slate-600 rounded-full" style={{ width: `${currentCitizen.metrics.localImpact}%` }} />
                    </div>
                  </div>

                  {/* Metric 3 */}
                  <div>
                    <div className="flex justify-between text-xs font-medium text-slate-600 mb-2">
                      <span>Deliberative Participation</span>
                      <span className="text-slate-900">{currentCitizen.metrics.participation}%</span>
                    </div>
                    <div className="h-1.5 w-full bg-slate-100 rounded-full overflow-hidden">
                      <div className="h-full bg-slate-400 rounded-full" style={{ width: `${currentCitizen.metrics.participation}%` }} />
                    </div>
                  </div>
                </div>
              </div>

              {/* Verified Submissions Feed */}
              <div className="bg-white border border-slate-200 shadow-sm rounded-3xl p-8 space-y-5">
                <p className="font-dm-sans text-xs font-semibold text-slate-400 uppercase tracking-wider">AI-Verified Proposals</p>
                <div className="space-y-5">
                  {currentCitizen.reports.map((rep, idx) => (
                    <div key={idx} className="space-y-1.5">
                      <div className="flex justify-between items-start text-sm font-medium text-slate-900 gap-4">
                        <span className="line-clamp-2 leading-snug">{rep.title}</span>
                        <span className="text-xs bg-slate-50 border border-slate-200 px-2 py-1 rounded-md text-slate-600 shrink-0">{rep.score}</span>
                      </div>
                      <div className="flex justify-between items-center text-xs text-slate-500">
                        <span>{rep.date}</span>
                        <span className="flex items-center gap-1.5 font-medium">
                          <span className={`h-2 w-2 rounded-full ${rep.status === "Verified" ? "bg-emerald-500" : "bg-orange-400"}`} />
                          {rep.status}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

            </div>

            {/* Column Center: Badge Vault */}
            <div className="md:col-span-4 bg-white border border-slate-200 shadow-sm rounded-3xl p-8 flex flex-col justify-between">
              <div>
                <p className="font-dm-sans text-xs font-semibold text-slate-400 uppercase tracking-wider mb-6">Citizen Badge Vault</p>
                <div className="grid gap-4">
                  {currentCitizen.badges.map((b, idx) => (
                    <div key={idx} className="flex items-center gap-4 p-4 border border-slate-100 rounded-2xl bg-slate-50 hover:bg-slate-100 hover:border-slate-200 transition-all cursor-default">
                      <div className="text-3xl filter drop-shadow-sm bg-white h-12 w-12 rounded-xl flex items-center justify-center border border-slate-200 shadow-sm shrink-0">{b.icon}</div>
                      <div>
                        <p className="font-syne text-sm font-semibold text-slate-900">{b.name}</p>
                        <p className="font-dm-sans text-xs text-slate-500 mt-1 line-clamp-2">{b.desc}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Column Right: Certificate Preview */}
            <div className="md:col-span-4 bg-white border border-slate-200 shadow-sm rounded-3xl p-8 flex flex-col justify-between">
              <div>
                <p className="font-dm-sans text-xs font-semibold text-slate-400 uppercase tracking-wider mb-6">Certificate Vault</p>

                {/* Certificate Template Box */}
                <div className="border border-slate-200 bg-slate-50 rounded-2xl p-6 text-center relative overflow-hidden shadow-inner flex flex-col items-center justify-center min-h-[300px]">
                  <Shield size={120} className="text-slate-200 absolute opacity-30 pointer-events-none" />

                  <p className="font-dm-sans text-[9px] font-bold tracking-widest text-slate-400 uppercase relative z-10">National Civic Merit</p>
                  <h5 className="font-syne text-lg font-bold text-slate-900 mt-2 tracking-tight relative z-10">CERTIFICATE OF ACHIEVEMENT</h5>

                  <div className="w-12 h-px bg-slate-300 mx-auto my-4 relative z-10"></div>

                  <p className="font-dm-sans text-xs font-medium text-slate-500 relative z-10">PROUDLY PRESENTED TO</p>
                  <p className="font-syne text-2xl font-bold text-slate-900 mt-2 relative z-10">{currentCitizen.name}</p>

                  <div className="grid grid-cols-2 w-full mt-8 pt-4 border-t border-slate-200 text-left relative z-10">
                    <div>
                      <p className="text-[9px] text-slate-400 font-semibold uppercase font-dm-sans mb-1">Issued On</p>
                      <p className="text-xs text-slate-700 font-medium">{currentCitizen.date}</p>
                    </div>
                    <div className="text-right">
                      <p className="text-[9px] text-slate-400 font-semibold uppercase font-dm-sans mb-1">Document ID</p>
                      <p className="text-xs text-slate-700 font-medium">{currentCitizen.serial}</p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="pt-6">
                <button
                  onClick={() => alert(`Downloading Certificate for ${currentCitizen.name}...`)}
                  className="w-full bg-white border border-slate-200 text-slate-900 font-dm-sans text-sm font-medium py-3 rounded-xl flex items-center justify-center gap-2 hover:bg-slate-50 transition-all shadow-sm"
                >
                  <FileBadge size={16} className="text-slate-500" />
                  Download Official PDF
                </button>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* Interactive Demo Playground */}
      <section id="playground" className="py-24 px-6 bg-slate-50 border-y border-slate-100">
        <div className="mx-auto max-w-7xl">
          <div className="mx-auto max-w-2xl text-center mb-16">
            <h2 className="font-syne text-3xl md:text-4xl font-bold tracking-tight text-slate-900">Live App Sandbox</h2>
            <p className="font-dm-sans text-slate-500 mt-4 max-w-lg mx-auto">
              Experience the core mechanics of Swaraj right now in your browser. Switch tabs to preview different civic features.
            </p>
          </div>

          <div className="mx-auto max-w-5xl bg-white border border-slate-200 shadow-xl shadow-slate-200/50 rounded-3xl overflow-hidden grid md:grid-cols-12">

            {/* Sidebar Navigation */}
            <div className="md:col-span-4 bg-slate-50 border-b md:border-b-0 md:border-r border-slate-200 p-4 flex flex-row md:flex-col gap-2 overflow-x-auto">
              <button
                onClick={() => setActiveTab("quiz")}
                className={`flex-1 md:flex-initial text-left px-5 py-4 text-sm font-dm-sans font-medium rounded-2xl transition-all flex items-center gap-3 whitespace-nowrap ${activeTab === "quiz" ? "bg-white text-slate-900 shadow-sm border border-slate-200" : "text-slate-500 border border-transparent hover:bg-slate-100 hover:text-slate-900"}`}
              >
                <HelpCircle size={18} />
                Constitutional Quiz
              </button>
              <button
                onClick={() => setActiveTab("ai")}
                className={`flex-1 md:flex-initial text-left px-5 py-4 text-sm font-dm-sans font-medium rounded-2xl transition-all flex items-center gap-3 whitespace-nowrap ${activeTab === "ai" ? "bg-white text-slate-900 shadow-sm border border-slate-200" : "text-slate-500 border border-transparent hover:bg-slate-100 hover:text-slate-900"}`}
              >
                <Sparkles size={18} />
                AI Grader
              </button>
              <button
                onClick={() => setActiveTab("debate")}
                className={`flex-1 md:flex-initial text-left px-5 py-4 text-sm font-dm-sans font-medium rounded-2xl transition-all flex items-center gap-3 whitespace-nowrap ${activeTab === "debate" ? "bg-white text-slate-900 shadow-sm border border-slate-200" : "text-slate-500 border border-transparent hover:bg-slate-100 hover:text-slate-900"}`}
              >
                <MessageSquare size={18} />
                Debate Arena
              </button>
            </div>

            {/* Sandbox Workspace */}
            <div className="md:col-span-8 p-8 md:p-12 flex flex-col justify-center min-h-[420px] bg-white">

              {/* Tab 1: Quiz */}
              {activeTab === "quiz" && (
                <div className="space-y-8 animate-in fade-in zoom-in-95 duration-300">
                  <div>
                    <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-slate-100 text-slate-600 font-dm-sans text-xs font-semibold uppercase tracking-wider mb-4">
                      Quiz Module
                    </div>
                    <h3 className="font-syne text-2xl font-bold text-slate-900 leading-snug">
                      Which of the following is NOT a Fundamental Right guaranteed under the Constitution of India?
                    </h3>
                  </div>

                  <div className="grid gap-3">
                    {quizOptions.map((opt, idx) => {
                      let btnStyle = "border-slate-200 bg-white text-slate-700 hover:bg-slate-50 hover:border-slate-300";
                      if (quizAnswered) {
                        if (opt.correct) {
                          btnStyle = "border-emerald-200 bg-emerald-50 text-emerald-800 cursor-default ring-1 ring-emerald-200";
                        } else if (selectedQuizOption === idx) {
                          btnStyle = "border-rose-200 bg-rose-50 text-rose-800 cursor-default ring-1 ring-rose-200";
                        } else {
                          btnStyle = "border-slate-100 bg-slate-50 text-slate-400 cursor-default";
                        }
                      }

                      return (
                        <button
                          key={idx}
                          disabled={quizAnswered}
                          onClick={() => setSelectedQuizOption(idx)}
                          className={`w-full text-left p-4 md:p-5 font-dm-sans font-medium border rounded-2xl transition-all flex items-center justify-between ${btnStyle}`}
                        >
                          <span>{opt.text}</span>
                          {quizAnswered && opt.correct && <Check size={20} className="text-emerald-600" />}
                          {quizAnswered && selectedQuizOption === idx && !opt.correct && <X size={20} className="text-rose-600" />}
                        </button>
                      );
                    })}
                  </div>

                  {quizAnswered && (
                    <div className="bg-slate-50 border border-slate-200 p-6 rounded-2xl mt-6 animate-in slide-in-from-bottom-2">
                      <div className="flex gap-4">
                        <div className="mt-1 h-8 w-8 bg-white rounded-full flex items-center justify-center border border-slate-200 shrink-0">
                          <BookOpen className="text-slate-500" size={16} />
                        </div>
                        <div>
                          <p className="font-dm-sans text-sm font-semibold text-slate-900">Educational Context</p>
                          <p className="mt-2 text-sm text-slate-600 leading-relaxed">
                            {selectedQuizOption !== null && quizOptions[selectedQuizOption].correct
                              ? "Correct! "
                              : "Incorrect. "}
                            {quizOptions[2].explanation}
                          </p>
                          <button
                            onClick={() => setSelectedQuizOption(null)}
                            className="mt-4 text-sm font-medium text-slate-900 hover:text-slate-600 transition flex items-center gap-1.5"
                          >
                            Reset Quiz <ArrowRight size={14} />
                          </button>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              )}

              {/* Tab 2: AI */}
              {activeTab === "ai" && (
                <div className="space-y-8 animate-in fade-in zoom-in-95 duration-300">
                  <div>
                    <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-slate-100 text-slate-600 font-dm-sans text-xs font-semibold uppercase tracking-wider mb-4">
                      AI Simulator
                    </div>
                    <h3 className="font-syne text-2xl font-bold text-slate-900 leading-snug">
                      Suggest a practical solution to handle solid waste collection in your neighborhood.
                    </h3>
                  </div>

                  <div className="space-y-4">
                    <textarea
                      value={submittedAnswer}
                      onChange={(e) => setSubmittedAnswer(e.target.value)}
                      placeholder="Type your response here... (e.g. 'I would set up segregating bins at the park and involve the local municipal ward committee...')"
                      className="w-full min-h-[140px] border border-slate-200 bg-slate-50 p-5 rounded-2xl outline-none focus:border-slate-400 focus:bg-white transition-all text-sm font-medium text-slate-900 resize-none shadow-inner"
                    />

                    <div className="flex justify-between items-center px-1">
                      <span className="font-dm-sans text-xs text-slate-500 flex items-center gap-1.5">
                        <Sparkles size={12} /> AI analyzes legal context and actionability
                      </span>
                      <button
                        onClick={simulateAiEvaluation}
                        disabled={isEvaluating || !submittedAnswer.trim()}
                        className="bg-slate-900 text-white font-dm-sans text-sm font-medium py-2.5 px-6 rounded-full hover:bg-slate-800 transition-all disabled:opacity-50 disabled:cursor-not-allowed shadow-sm"
                      >
                        {isEvaluating ? "Evaluating..." : "Submit to AI"}
                      </button>
                    </div>
                  </div>

                  {aiResult && (
                    <div className="border border-slate-200 bg-white p-6 space-y-4 rounded-2xl shadow-sm animate-in slide-in-from-bottom-2">
                      <div className="flex justify-between items-center border-b border-slate-100 pb-4">
                        <span className="font-dm-sans text-sm font-semibold text-slate-900 flex items-center gap-2">
                          <Sparkles size={16} className="text-slate-400" /> AI Feedback
                        </span>
                        <span className="font-dm-sans text-sm font-bold text-slate-900 bg-slate-100 px-3 py-1 rounded-full border border-slate-200">
                          Score: {aiResult.score}/10
                        </span>
                      </div>

                      <div className="space-y-2.5 pt-2">
                        {aiResult.points.map((p, i) => (
                          <div key={i} className="flex items-start gap-3 text-sm text-slate-600">
                            <CheckCircle size={16} className="text-slate-400 shrink-0 mt-0.5" />
                            <span>{p}</span>
                          </div>
                        ))}
                      </div>

                      <div className="bg-slate-50 p-4 rounded-xl mt-4">
                        <p className="text-sm leading-relaxed text-slate-600 italic">
                          "{aiResult.feedback}"
                        </p>
                      </div>
                    </div>
                  )}
                </div>
              )}

              {/* Tab 3: Debate */}
              {activeTab === "debate" && (
                <div className="space-y-8 animate-in fade-in zoom-in-95 duration-300">
                  <div>
                    <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-slate-100 text-slate-600 font-dm-sans text-xs font-semibold uppercase tracking-wider mb-4">
                      Live Debate
                    </div>
                    <h3 className="font-syne text-2xl font-bold text-slate-900 leading-snug">
                      Should student union elections be based on direct voting or academic merit selection?
                    </h3>
                  </div>

                  <div className="grid gap-4 sm:grid-cols-2">
                    <div className="border border-slate-200 p-6 bg-white rounded-2xl shadow-sm">
                      <div className="flex justify-between items-start mb-4">
                        <span className="font-dm-sans text-xs font-bold text-slate-900 uppercase">Direct Voting</span>
                        <span className="font-dm-sans text-xs text-slate-500 font-medium bg-slate-100 px-2 py-0.5 rounded border border-slate-200">148 votes</span>
                      </div>
                      <p className="text-sm text-slate-600 leading-relaxed">
                        "Direct elections teach democracy. Students learn about campaigns, manifestos, and voting accountability directly."
                      </p>
                    </div>

                    <div className="border border-slate-200 p-6 bg-white rounded-2xl shadow-sm">
                      <div className="flex justify-between items-start mb-4">
                        <span className="font-dm-sans text-xs font-bold text-slate-900 uppercase">Academic Merit</span>
                        <span className="font-dm-sans text-xs text-slate-500 font-medium bg-slate-100 px-2 py-0.5 rounded border border-slate-200">84 votes</span>
                      </div>
                      <p className="text-sm text-slate-600 leading-relaxed">
                        "Academic merit prevents elections from becoming mere popularity contests. It promotes leadership based on responsibility."
                      </p>
                    </div>
                  </div>

                  <div className="bg-slate-50 border border-slate-200 p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-6 rounded-2xl">
                    <div>
                      <p className="text-sm font-semibold text-slate-900">Cast your vote to view national results:</p>
                      {debateVotes.voted && (
                        <p className="mt-1.5 font-dm-sans text-xs font-medium text-slate-500">
                          Voted! Pro-voting: {debateVotes.pro}% | Merit: {debateVotes.con}%
                        </p>
                      )}
                    </div>

                    <div className="flex gap-3">
                      <button
                        onClick={() => handleDebateVote("pro")}
                        disabled={!!debateVotes.voted}
                        className={`px-5 py-2.5 font-dm-sans text-sm font-medium rounded-full border transition-all shadow-sm ${debateVotes.voted === "pro" ? "bg-slate-900 text-white border-slate-900" : "bg-white border-slate-200 text-slate-700 hover:bg-slate-50 disabled:opacity-50"}`}
                      >
                        Direct voting
                      </button>
                      <button
                        onClick={() => handleDebateVote("con")}
                        disabled={!!debateVotes.voted}
                        className={`px-5 py-2.5 font-dm-sans text-sm font-medium rounded-full border transition-all shadow-sm ${debateVotes.voted === "con" ? "bg-slate-900 text-white border-slate-900" : "bg-white border-slate-200 text-slate-700 hover:bg-slate-50 disabled:opacity-50"}`}
                      >
                        Academic Merit
                      </button>
                    </div>
                  </div>

                </div>
              )}

            </div>
          </div>
        </div>
      </section>

      {/* Structured Curriculum Features */}
      <section id="features" className="py-24 px-6 bg-white">
        <div className="mx-auto max-w-7xl">
          <div className="mx-auto max-w-2xl text-center mb-16">
            <h2 className="font-syne text-3xl md:text-4xl font-bold tracking-tight text-slate-900">Syllabus Breakdown</h2>
            <p className="font-dm-sans text-slate-500 mt-4 max-w-lg mx-auto leading-relaxed">
              Our curriculum aligns with standard social science frameworks, detailing local government acts and fundamental duties.
            </p>
          </div>

          <div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-3">
            {/* Feature 1 */}
            <div className="p-8 rounded-3xl border border-slate-100 bg-slate-50 transition-all hover:shadow-md hover:bg-white">
              <div className="mb-6 h-12 w-12 rounded-2xl bg-white text-slate-900 flex items-center justify-center border border-slate-200 shadow-sm">
                <Shield size={20} />
              </div>
              <h3 className="font-syne text-xl font-bold text-slate-900">The Constitutional Framework</h3>
              <p className="mt-3 text-sm leading-relaxed text-slate-500 font-dm-sans">
                Interactive text breakdowns of the Preamble, Fundamental Rights (Articles 14-32), and Directive Principles of State Policy.
              </p>
            </div>

            {/* Feature 2 */}
            <div className="p-8 rounded-3xl border border-slate-100 bg-slate-50 transition-all hover:shadow-md hover:bg-white">
              <div className="mb-6 h-12 w-12 rounded-2xl bg-white text-slate-900 flex items-center justify-center border border-slate-200 shadow-sm">
                <Users size={20} />
              </div>
              <h3 className="font-syne text-xl font-bold text-slate-900">Panchayats & Municipalities</h3>
              <p className="mt-3 text-sm leading-relaxed text-slate-500 font-dm-sans">
                Study the 73rd and 74th Amendment Acts. Understand how ward committees, village assemblies, and mayors perform duties.
              </p>
            </div>

            {/* Feature 3 */}
            <div className="p-8 rounded-3xl border border-slate-100 bg-slate-50 transition-all hover:shadow-md hover:bg-white">
              <div className="mb-6 h-12 w-12 rounded-2xl bg-white text-slate-900 flex items-center justify-center border border-slate-200 shadow-sm">
                <Compass size={20} />
              </div>
              <h3 className="font-syne text-xl font-bold text-slate-900">Electoral Systems</h3>
              <p className="mt-3 text-sm leading-relaxed text-slate-500 font-dm-sans">
                Learn how constituency division, representative models, voting rights, and the Election Commission of India function.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Founder's Story Section */}
      <section id="founder" className="py-24 px-6 bg-slate-50 relative overflow-hidden">
        <div className="mx-auto max-w-6xl bg-white border border-slate-200 shadow-xl rounded-[2.5rem] p-8 md:p-16 relative z-10 animate-in fade-in slide-in-from-bottom-6 duration-700">
          <div className="grid md:grid-cols-12 gap-12 items-center">
            {/* Left side: Image */}
            <div className="md:col-span-5 flex justify-center">
              <div className="relative group w-full max-w-sm aspect-[3/4] rounded-2xl overflow-hidden border border-slate-200 shadow-md bg-slate-50">
                <img
                  src="/siddharth.jpg"
                  alt="Siddharth Sharma, Founder of Swaraj"
                  className="w-full h-full object-cover grayscale hover:grayscale-0 transition-all duration-500 ease-in-out scale-100 hover:scale-105"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-slate-950/45 via-transparent to-transparent"></div>
                <div className="absolute bottom-4 left-4 right-4 bg-white/95 backdrop-blur-sm p-4 rounded-xl border border-slate-100 shadow-sm">
                  <p className="font-syne text-sm font-bold text-slate-900">Siddharth Sharma</p>
                  <p className="font-dm-sans text-[10px] text-slate-500 font-semibold uppercase tracking-wider mt-0.5">Founder of Swaraj</p>
                </div>
              </div>
            </div>

            {/* Right side: Story */}
            <div className="md:col-span-7 space-y-6">
              <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-slate-100 text-slate-600 font-dm-sans text-xs font-semibold uppercase tracking-wider">
                Founder's Message
              </div>
              <h2 className="font-syne text-3xl md:text-4xl font-bold tracking-tight text-slate-900 leading-tight">
                Democracy belongs to <br />
                <span className="text-slate-400">the next generation.</span>
              </h2>

              <div className="space-y-4 font-dm-sans text-[15px] leading-relaxed text-slate-600">
                <p>
                  I'm <strong className="text-slate-900 font-semibold">Siddharth Sharma</strong>, a student from Rajasthan and Head Boy at Jayshree Periwal International School. Like most people around me, I grew up on the outside of how decisions actually get made—close enough to feel them, never close enough to understand them.
                </p>
                <p>
                  That gap is why I built Swaraj. I kept meeting students who were sharp and curious but had been taught to see politics as something far away, something meant for adults and for later. I didn't believe that.
                </p>
                <p>
                  The system belongs to them now, not at some distant point when they finally turn eighteen. So I tried to build the thing I wish I'd had: politics explained plainly, in their own language, on their own phones, until understanding it feels ordinary instead of out of reach.
                </p>
              </div>

              <div className="pt-6 border-t border-slate-100 flex items-center justify-between">
                <div>
                  <p className="font-syne text-base font-bold text-slate-900">Siddharth Sharma</p>
                  <p className="font-dm-sans text-xs text-slate-500 font-medium">Head Boy, JPIS</p>
                </div>
                <div className="h-px w-16 bg-slate-200"></div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Download CTA */}
      <section id="download" className="bg-slate-50 py-24 px-6 border-t border-slate-100">
        <div className="mx-auto max-w-5xl bg-slate-900 rounded-[3rem] p-10 md:p-20 text-center relative overflow-hidden shadow-2xl">
          <div className="absolute top-0 right-0 p-8 opacity-10">
            <Smartphone size={200} className="text-white" />
          </div>
          <div className="absolute bottom-0 left-0 p-8 opacity-10">
            <BookOpen size={200} className="text-white" />
          </div>

          <div className="relative z-10 max-w-2xl mx-auto space-y-8">
            <h2 className="font-syne text-4xl sm:text-5xl font-bold text-white leading-tight">
              Ready to decode <br />
              <span className="text-slate-400">your democracy?</span>
            </h2>
            <p className="font-dm-sans text-slate-300 text-lg">
              Read curriculum modules, debate frameworks, and earn local community merits directly from your smartphone.
            </p>

            <div className="flex flex-col lg:flex-row items-center justify-center gap-4 pt-6">
              <a
                href="https://drive.google.com/drive/folders/1knoMacmpDaxReoOqSLzvS3o6pu8A1ovw?usp=sharing"
                target="_blank"
                rel="noopener noreferrer"
                className="w-full lg:w-auto bg-white text-slate-900 font-dm-sans text-sm font-semibold py-3.5 px-8 rounded-full hover:bg-slate-100 transition shadow-lg flex items-center justify-center gap-2"
              >
                <Download size={18} /> Download APK (Android)
              </a>

              <div className="flex flex-col sm:flex-row items-center gap-3 w-full lg:w-auto">
                <a
                  href="https://play.google.com/store/apps/details?id=app.swaraj.mobile"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="w-full sm:w-auto bg-slate-800/80 text-white border border-slate-700 font-dm-sans text-xs font-medium py-3.5 px-6 rounded-full flex items-center justify-center gap-3 hover:bg-slate-700 transition"
                >
                  <span>Google Play Store</span>
                </a>
                <div className="w-full sm:w-auto bg-slate-800/40 text-slate-400 border border-slate-800 font-dm-sans text-xs font-medium py-3.5 px-6 rounded-full flex items-center justify-center gap-3 cursor-not-allowed select-none">
                  <span>Apple App Store</span>
                  <span className="text-[9px] bg-slate-800 text-slate-500 px-2.5 py-0.5 rounded-full font-mono uppercase tracking-wider font-bold">Coming Soon</span>
                </div>
              </div>
            </div>
            <p className="font-dm-sans text-xs text-slate-500 pt-4">
              Supported Platforms: Android 8.0+ / iOS 14.0+
            </p>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-white border-t border-slate-100 py-16 px-6">
        <div className="mx-auto max-w-7xl flex flex-col md:flex-row items-start justify-between gap-12">

          <div className="space-y-4 max-w-sm">
            <div className="flex items-center gap-2.5">
              <div className="h-8 w-8 rounded-full bg-slate-900 flex items-center justify-center shadow-sm">
                <span className="text-white text-xs font-syne font-bold">S</span>
              </div>
              <span className="font-syne text-xl font-bold tracking-tight text-slate-900">SWARAJ</span>
            </div>
            <p className="font-dm-sans text-sm text-slate-500 leading-relaxed">
              Building the next generation of informed civic leadership through structured, digital-first constitutional exploration.
            </p>
          </div>

          <div className="flex flex-col gap-3 font-dm-sans text-sm font-medium text-slate-500">
            <a href="#" className="hover:text-slate-900 transition">Curriculum</a>
            <a href="#" className="hover:text-slate-900 transition">For Schools</a>
            <a href="mailto:info@swaraj.org.in" className="hover:text-slate-900 transition">Contact Support</a>
          </div>

        </div>

        <div className="mx-auto max-w-7xl mt-16 pt-8 border-t border-slate-100 flex flex-col md:flex-row justify-between items-center gap-4">
          <p className="font-dm-sans text-xs text-slate-400">
            © 2026 Siddharth Sharma. All rights reserved.
          </p>
          <div className="flex gap-6 text-slate-400 text-sm">
            <Link href="/privacy" className="hover:text-slate-900 transition">Privacy Policy</Link>
            <Link href="/terms" className="hover:text-slate-900 transition">Terms of Service</Link>
          </div>
        </div>
      </footer>
    </div>
  );
}
