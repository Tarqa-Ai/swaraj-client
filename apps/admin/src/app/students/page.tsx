import { ResourcePage } from "@/components/resource-page";

export default function StudentsPage() {
  return <ResourcePage title="Students" description="Manage enrolled learners and inspect progress signals." endpoint="/admin/students" columns={[{ key: "name", label: "Name" }, { key: "phone", label: "Phone" }, { key: "grade", label: "Grade" }, { key: "politicalIq", label: "Political IQ" }, { key: "streakCount", label: "Streak" }]} />;
}
