import { ResourcePage } from "@/components/resource-page";

export default function QuizQuestionsPage() {
  return (
    <ResourcePage
      title="Quiz Questions"
      description="Manage question order, options, correct answers, and explanations."
      endpoint="/admin/quiz-questions"
      columns={[{ key: "order", label: "Order" }, { key: "promptEn", label: "Question" }, { key: "type", label: "Type" }, { key: "quizId", label: "Quiz" }]}
      fields={[
        { key: "quizId", label: "Quiz ID", required: true },
        { key: "type", label: "Type", required: true },
        { key: "promptEn", label: "Question", required: true },
        { key: "promptHi", label: "Hindi Question", required: true },
        { key: "options", label: "Options JSON", type: "json", required: true },
        { key: "answer", label: "Correct Answer JSON", type: "json", required: true },
        { key: "explanationEn", label: "Explanation", type: "textarea", required: true },
        { key: "explanationHi", label: "Hindi Explanation", type: "textarea", required: true },
        { key: "order", label: "Order", type: "number", required: true }
      ]}
    />
  );
}
