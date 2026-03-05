import Asociacion from "./asociacion.model.js";
import Miembro from "./miembro.model.js";
import Personal from "./personal.model.js";

// Asociacion 1 - N Miembro
Asociacion.hasMany(Miembro, {
  foreignKey: { name: "id_asociacion", allowNull: false },
  onDelete: "CASCADE",
});
Miembro.belongsTo(Asociacion, {
  foreignKey: { name: "id_asociacion", allowNull: false },
});

export { Asociacion, Miembro, Personal };

