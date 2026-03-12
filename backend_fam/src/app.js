import express from "express";
import cors from "cors";
import helmet from "helmet"; // Seguridad HTTP
import rateLimit from "express-rate-limit"; // Limite de peticiones

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

// Confiar en el proxy de Render para que express-rate-limit funcione sin error
app.set('trust proxy', 1);

app.use(helmet({ crossOriginResourcePolicy: false })); // Permite cargar imagenes desde flutter
app.use(cors());
app.use(express.json());
app.use("/public", express.static("public")); // Servir imagenes
// Configuraciones de Rate Limiting
const globalApiLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutos
    max: 300, // 300 peticiones por IP cada 15 min
    message: { success: false, message: "Demasiadas peticiones desde esta IP, intente de nuevo en 15 minutos." }
});

const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutos
    max: 10, // Solo 10 intentos de login/registro por IP cada 15 min
    message: { success: false, message: "Demasiados intentos de inicio de sesión. Intente nuevamente en 15 minutos." }
});

// Aplicar Rate Limiting a las rutas Críticas
app.use("/api/auth/login", authLimiter);
app.use("/api/auth/register", authLimiter);

// Aplicar Global Rate Limiting a todo lo que esté bajo /api/
app.use("/api/", globalApiLimiter);

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
