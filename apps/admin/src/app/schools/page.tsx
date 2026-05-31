import { ResourcePage } from "@/components/resource-page";

export default function SchoolsPage() {
  return (
    <ResourcePage
      title="Schools"
      description="School directory used by citizens during onboarding."
      endpoint="/admin/schools"
      columns={[
        { key: "name", label: "School" },
        { key: "district", label: "District" },
        { key: "state", label: "State" },
        { key: "code", label: "Code" }
      ]}
      fields={[
        { key: "name", label: "School Name", required: true },
        { key: "district", label: "District", required: true },
        { key: "state", label: "State", required: true, placeholder: "Rajasthan" },
        { key: "code", label: "School Code", required: true, placeholder: "RJ-JAI-001", help: "Unique short code for this school." }
      ]}
    />
  );
}
