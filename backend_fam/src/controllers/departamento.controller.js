import { Departamento } from "../models/index.js";

export const createDepartamento = async (req, res) => {
  try {
    const departamento = await Departamento.create(req.body);
    res.status(201).json(departamento);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const listDepartamentos = async (_req, res) => {
  try {
    const items = await Departamento.findAll();
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
    if (!item) return res.status(404).json({ message: "No encontrado" });
    await item.update(req.body);
    res.json(item);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const deleteDepartamento = async (req, res) => {
  try {
    const deleted = await Departamento.destroy({ where: { id: req.params.id } });
    if (!deleted) return res.status(404).json({ message: "No encontrado" });
    res.json({ message: "Eliminado" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Endpoint público para obtener departamentos (para usuarios logueados)
export const getDepartamentosPublic = async (req, res) => {
  try {
    const departamentos = await Departamento.findAll({
      order: [['nombre', 'ASC']]
    });
    res.json(departamentos);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


