// src/routes/user.routes.js
import express from "express";
import { authMiddleware, roleMiddleware } from "../middlewares/auth.middleware.js"; // <--- Importa esto
import { getAllUsers, deleteUser, getUserProfile } from "../controllers/user.controller.js"; // si no lo tienes, crea funciones de ejemplo

const router = express.Router();

// Obtener perfil del usuario logueado
router.get("/profile", authMiddleware, getUserProfile);

// Solo admins pueden ver todos los usuarios
router.get("/", authMiddleware, roleMiddleware(["admin"]), getAllUsers);

// Solo admins pueden eliminar usuarios
router.delete("/:id", authMiddleware, roleMiddleware(["admin"]), deleteUser);


export default router;
