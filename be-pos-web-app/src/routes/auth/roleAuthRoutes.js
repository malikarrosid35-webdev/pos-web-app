import express from "express";
import refreshToken from "../../controllers/auth/refreshToken.js";
import logoutUser from "../../controllers/auth/logoutUser.js";
import { authenticate, authorize } from "../../middlewares/auth.middleware.js";
import {
  getAllUser,
  updateUserById,
  registerUser,
} from "../../controllers/auth/index.js";
import {
  listMySessions,
  revokeMySession,
} from "../../controllers/auth/sessionsUser.js";

const router = express.Router();

router.post("/auth/refresh", refreshToken);
router.post("/auth/logout", authenticate, logoutUser);

router.get("/users", authenticate, authorize(["owner", "admin"]), getAllUser);

// Owner-only. Lives under a role prefix (not /api/auth) because the owner's
// auth cookie is path-scoped to /api/owner, so it is never sent to /api/auth.
router.post("/users", authenticate, authorize(["owner"]), registerUser);

router.patch(
  "/users/:id_user",
  authenticate,
  authorize(["owner", "admin"]),
  updateUserById,
);

router.get("/auth/me/sessions", authenticate, authorize(["owner"]), listMySessions);
router.delete("/auth/me/sessions/:session_id", authenticate, authorize(["owner"]), revokeMySession);

export default router;
