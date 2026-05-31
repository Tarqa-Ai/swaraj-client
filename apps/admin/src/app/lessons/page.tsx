"use client";

import { useQuery } from "@tanstack/react-query";
import { ResourcePage } from "@/components/resource-page";
import { api } from "@/lib/api";

type ModuleItem = {
  id: string;
  order: number;
  titleEn: string;
};

type LessonItem = Record<string, unknown> & {
  moduleId?: string;
  module?: ModuleItem;
};

export default function LessonsPage() {
  const { data: modules = [] } = useQuery({
    queryKey: ["/admin/modules"],
    queryFn: () => api<ModuleItem[]>("/admin/modules")
  });
  const moduleOptions = modules.map((module) => ({
    label: `${module.order}. ${module.titleEn}`,
    value: module.id
  }));

  return (
    <ResourcePage<LessonItem>
      title="Lessons"
      recordLabel="lesson"
      addLabel="Add lesson"
      description="Add, remove, and modify lesson content inside each module. These lessons feed module progress and Political IQ."
      endpoint="/admin/lessons"
      columns={[
        { key: "order", label: "Order" },
        { key: "titleEn", label: "Title" },
        { key: "titleHi", label: "Hindi Title" },
        { key: "moduleId", label: "Module", render: (lesson) => lesson.module?.titleEn ?? lesson.moduleId ?? "" }
      ]}
      fields={[
        { key: "moduleId", label: "Module", type: "select", options: moduleOptions, required: true, help: "Choose where this lesson should appear." },
        {
          key: "type",
          label: "Lesson Type",
          type: "select",
          required: true,
          options: [
            { label: "Text", value: "TEXT" },
            { label: "Image", value: "IMAGE" },
            { label: "Infographic", value: "INFOGRAPHIC" }
          ]
        },
        { key: "titleEn", label: "English Title", required: true },
        { key: "titleHi", label: "Hindi Title", required: true },
        { key: "bodyEn", label: "English Lesson Body", type: "textarea", required: true, fullWidth: true },
        { key: "bodyHi", label: "Hindi Lesson Body", type: "textarea", required: true, fullWidth: true },
        { key: "mediaUrl", label: "Media URL", placeholder: "https://example.com/image.png", help: "Optional image or infographic URL." },
        { key: "order", label: "Display Order", type: "number", required: true }
      ]}
    />
  );
}
