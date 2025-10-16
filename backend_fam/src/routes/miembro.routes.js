import express from "express";
import { authMiddleware, roleMiddleware } from "../middlewares/auth.middleware.js";
import {
  createMiembro,
  listMiembros,
  getMiembro,
  updateMiembro,
  deleteMiembro,
  getMiembrosByAsociacion,
} from "../controllers/miembro.controller.js";

const router = express.Router();

// Ruta pública para obtener miembros por asociación
router.get("/asociacion/:asociacionId", authMiddleware, getMiembrosByAsociacion);

// Rutas administrativas
router.get("/", authMiddleware, listMiembros);
router.get("/:id", authMiddleware, getMiembro);
router.post("/", authMiddleware, roleMiddleware(["admin", "fam"]), createMiembro);
router.put("/:id", authMiddleware, roleMiddleware(["admin", "fam"]), updateMiembro);
router.delete("/:id", authMiddleware, roleMiddleware(["admin"]), deleteMiembro);

export default router;


