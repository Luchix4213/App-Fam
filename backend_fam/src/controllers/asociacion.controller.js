import { Asociacion, Departamento } from "../models/index.js";
import { uploadStream, deleteImage } from "../config/cloudinary.config.js";

const deleteOldImage = async (imagePath) => {
  if (imagePath && imagePath.includes('cloudinary.com')) {
    await deleteImage(imagePath);
  }
};

const sanitizeBody = (body) => {
  const data = { ...body };
  Object.keys(data).forEach(key => {
    if (data[key] === "") {
      data[key] = null;
    }
  });
  return data;
};

export const createAsociacion = async (req, res) => {
  try {
    const data = sanitizeBody(req.body);
    if (req.file) {
      const result = await uploadStream(req.file.buffer, 'asociaciones');
      data.foto = result.secure_url;
    }
    const asociacion = await Asociacion.create(data);
    res.status(201).json(asociacion);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const listAsociaciones = async (req, res) => {
  try {
    const { estado } = req.query;
    const where = {};
    if (estado !== 'todos') {
      where.estado = estado || 'activo';
    }

    const items = await Asociacion.findAll({
      where: where,
      include: [{ model: Departamento }],
      order: [['nombre', 'ASC']]
    });
    res.json(items);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getAsociacion = async (req, res) => {
  try {
    const item = await Asociacion.findByPk(req.params.id, { include: [{ model: Departamento }] });
    if (!item) return res.status(404).json({ message: "No encontrado" });
    res.json(item);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const updateAsociacion = async (req, res) => {
  try {
    const item = await Asociacion.findByPk(req.params.id);
    if (!item) {
      return res.status(404).json({ message: "No encontrado" });
    }

    const data = sanitizeBody(req.body);
    if (req.file) {
      if (item.foto) {
        await deleteOldImage(item.foto);
      }
      const result = await uploadStream(req.file.buffer, 'asociaciones');
      data.foto = result.secure_url;
    }

    await item.update(data);
    res.json(item);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const deleteAsociacion = async (req, res) => {
  try {
    const item = await Asociacion.findByPk(req.params.id);
    if (!item) return res.status(404).json({ message: "No encontrado" });

    await deleteOldImage(item.foto);

    await item.destroy();
    res.json({ message: "Eliminado" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtener asociaciones por departamento con filtros según rol
export const getAsociacionesByDepartamento = async (req, res) => {
  try {
    const { departamentoId } = req.params;
    const userRole = req.user?.role || 'usuario';

    // Campos básicos para todos los usuarios
    let attributes = [
      'id', 'alias', 'nombre', 'municipio',
      'telefono_publico', 'telefono_fax', 'correo_publico', 'direccion', 'foto'
    ];

    // Campos adicionales para usuarios FAM y admin
    if (userRole === 'fam' || userRole === 'admin') {
      attributes = [
        'id', 'alias', 'nombre', 'presidente', 'municipio',
        'telefono_personal', 'telefono_publico', 'telefono_fax',
        'correo_personal', 'correo_publico', 'tipo', 'direccion', 'estado', 'foto'
      ];
    }

    const asociaciones = await Asociacion.findAll({
      where: {
        id_departamento: departamentoId,
        estado: 'activo'
      },
      attributes: attributes,
      include: [{
        model: Departamento,
        attributes: ['id', 'nombre']
      }],
      order: [['nombre', 'ASC']]
    });

    res.json(asociaciones);
  } catch (error) {
    console.error('Error al obtener asociaciones:', error);
    res.status(500).json({
      message: 'Error interno del servidor',
      error: error.message,
      details: error.stack
    });
  }
};


