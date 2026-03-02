import express from "express";
import { register, login, registerFamUser, googleLogin } from "../controllers/auth.controller.js";
import { authMiddleware, roleMiddleware } from "../middlewares/auth.middleware.js";

const router = express.Router();

router.post("/register", register);
router.post("/login", login);
router.post("/google-login", googleLogin);

// Solo administradores pueden registrar usuarios FAM
router.post("/register-fam", authMiddleware, roleMiddleware(["admin"]), registerFamUser);

export default router;
