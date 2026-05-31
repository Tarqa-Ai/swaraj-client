import { ResourcePage } from "@/components/resource-page";

export default function ModulesPage() {
  return (
    <ResourcePage
      title="Modules"
      description="Manage the three MVP learning modules and their display order."
      endpoint="/admin/modules"
      columns={[
        { key: "order", label: "Order" },
        { key: "titleEn", label: "Title" },
        { key: "titleHi", label: "Hindi Title" },
        { key: "estimatedMinutes", label: "Minutes" }
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
