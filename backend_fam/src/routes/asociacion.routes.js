import express from "express";
import { authMiddleware, roleMiddleware } from "../middlewares/auth.middleware.js";
import {
  createAsociacion,
  listAsociaciones,
  getAsociacion,
  updateAsociacion,
  deleteAsociacion,
  getAsociacionesByDepartamento,
} from "../controllers/asociacion.controller.js";

const router = express.Router();

// Ruta pública para obtener asociaciones por departamento
router.get("/departamento/:departamentoId", authMiddleware, getAsociacionesByDepartamento);

// Rutas administrativas
router.get("/", authMiddleware, listAsociaciones);
router.get("/:id", authMiddleware, getAsociacion);
router.post("/", authMiddleware, roleMiddleware(["admin", "fam"]), createAsociacion);
router.put("/:id", authMiddleware, roleMiddleware(["admin", "fam"]), updateAsociacion);
router.delete("/:id", authMiddleware, roleMiddleware(["admin"]), deleteAsociacion);

export default router;


