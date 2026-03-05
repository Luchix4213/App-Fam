import { Asociacion, Miembro } from "../models/index.js";
import sequelize from "../config/db.js";

async function checkData() {
  try {
    console.log('🔍 Verificando datos en la base de datos...\n');

    console.log('\n🏢 Verificando asociaciones...');

    // Verificar asociaciones
    const asociaciones = await Asociacion.findAll();

    console.log(`📊 Asociaciones encontradas: ${asociaciones.length}`);
    asociaciones.forEach(aso => {
      console.log(`  - ID: ${aso.id}, Nombre: ${aso.nombre}`);
    });

    // Verificar miembros
    const miembros = await Miembro.findAll({
      include: [{
        model: Asociacion,
        attributes: ['id', 'nombre', 'alias']
      }]
    });

    console.log(`\n👥 Miembros encontrados: ${miembros.length}`);
    miembros.slice(0, 5).forEach(miembro => {
      console.log(`  - ${miembro.nombre} (${miembro.Asociacion?.nombre || 'Sin asociación'})`);
    });

  } catch (error) {
    console.error('❌ Error al verificar datos:', error.message);
  } finally {
    await sequelize.close();
  }
}

checkData();
