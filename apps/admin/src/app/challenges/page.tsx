import { ResourcePage } from "@/components/resource-page";

export default function ChallengesPage() {
  return <ResourcePage title="Daily Challenges" description="Three-question civic challenges with rotating categories." endpoint="/admin/daily-challenges" columns={[{ key: "challengeDate", label: "Date" }, { key: "category", label: "Category" }]} fields={[{ key: "challengeDate", label: "Date", type: "date", required: true }, { key: "category", label: "Category", required: true }, { key: "questions", label: "Questions JSON", type: "json", required: true }]} />;
}
