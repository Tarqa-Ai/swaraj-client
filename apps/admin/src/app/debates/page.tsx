import { ResourcePage } from "@/components/resource-page";

export default function DebatesPage() {
  return <ResourcePage title="Debates" description="Manage active civic reflection topics." endpoint="/admin/debates" columns={[{ key: "topicEn", label: "Topic" }, { key: "topicHi", label: "Hindi Topic" }, { key: "isActive", label: "Active" }]} />;
}
