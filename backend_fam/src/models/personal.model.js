import { DataTypes } from "sequelize";
import sequelize from "../config/db.js";

const Personal = sequelize.define(
    "Personal",
    {
        nombre: {
            type: DataTypes.STRING(200),
            allowNull: false,
        },
        cargo: {
            type: DataTypes.STRING(150),
            allowNull: false,
        },
        celular: {
            type: DataTypes.STRING(20),
            allowNull: true,
        },
        correo_electronico: {
            type: DataTypes.STRING(100),
            allowNull: true,
            validate: {
                isEmailOrEmpty(value) {
                    if (value && value !== "" && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
                        throw new Error("Formato de correo inválido");
                    }
                },
            },
        },
        foto: {
            type: DataTypes.STRING(255),
            allowNull: true,
        },
        estado: {
            type: DataTypes.ENUM("activo", "inactivo"),
            defaultValue: "activo",
        },
    },
    {
        tableName: "personal", // Nombre de la tabla en Postgres
        timestamps: false,
    }
);

export default Personal;
