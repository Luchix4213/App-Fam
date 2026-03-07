import { DataTypes } from "sequelize";
import sequelize from "../config/db.js";

const Asociacion = sequelize.define(
  "Asociacion",
  {
    alias: {
      type: DataTypes.STRING(50),
      allowNull: true,
    },
    foto: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    color: {
      type: DataTypes.STRING(50),
      allowNull: true,
    },
    nombre: {
      type: DataTypes.STRING(200),
      allowNull: false,
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
