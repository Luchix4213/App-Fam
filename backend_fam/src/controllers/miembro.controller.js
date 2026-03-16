import { Miembro, Asociacion } from "../models/index.js";
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

export const createMiembro = async (req, res) => {
  try {
    const data = sanitizeBody(req.body);
    if (req.file) {
      const result = await uploadStream(req.file.buffer, 'miembros');
      data.foto = result.secure_url;
    }
    const miembro = await Miembro.create(data);
    res.status(201).json(miembro);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const listMiembros = async (req, res) => {
  try {
    const { estado } = req.query;
    const where = {};
    if (estado !== 'todos') {
      where.estado = estado || 'activo';
    }

    const items = await Miembro.findAll({
      where: where,
      include: [
        { model: Asociacion },
      ],
      order: [['nombre', 'ASC']]
    });
    res.json(items);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getMiembro = async (req, res) => {
  try {
    const item = await Miembro.findByPk(req.params.id, {
      include: [
        { model: Asociacion },
      ],
    });
    if (!item) return res.status(404).json({ message: "No encontrado" });
    res.json(item);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const updateMiembro = async (req, res) => {
  try {
    const item = await Miembro.findByPk(req.params.id);
    if (!item) {
      return res.status(404).json({ message: "No encontrado" });
    }

    const data = sanitizeBody(req.body);
    if (req.file) {
      if (item.foto) {
        await deleteOldImage(item.foto);
      }
      const result = await uploadStream(req.file.buffer, 'miembros');
      data.foto = result.secure_url;
    }

    await item.update(data);
    res.json(item);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const deleteMiembro = async (req, res) => {
  try {
    const item = await Miembro.findByPk(req.params.id);
    if (!item) return res.status(404).json({ message: "No encontrado" });

    await deleteOldImage(item.foto);

    await item.destroy();
    res.json({ message: "Eliminado" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtener miembros por asociación (Vista Pública)
export const getMiembrosByAsociacion = async (req, res) => {
  try {
    const { asociacionId } = req.params;

    // Campos básicos para todos los usuarios (Vista Pública)
    const attributes = [
      'id', 'alias', 'nombre', 'municipio',
      'telefono_publico', 'telefono_fax', 'correo_publico', 'direccion', 'foto'
    ];

    const miembros = await Miembro.findAll({
      where: {
        id_asociacion: asociacionId,
        estado: 'activo'
      },
      attributes: attributes,
      include: [{
        model: Asociacion,
        attributes: ['id', 'nombre', 'alias', 'tipo', 'id_departamento'],
        include: [{
          model: Departamento,
          attributes: ['id', 'nombre']
        }]
      }],
      order: [['nombre', 'ASC']]
    });

    res.json(miembros);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


