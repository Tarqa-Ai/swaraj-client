import { ResourcePage } from "@/components/resource-page";

export default function StudentsPage() {
  return (
    <ResourcePage
      title="Students"
      description="Enrolled learners. Delete removes the student and invalidates their active session."
      endpoint="/admin/students"
      columns={[
        { key: "name", label: "Name" },
        { key: "phone", label: "Phone" },
        { key: "grade", label: "Grade" },
        { key: "politicalIq", label: "Political IQ" },
        { key: "streakCount", label: "Streak" }
      ]}
      deletable
    />
  );
}
