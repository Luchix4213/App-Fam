import { DataTypes } from "sequelize";
import sequelize from "../config/db.js";

const Miembro = sequelize.define(
  "Miembro",
  {
    alias: {
      type: DataTypes.STRING(50),
      allowNull: true,
    },
    nombre: {
      type: DataTypes.STRING(200),
      allowNull: false,
    },
    municipio: {
      type: DataTypes.STRING(50),
      allowNull: true,
    },
    telefono_personal: {
      type: DataTypes.STRING(20),
      allowNull: true,
    },
    telefono_publico: {
      type: DataTypes.STRING(20),
      allowNull: true,
    },
    telefono_fax: {
      type: DataTypes.STRING(40),
      allowNull: true,
    },
    correo_personal: {
      type: DataTypes.STRING(70),
      allowNull: true,
      validate: { isEmail: true },
    },
    correo_publico: {
      type: DataTypes.STRING(70),
      allowNull: true,
      validate: { isEmail: true },
    },
    direccion: {
      type: DataTypes.STRING(150),
      allowNull: true,
    },
    tipo_miembro: {
      type: DataTypes.ENUM("ALCALDE", "CONCEJALA", "AMBES"),
      allowNull: true,
    },
    estado: {
      type: DataTypes.ENUM("activo", "inactivo", "suspendido"),
      defaultValue: "activo",
    },
  },
  {
    tableName: "miembros",
    timestamps: false,
  }
);

export default Miembro;


