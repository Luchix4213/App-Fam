import { DataTypes } from "sequelize";
import sequelize from "../config/db.js";

const Asociacion = sequelize.define(
  "Asociacion",
  {
    alias: {
      type: DataTypes.STRING(50),
      allowNull: true,
    },
    nombre: {
      type: DataTypes.STRING(200),
      allowNull: false,
    },
    presidente: {
      type: DataTypes.STRING(100),
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
    municipio: {
      type: DataTypes.STRING(50),
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
    tipo: {
      type: DataTypes.ENUM("AMDES", "ACOBOL", "AMB"),
      allowNull: true,
    },
    direccion: {
      type: DataTypes.STRING(150),
      allowNull: true,
    },
    estado: {
      type: DataTypes.ENUM("activo", "inactivo", "suspendido"),
      defaultValue: "activo",
    },
  },
  {
    tableName: "asociaciones",
    timestamps: false,
  }
);

export default Asociacion;
