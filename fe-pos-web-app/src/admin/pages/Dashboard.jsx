import Header from "../components/Header.jsx";
import DashboardCards from "../components/DashboardCards.jsx";

export default function Dashboard() {
  return (
    <div className="flex-1">
      <Header />
      <DashboardCards />
    </div>
  );
}