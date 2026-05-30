import { ResourcePage } from "@/components/resource-page";

export default function DebatesPage() {
  return <ResourcePage title="Debates" description="Manage active civic reflection topics." endpoint="/admin/debates" columns={[{ key: "topicEn", label: "Topic" }, { key: "topicHi", label: "Hindi Topic" }, { key: "isActive", label: "Active" }]} fields={[{ key: "topicEn", label: "Topic", required: true }, { key: "topicHi", label: "Hindi Topic", required: true }, { key: "forSummaryEn", label: "For Summary", type: "textarea", required: true }, { key: "forSummaryHi", label: "Hindi For Summary", type: "textarea", required: true }, { key: "againstSummaryEn", label: "Against Summary", type: "textarea", required: true }, { key: "againstSummaryHi", label: "Hindi Against Summary", type: "textarea", required: true }, { key: "isActive", label: "Active", type: "boolean" }]} />;
}
