import { DataTypes } from "sequelize";
import sequelize from "../config/db.js";

const Noticia = sequelize.define(
    "Noticia",
    {
        titulo: {
            type: DataTypes.STRING(150),
            allowNull: false,
        },
        descripcion: {
            type: DataTypes.TEXT,
            allowNull: true,
        },
        imagen_url: {
            type: DataTypes.STRING(255),
            allowNull: false,
        },
        activa: {
            type: DataTypes.BOOLEAN,
            defaultValue: true,
        },
        creado_por: {
            type: DataTypes.INTEGER,
            allowNull: true, // Asumimos opcional por ahora si no hay foreing key estricta en DB vieja
        },
    },
    {
        tableName: "noticias",
        timestamps: true, // Esto añadirá createdAt automáticamente
        createdAt: "created_at",
        updatedAt: false, // Desactivar si no quieres updatedAt
    }
);

export default Noticia;
