// src/seed/seedAdmin.js
import dotenv from "dotenv";
dotenv.config();

import sequelize from "../config/db.js";
import User from "../models/user.model.js";
import bcrypt from "bcryptjs";

async function seedAdmin() {
  try {
    await sequelize.authenticate();
    await sequelize.sync(); // asegura tablas creadas

    // Admin
    const adminEmail = "admin@fam.org";
    const existingAdmin = await User.findOne({ where: { email: adminEmail }});
    if (existingAdmin) {
      console.log("Admin ya existe:", adminEmail);
    } else {
      const adminHashed = await bcrypt.hash("admin123", 10); // cambia la pass
      await User.create({
        name: "Admin FAM",
        email: adminEmail,
        password: adminHashed,
        role: "admin"
      });
      console.log("Admin creado:", adminEmail);
    }

    // Usuario genérico público (solo rol usuario)
    const guestEmail = "usuario12345@gmail.com";
    const existingGuest = await User.findOne({ where: { email: guestEmail }});
    if (existingGuest) {
      console.log("Usuario genérico ya existe:", guestEmail);
    } else {
      const guestHashed = await bcrypt.hash("usuario12345", 10);
      await User.create({
        name: "Usuario Genérico",
        email: guestEmail,
        password: guestHashed,
        role: "usuario",
      });
      console.log("Usuario genérico creado:", guestEmail);
    }

    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

seedAdmin();
