import { ResourcePage } from "@/components/resource-page";

export default function ModulesPage() {
  return <ResourcePage title="Modules" description="Learning modules, lesson counts, and completion order." endpoint="/admin/modules" columns={[{ key: "order", label: "Order" }, { key: "titleEn", label: "Title" }, { key: "titleHi", label: "Hindi Title" }, { key: "estimatedMinutes", label: "Minutes" }]} fields={[{ key: "slug", label: "Slug", required: true }, { key: "titleEn", label: "Title", required: true }, { key: "titleHi", label: "Hindi Title", required: true }, { key: "descriptionEn", label: "Description", type: "textarea", required: true }, { key: "descriptionHi", label: "Hindi Description", type: "textarea", required: true }, { key: "illustrationUrl", label: "Illustration URL" }, { key: "order", label: "Order", type: "number", required: true }, { key: "estimatedMinutes", label: "Minutes", type: "number", required: true }]} />;
}
