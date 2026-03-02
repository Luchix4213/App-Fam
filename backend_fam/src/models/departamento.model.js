import { DataTypes } from "sequelize";
import sequelize from "../config/db.js";

const Departamento = sequelize.define(
  "Departamento",
  {
    nombre: {
      type: DataTypes.STRING(50),
      allowNull: false,
      unique: true,
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
    tableName: "departamento",
    timestamps: false,
  }
);

export default Departamento;


