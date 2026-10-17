import express from "express";
const router = express.Router();
import { loginLimiter, loginUser } from "../../controllers/auth/index.js";

// User creation is no longer public: see POST /api/owner/users (roleAuthRoutes.js).
router.post("/login", loginLimiter, loginUser);

export default router;
