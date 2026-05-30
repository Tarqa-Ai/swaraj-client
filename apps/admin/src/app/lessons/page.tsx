import { ResourcePage } from "@/components/resource-page";

export default function LessonsPage() {
  return (
    <ResourcePage
      title="Lessons"
      description="Create, edit, order, and retire module lessons."
      endpoint="/admin/lessons"
      columns={[{ key: "order", label: "Order" }, { key: "titleEn", label: "Title" }, { key: "titleHi", label: "Hindi Title" }, { key: "moduleId", label: "Module" }]}
      fields={[
        { key: "moduleId", label: "Module ID", required: true },
        { key: "type", label: "Type", required: true },
        { key: "titleEn", label: "Title", required: true },
        { key: "titleHi", label: "Hindi Title", required: true },
        { key: "bodyEn", label: "Body", type: "textarea", required: true },
        { key: "bodyHi", label: "Hindi Body", type: "textarea", required: true },
        { key: "mediaUrl", label: "Media URL" },
        { key: "order", label: "Order", type: "number", required: true }
      ]}
    />
  );
}
