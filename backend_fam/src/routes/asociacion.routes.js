import express from "express";
import { authMiddleware, roleMiddleware } from "../middlewares/auth.middleware.js";
import { upload } from "../middlewares/upload.middleware.js";
import {
  createAsociacion,
  listAsociaciones,
  getAsociacion,
  updateAsociacion,
  deleteAsociacion,
} from "../controllers/asociacion.controller.js";

const router = express.Router();

// Rutas administrativas
router.get("/", listAsociaciones);
router.get("/:id", getAsociacion);
router.post("/", authMiddleware, roleMiddleware(["admin", "fam"]), upload('asociaciones').single('foto'), createAsociacion);
router.put("/:id", authMiddleware, roleMiddleware(["admin", "fam"]), upload('asociaciones').single('foto'), updateAsociacion);
router.delete("/:id", authMiddleware, roleMiddleware(["admin"]), deleteAsociacion);

export default router;


