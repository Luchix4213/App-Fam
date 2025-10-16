import { Miembro, Asociacion, Departamento } from "../models/index.js";

export const createMiembro = async (req, res) => {
  try {
    const miembro = await Miembro.create(req.body);
    res.status(201).json(miembro);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const listMiembros = async (_req, res) => {
  try {
    const items = await Miembro.findAll({
      include: [
        { model: Asociacion, include: [Departamento] },
      ],
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
        { model: Asociacion, include: [Departamento] },
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
    if (!item) return res.status(404).json({ message: "No encontrado" });
    await item.update(req.body);
    res.json(item);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const deleteMiembro = async (req, res) => {
  try {
    const deleted = await Miembro.destroy({ where: { id: req.params.id } });
    if (!deleted) return res.status(404).json({ message: "No encontrado" });
    res.json({ message: "Eliminado" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Obtener miembros por asociación con filtros según rol
export const getMiembrosByAsociacion = async (req, res) => {
  try {
    const { asociacionId } = req.params;
    const userRole = req.user?.role || 'usuario';

    // Campos básicos para todos los usuarios
    let attributes = [
      'id', 'alias', 'nombre', 'municipio', 
      'telefono_publico', 'telefono_fax', 'correo_publico', 'direccion'
    ];

    // Campos adicionales para usuarios FAM y admin
    if (userRole === 'fam' || userRole === 'admin') {
      attributes = [
        'id', 'alias', 'nombre', 'municipio',
        'telefono_personal', 'telefono_publico', 'telefono_fax',
        'correo_personal', 'correo_publico', 'tipo_miembro', 'direccion', 'estado'
      ];
    }

    const miembros = await Miembro.findAll({
      where: { 
        id_asociacion: asociacionId,
        estado: 'activo'
      },
      attributes: attributes,
      include: [{
        model: Asociacion,
        attributes: ['id', 'nombre', 'alias'],
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


