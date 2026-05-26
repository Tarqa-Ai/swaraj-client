import { ResourcePage } from "@/components/resource-page";

export default function ModulesPage() {
  return <ResourcePage title="Modules" description="Learning modules, lesson counts, and completion order." endpoint="/admin/modules" columns={[{ key: "order", label: "Order" }, { key: "titleEn", label: "Title" }, { key: "titleHi", label: "Hindi Title" }, { key: "estimatedMinutes", label: "Minutes" }]} />;
}
