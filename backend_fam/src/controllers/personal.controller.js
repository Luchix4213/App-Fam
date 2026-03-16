import { Personal } from "../models/index.js";
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

export const createPersonal = async (req, res) => {
    try {
        const data = sanitizeBody(req.body);
        if (req.file) {
            const result = await uploadStream(req.file.buffer, 'personal');
            data.foto = result.secure_url;
        }
        const personal = await Personal.create(data);
        res.status(201).json(personal);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

export const listPersonal = async (req, res) => {
    try {
        const { estado } = req.query;
        const where = {};
        if (estado !== 'todos') {
            where.estado = estado || 'activo';
        }

        const items = await Personal.findAll({
            where: where,
            order: [['nombre', 'ASC']]
        });
        res.json(items);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

export const getPersonal = async (req, res) => {
    try {
        const item = await Personal.findByPk(req.params.id);
        if (!item) return res.status(404).json({ message: "No encontrado" });
        res.json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

export const updatePersonal = async (req, res) => {
    try {
        const item = await Personal.findByPk(req.params.id);
        if (!item) {
            return res.status(404).json({ message: "No encontrado" });
        }

        const data = sanitizeBody(req.body);
        if (req.file) {
            if (item.foto) {
                await deleteOldImage(item.foto);
            }
            const result = await uploadStream(req.file.buffer, 'personal');
            data.foto = result.secure_url;
        }

        await item.update(data);
        res.json(item);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

export const deletePersonal = async (req, res) => {
    try {
        const item = await Personal.findByPk(req.params.id);
        if (!item) return res.status(404).json({ message: "No encontrado" });

        await deleteOldImage(item.foto);

        await item.destroy();
        res.json({ message: "Eliminado" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
