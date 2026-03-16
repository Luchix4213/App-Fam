import { Noticia } from "../models/index.js";
import { uploadStream, deleteImage } from "../config/cloudinary.config.js";

const deleteOldImage = async (imagePath) => {
    if (imagePath && imagePath.includes('cloudinary.com')) {
        await deleteImage(imagePath);
    }
};

export const createNoticia = async (req, res) => {
    try {
        const data = { ...req.body };
        if (req.file) {
            const result = await uploadStream(req.file.buffer, 'noticias');
            data.imagen_url = result.secure_url;
        } else if (!data.imagen_url) {
            return res.status(400).json({ message: "Se requiere una imagen para la noticia." });
        }

        // Convertir strings "true"/"false" a booleans
        if (data.activa === 'true') data.activa = true;
        if (data.activa === 'false') data.activa = false;

        const noticia = await Noticia.create(data);
        res.status(201).json(noticia);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

export const listNoticias = async (req, res) => {
    try {
        const { activa } = req.query;
        const where = {};
        if (activa === 'true') where.activa = true;
        else if (activa === 'false') where.activa = false;

        const items = await Noticia.findAll({
            where: where,
            order: [['created_at', 'DESC']]
        });
        res.json(items);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

export const updateNoticia = async (req, res) => {
    try {
        const item = await Noticia.findByPk(req.params.id);
        if (!item) {
            return res.status(404).json({ message: "Noticia no encontrada" });
        }

        const data = { ...req.body };

        if (data.activa === 'true') data.activa = true;
        if (data.activa === 'false') data.activa = false;

        if (req.file) {
            if (item.imagen_url) {
                await deleteOldImage(item.imagen_url);
            }
            const result = await uploadStream(req.file.buffer, 'noticias');
            data.imagen_url = result.secure_url;
        }

        await item.update(data);
        res.json(item);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

export const deleteNoticia = async (req, res) => {
    try {
        const item = await Noticia.findByPk(req.params.id);
        if (!item) return res.status(404).json({ message: "No encontrado" });

        await deleteOldImage(item.imagen_url);

        await item.destroy();
        res.json({ message: "Eliminado exitosamente" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
