import { Asociacion, Departamento } from "../models/index.js";

export const createAsociacion = async (req, res) => {
  try {
    const asociacion = await Asociacion.create(req.body);
    res.status(201).json(asociacion);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const listAsociaciones = async (_req, res) => {
  try {
    const items = await Asociacion.findAll({ include: [{ model: Departamento }] });
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
    if (!item) return res.status(404).json({ message: "No encontrado" });
    await item.update(req.body);
    res.json(item);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const deleteAsociacion = async (req, res) => {
  try {
    const deleted = await Asociacion.destroy({ where: { id: req.params.id } });
    if (!deleted) return res.status(404).json({ message: "No encontrado" });
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

    //console.log('Buscando asociaciones para departamento:', departamentoId);
    //console.log('Rol del usuario:', userRole);

    // Campos básicos para todos los usuarios
    let attributes = [
      'id', 'alias', 'nombre', 'municipio', 
      'telefono_publico', 'telefono_fax', 'correo_publico', 'direccion'
    ];

    // Campos adicionales para usuarios FAM y admin
    if (userRole === 'fam' || userRole === 'admin') {
      attributes = [
        'id', 'alias', 'nombre', 'presidente', 'municipio',
        'telefono_personal', 'telefono_publico', 'telefono_fax',
        'correo_personal', 'correo_publico', 'tipo', 'direccion', 'estado'
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

    //console.log('Asociaciones encontradas:', asociaciones.length);
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


