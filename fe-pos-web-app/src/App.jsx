import { lazy, Suspense } from "react";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Navigate,
} from "react-router-dom";
import OfflineBanner from "./shared/components/OfflineBanner.jsx";

const LoginPage = lazy(() => import("./auth/LoginPage.jsx"));
const AdminRoutes = lazy(() => import("./routes/AdminRoutes.jsx"));
const KasirRoutes = lazy(() => import("./routes/KasirRoutes.jsx"));
const OwnerRoutes = lazy(() => import("./routes/OwnerRoutes.jsx"));

function App() {
  return (
    <Router>
      <OfflineBanner />
      <Suspense
        fallback={
          <div className="p-6 text-center text-gray-500">Memuat…</div>
        }
      >
        <Routes>
          <Route path="/login" element={<LoginPage />} />

          <Route path="/admin/*" element={<AdminRoutes />} />

          <Route path="/kasir/*" element={<KasirRoutes />} />

          <Route path="/owner/*" element={<OwnerRoutes />} />

          <Route path="/" element={<Navigate to="/login" replace />} />

          <Route path="*" element={<Navigate to="/login" replace />} />
        </Routes>
      </Suspense>
    </Router>
  );
}

export default App;