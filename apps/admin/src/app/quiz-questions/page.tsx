"use client";

import { useQuery } from "@tanstack/react-query";
import { ResourcePage } from "@/components/resource-page";
import { api } from "@/lib/api";

type QuizItem = {
  id: string;
  titleEn: string;
  module?: {
    titleEn?: string;
  };
};

type QuizQuestionItem = Record<string, unknown> & {
  quizId?: string;
  quiz?: QuizItem;
};

const optionExample = `[
  "Option A",
  "Option B",
  "Option C",
  "Option D"
]`;

export default function QuizQuestionsPage() {
  const { data: quizzes = [] } = useQuery({
    queryKey: ["/admin/quizzes"],
    queryFn: () => api<QuizItem[]>("/admin/quizzes")
  });
  const quizOptions = quizzes.map((quiz) => ({
    label: quiz.module?.titleEn ? `${quiz.module.titleEn} - ${quiz.titleEn}` : quiz.titleEn,
    value: quiz.id
  }));

  return (
    <ResourcePage<QuizQuestionItem>
      title="Quiz Questions"
      recordLabel="question"
      addLabel="Add question"
      description="Update the exact quiz questions, answer choices, correct answers, and instant explanations shown in the citizen app."
      endpoint="/admin/quiz-questions"
      columns={[
        { key: "order", label: "Order" },
        { key: "promptEn", label: "Question" },
        { key: "type", label: "Type" },
        { key: "quizId", label: "Quiz", render: (question) => question.quiz?.titleEn ?? question.quizId ?? "" }
      ]}
      fields={[
        { key: "quizId", label: "Quiz", type: "select", options: quizOptions, required: true },
        {
          key: "type",
          label: "Question Type",
          type: "select",
          required: true,
          options: [
            { label: "Multiple Choice", value: "MCQ" },
            { label: "True / False", value: "TRUE_FALSE" },
            { label: "Match the Column", value: "MATCH_COLUMN" }
          ]
        },
        { key: "promptEn", label: "English Question", required: true, fullWidth: true },
        { key: "promptHi", label: "Hindi Question", required: true, fullWidth: true },
        {
          key: "options",
          label: "Answer Choices",
          type: "json",
          required: true,
          fullWidth: true,
          placeholder: optionExample,
          help: "For MCQ and True/False, enter a JSON list of choices. Match the Column can use structured JSON."
        },
        {
          key: "answer",
          label: "Correct Answer",
          type: "json",
          required: true,
          fullWidth: true,
          placeholder: `"Option A"`,
          help: "Use a JSON string for MCQ/True-False, for example \"True\". Use an object for Match the Column."
        },
        { key: "explanationEn", label: "English Explanation", type: "textarea", required: true, fullWidth: true },
        { key: "explanationHi", label: "Hindi Explanation", type: "textarea", required: true, fullWidth: true },
        { key: "order", label: "Display Order", type: "number", required: true }
      ]}
    />
  );
}
