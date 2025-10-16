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
  },
  {
    tableName: "departamento",
    timestamps: false,
  }
);

export default Departamento;


