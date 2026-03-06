import app from "./app.js";
import dotenv from "dotenv";
import sequelize from "./config/db.js";
import User from "./models/user.model.js";
import bcrypt from "bcryptjs";
dotenv.config();

const PORT = process.env.PORT || 4000;

// RUTA TEMPORAL PARA CREAR AL ADMIN EN PRODUCCION
app.get("/api/seed-admin", async (req, res) => {
    try {
        const adminEmail = "admin@fam.org";
        const existingAdmin = await User.findOne({ where: { email: adminEmail } });
        if (existingAdmin) {
            return res.json({ message: "Admin ya existe", email: adminEmail });
        }

        const adminHashed = await bcrypt.hash("admin123", 10);
        await User.create({
            name: "Admin FAM",
            email: adminEmail,
            password: adminHashed,
            role: "admin",
            estado: "activo"
        });

        return res.json({ message: "Admin creado correctamente", email: adminEmail });
    } catch (err) {
        return res.status(500).json({ error: err.message });
    }
});

app.listen(PORT, () => console.log(`Servidor corriendo en puerto ${PORT}`));
