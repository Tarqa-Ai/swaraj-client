import { ResourcePage } from "@/components/resource-page";

export default function QuizzesPage() {
  return (
    <ResourcePage
      title="Quizzes"
      description="Create quizzes and manage questions with ordering, answers, and explanations."
      endpoint="/admin/quizzes"
      columns={[{ key: "titleEn", label: "Quiz" }, { key: "titleHi", label: "Hindi Quiz" }, { key: "moduleId", label: "Module" }]}
      fields={[{ key: "moduleId", label: "Module ID", required: true }, { key: "titleEn", label: "Title", required: true }, { key: "titleHi", label: "Hindi Title", required: true }]}
    />
  );
}
