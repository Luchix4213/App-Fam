import { Router } from "express";
import {
    createNoticia,
    listNoticias,
    updateNoticia,
    deleteNoticia
} from "../controllers/noticia.controller.js";
import { authMiddleware, roleMiddleware } from "../middlewares/auth.middleware.js";
import { upload } from "../middlewares/upload.middleware.js";

const router = Router();

// Endpoint público/autenticado para listar noticias
router.get("/", listNoticias);

// Administracion
router.post("/", authMiddleware, roleMiddleware(["admin", "fam"]), upload('noticias').single("foto"), createNoticia);
router.put("/:id", authMiddleware, roleMiddleware(["admin", "fam"]), upload('noticias').single("foto"), updateNoticia);
router.delete("/:id", authMiddleware, roleMiddleware(["admin"]), deleteNoticia);

export default router;
