import express from "express";
import { authMiddleware, roleMiddleware } from "../middlewares/auth.middleware.js";
import {
  createDepartamento,
  listDepartamentos,
  getDepartamento,
  updateDepartamento,
  deleteDepartamento,
  getDepartamentosPublic,
} from "../controllers/departamento.controller.js";

const router = express.Router();

// Ruta pública para obtener departamentos (requiere autenticación)
router.get("/public", authMiddleware, getDepartamentosPublic);

// Rutas administrativas
router.get("/", authMiddleware, listDepartamentos);
router.get("/:id", authMiddleware, getDepartamento);
router.post("/", authMiddleware, roleMiddleware(["admin", "fam"]), createDepartamento);
router.put("/:id", authMiddleware, roleMiddleware(["admin", "fam"]), updateDepartamento);
router.delete("/:id", authMiddleware, roleMiddleware(["admin"]), deleteDepartamento);

export default router;


