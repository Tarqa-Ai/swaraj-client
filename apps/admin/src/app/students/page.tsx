"use client";

import { useQuery } from "@tanstack/react-query";
import { ResourcePage } from "@/components/resource-page";
import { api } from "@/lib/api";

type SchoolItem = {
  id: string;
  name: string;
  district?: string;
};

type CitizenItem = Record<string, unknown> & {
  id: string;
  name?: string | null;
  phone: string;
  grade?: number | null;
  language?: "en" | "hi";
  schoolId?: string | null;
  school?: SchoolItem | null;
  politicalIq: number;
  streakCount: number;
};

type SchoolResponse = SchoolItem[] | { items: SchoolItem[] };

export default function CitizensPage() {
  const { data: schoolsData } = useQuery({
    queryKey: ["/admin/schools"],
    queryFn: () => api<SchoolResponse>("/admin/schools")
  });

  const schools = Array.isArray(schoolsData) ? schoolsData : schoolsData?.items ?? [];
  const schoolOptions = schools.map((school) => ({
    label: school.district ? `${school.name} - ${school.district}` : school.name,
    value: school.id
  }));

  return (
    <ResourcePage<CitizenItem>
      title="Citizens"
      recordLabel="citizen"
      description="View citizen app users, correct onboarding details, reset progress inputs, and remove inactive accounts when needed."
      endpoint="/admin/students"
      createEnabled={false}
      columns={[
        { key: "name", label: "Name", render: (user) => user.name ?? "Unnamed citizen" },
        { key: "phone", label: "Phone" },
        { key: "grade", label: "Grade", render: (user) => (user.grade ? `Class ${user.grade}` : "") },
        { key: "schoolId", label: "School", render: (user) => user.school?.name ?? user.schoolId ?? "" },
        { key: "politicalIq", label: "Political IQ" },
        { key: "streakCount", label: "Streak" }
      ]}
      fields={[
        { key: "name", label: "Name", placeholder: "Citizen full name" },
        { key: "phone", label: "Phone", placeholder: "10 digit phone" },
        {
          key: "grade",
          label: "Grade",
          type: "select",
          options: [
            { label: "Class 9", value: "9" },
            { label: "Class 10", value: "10" },
            { label: "Class 11", value: "11" },
            { label: "Class 12", value: "12" }
          ]
        },
        {
          key: "language",
          label: "Language",
          type: "select",
          options: [
            { label: "English", value: "en" },
            { label: "Hindi", value: "hi" }
          ]
        },
        { key: "schoolId", label: "School", type: "select", options: schoolOptions, help: "School list is still maintained under the schools route for onboarding lookup." },
        { key: "politicalIq", label: "Political IQ", type: "number" },
        { key: "streakCount", label: "Streak Days", type: "number" }
      ]}
      deletable
      emptyTitle="No citizens yet"
      emptyBody="Citizens will appear here after mobile onboarding."
    />
  );
}
