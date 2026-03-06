import express from "express";
import cors from "cors";
import authRoutes from "./routes/auth.routes.js";
import userRoutes from "./routes/user.routes.js";
import asociacionRoutes from "./routes/asociacion.routes.js";
import miembroRoutes from "./routes/miembro.routes.js";
import personalRoutes from "./routes/personal.routes.js";
import noticiaRoutes from "./routes/noticia.routes.js";
import sequelize from "./config/db.js";
import User from "./models/user.model.js";
import "./models/index.js";

const app = express();
app.use(cors());
app.use(express.json());
app.use("/public", express.static("public")); // Servir imagenes
app.use("/api/users", userRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/asociaciones", asociacionRoutes);
app.use("/api/miembros", miembroRoutes);
app.use("/api/personal", personalRoutes);
app.use("/api/noticias", noticiaRoutes);
await sequelize.sync({ alter: true }); // actualiza tablas si cambian

// Middleware de manejo de errores global
app.use((err, req, res, next) => {
    // Si el error es de Multer
    if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(400).json({
            success: false,
            message: 'El archivo es demasiado grande. El límite es 50MB.'
        });
    }

    if (err.code === 'LIMIT_UNEXPECTED_FILE') {
        return res.status(400).json({
            success: false,
            message: 'Error en la subida de archivo: campo inesperado o demasiados archivos.'
        });
    }

    // Default error
    console.error(err.stack);
    res.status(500).json({
        success: false,
        message: err.message || 'Error interno del servidor'
    });
});

export default app;
