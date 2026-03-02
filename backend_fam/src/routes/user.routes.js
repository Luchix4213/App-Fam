// src/routes/user.routes.js
import express from "express";
import { authMiddleware, roleMiddleware } from "../middlewares/auth.middleware.js"; // <--- Importa esto
import { getAllUsers, deleteUser, getUserProfile, createUser, updateUser } from "../controllers/user.controller.js"; // si no lo tienes, crea funciones de ejemplo

const router = express.Router();

// Obtener perfil del usuario logueado
router.get("/profile", authMiddleware, getUserProfile);

// Solo admins pueden ver todos los usuarios y crear
router.get("/", authMiddleware, roleMiddleware(["admin"]), getAllUsers);
router.post("/", authMiddleware, roleMiddleware(["admin"]), createUser);

// Solo admins pueden eliminar y editar usuarios
router.delete("/:id", authMiddleware, roleMiddleware(["admin"]), deleteUser);
router.put("/:id", authMiddleware, roleMiddleware(["admin"]), updateUser);


export default router;
