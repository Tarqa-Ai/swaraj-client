import { ResourcePage } from "@/components/resource-page";

export default function ChallengesPage() {
  return <ResourcePage title="Daily Challenges" description="Three-question civic challenges with rotating categories." endpoint="/admin/daily-challenges" columns={[{ key: "challengeDate", label: "Date" }, { key: "category", label: "Category" }]} />;
}
