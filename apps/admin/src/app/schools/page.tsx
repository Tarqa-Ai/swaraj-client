import { ResourcePage } from "@/components/resource-page";

export default function SchoolsPage() {
  return <ResourcePage title="Schools" description="Rajasthan school directory for student onboarding." endpoint="/admin/schools" columns={[{ key: "name", label: "School" }, { key: "district", label: "District" }, { key: "state", label: "State" }, { key: "code", label: "Code" }]} />;
}
