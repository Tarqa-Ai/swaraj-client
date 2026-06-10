"use client";

import { ResourcePage } from "@/components/resource-page";

const challengeQuestionsExample = `[
  {
    "id": "dc-1",
    "promptEn": "Question in English?",
    "promptHi": "Question in Hindi?",
    "options": ["A", "B", "C", "D"],
    "answer": "A",
    "explanationEn": "Short explanation.",
    "explanationHi": "Short Hindi explanation."
  },
  {
    "id": "dc-2",
    "promptEn": "Second question?",
    "promptHi": "Second Hindi question?",
    "options": ["True", "False"],
    "answer": "True",
    "explanationEn": "Short explanation.",
    "explanationHi": "Short Hindi explanation."
  },
  {
    "id": "dc-3",
    "promptEn": "Third question?",
    "promptHi": "Third Hindi question?",
    "options": ["A", "B", "C", "D"],
    "answer": "B",
    "explanationEn": "Short explanation.",
    "explanationHi": "Short Hindi explanation."
  }
]`;
// nice
export default function ChallengesPage() {
  return (
    <ResourcePage
      title="Daily Challenges"
      recordLabel="challenge"
      addLabel="Add challenge"
      description="Schedule the three-question daily challenge used by the app. Keep one date-based challenge per day."
      endpoint="/admin/daily-challenges"
      columns={[
        { key: "challengeDate", label: "Date" },
        { key: "category", label: "Category" },
        { key: "questions", label: "Questions", render: (challenge) => Array.isArray(challenge.questions) ? challenge.questions.length : 0 }
      ]}
      fields={[
        { key: "challengeDate", label: "Date", type: "date", required: true },
        {
          key: "category",
          label: "Category",
          type: "select",
          required: true,
          options: [
            { label: "India Today", value: "INDIA_TODAY" },
            { label: "Parliament Watch", value: "PARLIAMENT_WATCH" },
            { label: "Civic Awareness", value: "CIVIC_AWARENESS" }
          ]
        },
        {
          key: "questions",
          label: "Three Questions",
          type: "json",
          required: true,
          fullWidth: true,
          placeholder: challengeQuestionsExample,
          help: "Must contain exactly 3 questions. Each answer must match one of its options."
        }
      ]}
    />
  );
}
