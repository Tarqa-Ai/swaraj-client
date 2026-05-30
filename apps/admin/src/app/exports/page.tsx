import { ResourcePage } from "@/components/resource-page";

export default function ExportsPage() {
  return (
    <ResourcePage
      title="Exports"
      description="Operational export counts for production reporting."
      endpoint="/admin/exports"
      columns={[{ key: "generatedAt", label: "Generated" }, { key: "students", label: "Students" }, { key: "schools", label: "Schools" }, { key: "modules", label: "Modules" }, { key: "certificates", label: "Certificates" }]}
    />
  );
}
