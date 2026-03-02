import { Departamento, Asociacion, Miembro } from "../models/index.js";
import { uploadStream, deleteImage } from "../config/cloudinary.config.js";
import { Op } from "sequelize";

const deleteOldImage = async (imagePath) => {
  if (imagePath && imagePath.includes('cloudinary.com')) {
    await deleteImage(imagePath);
  }
};

export const createDepartamento = async (req, res) => {
  try {
    const data = req.body;
    if (req.file) {
      const result = await uploadStream(req.file.buffer, 'departamentos');
      data.foto = result.secure_url;
    }
    // Asegurar estado activo por defecto
    data.estado = 'activo';
    const departamento = await Departamento.create(data);
    res.status(201).json(departamento);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const listDepartamentos = async (req, res) => {
  try {
    const { estado } = req.query;
    const where = {};

    if (estado !== 'todos') {
      where.estado = estado || 'activo';
    }

    const items = await Departamento.findAll({
      where: where,
      order: [['nombre', 'ASC']]
    });
    res.json(items);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getDepartamento = async (req, res) => {
  try {
    const item = await Departamento.findByPk(req.params.id);
    if (!item) return res.status(404).json({ message: "No encontrado" });
    res.json(item);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const updateDepartamento = async (req, res) => {
  try {
    const item = await Departamento.findByPk(req.params.id);

    if (!item) {
      return res.status(404).json({ message: "No encontrado" });
    }

    const data = req.body;
    if (req.file) {
      if (item.foto) {
        await deleteOldImage(item.foto);
      }
      const result = await uploadStream(req.file.buffer, 'departamentos');
      data.foto = result.secure_url;
    }

    await item.update(data);
    res.json(item);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const deleteDepartamento = async (req, res) => {
  try {
    const item = await Departamento.findByPk(req.params.id);
    if (!item || item.estado === 'inactivo') return res.status(404).json({ message: "No encontrado" });

    // BAJA LÓGICA
    // 1. Desactivar Departamento
    await item.update({ estado: 'inactivo' });

    // 2. Desactivar Asociaciones asociadas
    // Primero buscar IDs de asociaciones para desactivar sus miembros
    const asociaciones = await Asociacion.findAll({
      where: { id_departamento: item.id },
      attributes: ['id']
    });
    const asociacionIds = asociaciones.map(a => a.id);

    if (asociacionIds.length > 0) {
      // Desactivar Asociaciones
      await Asociacion.update(
        { estado: 'inactivo' },
        { where: { id_departamento: item.id } }
      );

      // 3. Desactivar Miembros asociados a esas asociaciones
      await Miembro.update(
        { estado: 'inactivo' },
        { where: { id_asociacion: { [Op.in]: asociacionIds } } }
      );
    }

    // Nota: NO borramos la imagen físicamente en baja lógica, 
    // para poder restaurarlo si fuera necesario (o borrarla si se desea limpiar espacio).
    // Usuario no especificó, pero baja lógica suele conservar datos.

    res.json({ message: "Departamento dado de baja (y sus asociaciones/miembros)" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Endpoint público para obtener departamentos (para usuarios logueados)
export const getDepartamentosPublic = async (req, res) => {
  try {
    const departamentos = await Departamento.findAll({
      where: { estado: 'activo' }, // Solo activos
      order: [['nombre', 'ASC']]
    });
    res.json(departamentos);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


