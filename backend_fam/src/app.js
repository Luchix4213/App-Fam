import express from "express";
import cors from "cors";
import userRoutes from "./routes/user.routes.js";
import sequelize from "./config/db.js";
import User from "./models/user.model.js";

const app = express();
app.use(cors());
app.use(express.json());
app.use("/api/users", userRoutes);
app.use("/api/auth", authRoutes);
await sequelize.sync(); // crea tablas si no existen

export default app;
