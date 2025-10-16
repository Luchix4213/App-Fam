import { Departamento, Asociacion, Miembro } from "../models/index.js";
import sequelize from "../config/db.js";

async function checkData() {
  try {
    console.log('🔍 Verificando datos en la base de datos...\n');

    // Verificar departamentos
    const departamentos = await Departamento.findAll();
    console.log(`📊 Departamentos encontrados: ${departamentos.length}`);
    departamentos.forEach(dept => {
      console.log(`  - ID: ${dept.id}, Nombre: ${dept.nombre}`);
    });

    if (departamentos.length === 0) {
      console.log('❌ No hay departamentos en la base de datos');
      return;
    }

    console.log('\n🏢 Verificando asociaciones...');
    
    // Verificar asociaciones
    const asociaciones = await Asociacion.findAll({
      include: [{
        model: Departamento,
        attributes: ['id', 'nombre']
      }]
    });
    
    console.log(`📊 Asociaciones encontradas: ${asociaciones.length}`);
    asociaciones.forEach(aso => {
      console.log(`  - ID: ${aso.id}, Nombre: ${aso.nombre}, Departamento: ${aso.Departamento?.nombre || 'Sin departamento'}`);
    });

    // Verificar asociaciones por departamento específico
    const primerDepartamento = departamentos[0];
    console.log(`\n🔍 Buscando asociaciones para "${primerDepartamento.nombre}" (ID: ${primerDepartamento.id})...`);
    
    const asociacionesPorDept = await Asociacion.findAll({
      where: {
        id_departamento: primerDepartamento.id
      },
      include: [{
        model: Departamento,
        attributes: ['id', 'nombre']
      }]
    });
    
    console.log(`📊 Asociaciones para ${primerDepartamento.nombre}: ${asociacionesPorDept.length}`);
    asociacionesPorDept.forEach(aso => {
      console.log(`  - ${aso.nombre} (${aso.alias || 'Sin alias'})`);
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
