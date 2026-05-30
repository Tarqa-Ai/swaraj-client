import { ResourcePage } from "@/components/resource-page";

export default function LeaderboardPage() {
  return <ResourcePage title="Leaderboard" description="Top student rankings across schools." endpoint="/admin/leaderboard" columns={[{ key: "name", label: "Student" }, { key: "grade", label: "Grade" }, { key: "politicalIq", label: "Political IQ" }, { key: "streakCount", label: "Streak" }]} />;
}
