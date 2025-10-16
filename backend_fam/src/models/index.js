import Departamento from "./departamento.model.js";
import Asociacion from "./asociacion.model.js";
import Miembro from "./miembro.model.js";

// Relaciones
// Departamento 1 - N Asociacion
Departamento.hasMany(Asociacion, {
  foreignKey: { name: "id_departamento", allowNull: true },
  onDelete: "SET NULL",
});
Asociacion.belongsTo(Departamento, {
  foreignKey: { name: "id_departamento", allowNull: true },
});

// Asociacion 1 - N Miembro
Asociacion.hasMany(Miembro, {
  foreignKey: { name: "id_asociacion", allowNull: false },
  onDelete: "CASCADE",
});
Miembro.belongsTo(Asociacion, {
  foreignKey: { name: "id_asociacion", allowNull: false },
});

export { Departamento, Asociacion, Miembro };


