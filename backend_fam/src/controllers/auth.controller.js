import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User from "../models/user.model.js";
import { OAuth2Client } from "google-auth-library";

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

export const register = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Validaciones básicas
    if (!name || !email || !password) {
      return res.status(400).json({ message: "Todos los campos son obligatorios" });
    }

    // Verificar si ya existe el correo
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ message: "El correo ya está registrado" });
    }

    // Encriptar contraseña
    const hashedPassword = await bcrypt.hash(password, 10);

    // Crear usuario - solo usuarios normales pueden registrarse públicamente
    const user = await User.create({
      name,
      email,
      password: hashedPassword,
      role: "usuario", // Solo usuarios normales
    });

    res.status(201).json({
      message: "Usuario registrado exitosamente",
      user: { id: user.id, name: user.name, email: user.email, role: user.role },
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Registro especial para administradores (solo admins pueden crear usuarios FAM)
export const registerFamUser = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Validaciones básicas
    if (!name || !email || !password) {
      return res.status(400).json({ message: "Todos los campos son obligatorios" });
    }

    // Verificar si ya existe el correo
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ message: "El correo ya está registrado" });
    }

    // Encriptar contraseña
    const hashedPassword = await bcrypt.hash(password, 10);

    // Crear usuario FAM
    const user = await User.create({
      name,
      email,
      password: hashedPassword,
      role: "fam", // Solo usuarios FAM
    });

    res.status(201).json({
      message: "Usuario FAM registrado exitosamente",
      user: { id: user.id, name: user.name, email: user.email, role: user.role },
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validar campos
    if (!email || !password) {
      return res.status(400).json({ message: "Email y contraseña requeridos" });
    }

    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(404).json({ message: "Usuario no encontrado" });
    }

    // Comparar contraseñas
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Contraseña incorrecta" });
    }

    // Generar Access Token
    const token = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "30m" }
    );

    // Generar Refresh Token
    const refreshToken = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "30d" }
    );

    res.json({
      message: "Login exitoso",
      token,
      refreshToken,
      user: { id: user.id, name: user.name, email: user.email, role: user.role },
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Autenticación con Google
export const googleLogin = async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({ message: "Se requiere un idToken de Google" });
    }

    // Verificar el token con Google
    const clientIds = process.env.GOOGLE_CLIENT_ID.split(',').map(id => id.trim());
    const ticket = await client.verifyIdToken({
      idToken: idToken,
      audience: clientIds, // Puede ser un array si se usan varios clientes (Web, iOS, Android)
    });

    const payload = ticket.getPayload();
    const { email, name } = payload;

    // Buscar si el usuario ya existe
    let user = await User.findOne({ where: { email } });

    // Si no existe, crearlo con rol de "usuario"
    if (!user) {
      // Generar una contraseña aleatoria segura, ya que el logueo es por Google
      const randomPassword = Math.random().toString(36).slice(-10) + Math.random().toString(36).slice(-10);
      const hashedPassword = await bcrypt.hash(randomPassword, 10);

      user = await User.create({
        name: name,
        email: email,
        password: hashedPassword,
        role: "usuario",
      });
    }

    // Generar el Access Token
    const token = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "30m" }
    );

    // Generar Refresh Token
    const refreshToken = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "30d" }
    );

    res.json({
      message: "Login con Google exitoso",
      token,
      refreshToken,
      user: { id: user.id, name: user.name, email: user.email, role: user.role },
    });

  } catch (err) {
    console.error("Error en googleLogin:", err);
    res.status(500).json({ message: "Error verificando token de Google: " + err.message });
  }
};

export const refreshToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) return res.status(403).json({ message: "Se requiere un refreshToken" });

    jwt.verify(refreshToken, process.env.JWT_SECRET, async (err, decoded) => {
      if (err) return res.status(401).json({ message: "RefreshToken expirado o inválido" });

      const user = await User.findByPk(decoded.id);
      if (!user) return res.status(404).json({ message: "Usuario no encontrado" });

      const newAccessToken = jwt.sign(
        { id: user.id, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: "30m" }
      );

      res.json({ token: newAccessToken });
    });
  } catch (err) {
    console.error("Error renovando token:", err);
    res.status(500).json({ message: err.message });
  }
};
