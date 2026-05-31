"use client";

import { ResourcePage } from "@/components/resource-page";

type ModuleItem = Record<string, unknown> & {
  lessons?: unknown[];
  quizzes?: unknown[];
};

export default function ModulesPage() {
  return (
    <ResourcePage<ModuleItem>
      title="Modules"
      recordLabel="module"
      addLabel="Add module"
      description="Add, remove, and modify the app learning modules. MVP should stay focused on Constitution, Government Structure, and Elections & Voting unless the scope changes."
      endpoint="/admin/modules"
      columns={[
        { key: "order", label: "Order" },
        { key: "titleEn", label: "Title" },
        { key: "estimatedMinutes", label: "Minutes" },
        { key: "lessons", label: "Lessons", render: (module) => module.lessons?.length ?? 0 },
        { key: "quizzes", label: "Quizzes", render: (module) => module.quizzes?.length ?? 0 }
      ]}
      fields={[
        { key: "slug", label: "Slug", required: true, placeholder: "constitution-of-india", help: "Lowercase URL-safe name." },
        { key: "titleEn", label: "English Title", required: true },
        { key: "titleHi", label: "Hindi Title", required: true },
        { key: "descriptionEn", label: "English Description", type: "textarea", required: true, fullWidth: true },
        { key: "descriptionHi", label: "Hindi Description", type: "textarea", required: true, fullWidth: true },
        { key: "illustrationUrl", label: "Illustration URL", placeholder: "https://example.com/module.png", help: "Optional visual used by the citizen app." },
        { key: "order", label: "Display Order", type: "number", required: true },
        { key: "estimatedMinutes", label: "Estimated Minutes", type: "number", required: true }
      ]}
    />
  );
}
