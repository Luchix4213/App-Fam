import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken"; // src/controllers/user.controller.js
import User from "../models/user.model.js";
import dotenv from "dotenv";
dotenv.config();


export const getAllUsers = async (req, res) => {
  try {
    const users = await User.findAll({
      attributes: ['id', 'name', 'email', 'role', 'estado'] // no mandar password
    });
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const getUserProfile = async (req, res) => {
  try {
    const userId = req.user.id; // viene del middleware de auth
    const user = await User.findByPk(userId, {
      attributes: ['id', 'name', 'email', 'role', 'estado'] // no mandar password
    });

    if (!user) {
      return res.status(404).json({ error: "Usuario no encontrado" });
    }

    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findByPk(req.params.id);
    if (!user) return res.status(404).json({ message: "Usuario no encontrado" });

    // No eliminar al propio admin logueado (opcional)
    // if (user.id === req.userId) return res.status(400).json({ message: "No puedes eliminarte a ti mismo" });

    await user.destroy();
    res.json({ message: "Usuario eliminado" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const createUser = async (req, res) => {
  try {
    const { name, email, password, role, estado } = req.body;
    if (!name || !email || !password || !role) {
      return res.status(400).json({ message: "Todos los campos son requeridos" });
    }

    // Check existing
    const existing = await User.findOne({ where: { email } });
    if (existing) return res.status(400).json({ message: "Email ya registrado" });

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await User.create({ name, email, password: hashedPassword, role, estado: estado || 'activo' });

    res.status(201).json({ message: "Usuario creado", user });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};

export const updateUser = async (req, res) => {
  try {
    const { name, email, role, password, estado } = req.body;
    const user = await User.findByPk(req.params.id);
    if (!user) return res.status(404).json({ message: "Usuario no encontrado" });

    user.name = name || user.name;
    user.email = email || user.email;
    user.role = role || user.role;
    if (estado) user.estado = estado;
    if (password) {
      user.password = await bcrypt.hash(password, 10);
    }

    await user.save();
    res.json({ message: "Usuario actualizado", user });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};
