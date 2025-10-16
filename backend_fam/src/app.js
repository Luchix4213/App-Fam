import express from "express";
import cors from "cors";
import authRoutes from "./routes/auth.routes.js";
import userRoutes from "./routes/user.routes.js";
import departamentoRoutes from "./routes/departamento.routes.js";
import asociacionRoutes from "./routes/asociacion.routes.js";
import miembroRoutes from "./routes/miembro.routes.js";
import sequelize from "./config/db.js";
import User from "./models/user.model.js";
import "./models/index.js";

const app = express();
app.use(cors());
app.use(express.json());
app.use("/api/users", userRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/departamentos", departamentoRoutes);
app.use("/api/asociaciones", asociacionRoutes);
app.use("/api/miembros", miembroRoutes);
await sequelize.sync(); // crea tablas si no existen

export default app;
