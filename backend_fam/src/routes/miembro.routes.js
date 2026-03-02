import express from "express";
import { authMiddleware, roleMiddleware } from "../middlewares/auth.middleware.js";
import { upload } from "../middlewares/upload.middleware.js";
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
router.get("/asociacion/:asociacionId", getMiembrosByAsociacion);

// Rutas administrativas
router.get("/", authMiddleware, listMiembros);
router.get("/:id", authMiddleware, getMiembro);
router.post("/", authMiddleware, roleMiddleware(["admin", "fam"]), upload('miembros').single('foto'), createMiembro);
router.put("/:id", authMiddleware, roleMiddleware(["admin", "fam"]), upload('miembros').single('foto'), updateMiembro);
router.delete("/:id", authMiddleware, roleMiddleware(["admin"]), deleteMiembro);

export default router;


