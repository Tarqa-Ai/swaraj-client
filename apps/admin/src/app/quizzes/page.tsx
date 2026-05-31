"use client";

import { useQuery } from "@tanstack/react-query";
import { ResourcePage } from "@/components/resource-page";
import { api } from "@/lib/api";

type ModuleItem = {
  id: string;
  order: number;
  titleEn: string;
};

type QuizItem = Record<string, unknown> & {
  moduleId?: string;
  module?: ModuleItem;
};

export default function QuizzesPage() {
  const { data: modules = [] } = useQuery({
    queryKey: ["/admin/modules"],
    queryFn: () => api<ModuleItem[]>("/admin/modules")
  });
  const moduleOptions = modules.map((module) => ({
    label: `${module.order}. ${module.titleEn}`,
    value: module.id
  }));

  return (
    <ResourcePage<QuizItem>
      title="Quizzes"
      description="Create one short quiz for each module."
      endpoint="/admin/quizzes"
      columns={[
        { key: "titleEn", label: "Quiz" },
        { key: "titleHi", label: "Hindi Quiz" },
        { key: "moduleId", label: "Module", render: (quiz) => quiz.module?.titleEn ?? quiz.moduleId ?? "" }
      ]}
      fields={[
        { key: "moduleId", label: "Module", type: "select", options: moduleOptions, required: true },
        { key: "titleEn", label: "English Title", required: true },
        { key: "titleHi", label: "Hindi Title", required: true }
      ]}
    />
  );
}
