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

    const email = "admin@fam.org";
    const existing = await User.findOne({ where: { email }});
    if (existing) {
      console.log("Admin ya existe:", email);
      process.exit(0);
    }

    const hashed = await bcrypt.hash("admin123", 10); // cambia la pass
    await User.create({
      name: "Admin FAM",
      email,
      password: hashed,
      role: "admin"
    });
    console.log("Admin creado:", email);
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

seedAdmin();
