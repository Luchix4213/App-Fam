import express from "express";
import {
    createPersonal,
    listPersonal,
    getPersonal,
    updatePersonal,
    deletePersonal
} from "../controllers/personal.controller.js";
import { authMiddleware, roleMiddleware } from "../middlewares/auth.middleware.js";
import { upload } from "../middlewares/upload.middleware.js";

const router = express.Router();

// Rutas (pueden ser publicas las list y get pero las dejo libres por simplicidad del directorio)
router.get("/", listPersonal);
router.get("/:id", getPersonal);

// Rutas protegidas para admins
router.post("/", authMiddleware, roleMiddleware(["admin", "fam"]), upload('personal').single("foto"), createPersonal);
router.put("/:id", authMiddleware, roleMiddleware(["admin", "fam"]), upload('personal').single("foto"), updatePersonal);
router.delete("/:id", authMiddleware, roleMiddleware(["admin"]), deletePersonal);

export default router;
