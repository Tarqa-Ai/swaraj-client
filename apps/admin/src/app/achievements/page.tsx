import { ResourcePage } from "@/components/resource-page";

export default function AchievementsPage() {
  return (
    <ResourcePage
      title="Achievements"
      description="Badge definitions awarded automatically from citizen progress."
      endpoint="/admin/achievements"
      columns={[
        { key: "code", label: "Code" },
        { key: "titleEn", label: "Title" },
        { key: "titleHi", label: "Hindi Title" },
        { key: "icon", label: "Icon" }
      ]}
      fields={[
        { key: "code", label: "Code", required: true, placeholder: "CIVIC_HERO", help: "Uppercase letters and underscores only." },
        { key: "titleEn", label: "English Title", required: true },
        { key: "titleHi", label: "Hindi Title", required: true },
        { key: "descriptionEn", label: "English Description", required: true, type: "textarea", fullWidth: true },
        { key: "descriptionHi", label: "Hindi Description", required: true, type: "textarea", fullWidth: true },
        {
          key: "icon",
          label: "Icon",
          required: true,
          type: "select",
          options: [
            { label: "Award", value: "award" },
            { label: "Book Open", value: "book-open" },
            { label: "Messages", value: "messages-square" },
            { label: "Shield", value: "shield" },
            { label: "Star", value: "star" }
          ]
        }
      ]}
    />
  );
}
