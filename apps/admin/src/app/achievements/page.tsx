import { ResourcePage } from "@/components/resource-page";

export default function AchievementsPage() {
  return (
    <ResourcePage
      title="Achievements"
      description="Badges awarded automatically when students hit civic milestones."
      endpoint="/admin/achievements"
      columns={[
        { key: "code", label: "Code" },
        { key: "titleEn", label: "Title (EN)" },
        { key: "titleHi", label: "Title (HI)" },
        { key: "icon", label: "Icon" }
      ]}
      fields={[
        { key: "code", label: "Code (UPPER_SNAKE)", required: true },
        { key: "titleEn", label: "Title (English)", required: true },
        { key: "titleHi", label: "Title (Hindi)", required: true },
        { key: "descriptionEn", label: "Description (English)", required: true, type: "textarea" },
        { key: "descriptionHi", label: "Description (Hindi)", required: true, type: "textarea" },
        { key: "icon", label: "Icon name", required: true }
      ]}
    />
  );
}
