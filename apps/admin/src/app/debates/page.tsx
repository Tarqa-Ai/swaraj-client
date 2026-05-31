import { ResourcePage } from "@/components/resource-page";

export default function DebatesPage() {
  return (
    <ResourcePage
      title="Debates"
      description="Manage the active civic reflection topic shown in the citizen app."
      endpoint="/admin/debates"
      columns={[
        { key: "topicEn", label: "Topic" },
        { key: "topicHi", label: "Hindi Topic" },
        { key: "isActive", label: "Active" }
      ]}
      fields={[
        { key: "topicEn", label: "English Topic", required: true, fullWidth: true },
        { key: "topicHi", label: "Hindi Topic", required: true, fullWidth: true },
        { key: "forSummaryEn", label: "For Summary", type: "textarea", required: true, fullWidth: true },
        { key: "forSummaryHi", label: "Hindi For Summary", type: "textarea", required: true, fullWidth: true },
        { key: "againstSummaryEn", label: "Against Summary", type: "textarea", required: true, fullWidth: true },
        { key: "againstSummaryHi", label: "Hindi Against Summary", type: "textarea", required: true, fullWidth: true },
        { key: "isActive", label: "Make This Active", type: "boolean", help: "Only one debate can be active at a time." }
      ]}
    />
  );
}
