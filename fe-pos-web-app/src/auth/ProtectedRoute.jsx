import { Navigate } from "react-router-dom";
import { useAuthStore } from "../stores/useAuthStore.js";

export default function ProtectedRoute({ role, children }) {
  const { role: currentRole } = useAuthStore();

  if (!currentRole) return <Navigate to="/login" replace />;
  if (currentRole !== role) return <Navigate to="/login" replace />;

  return children;
}