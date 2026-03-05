import sequelize from './src/config/db.js';

async function removeDepartamentos() {
    try {
        console.log("Starting DB cleanup...");

        // Find the foreign key constraint name for id_departamento on asociaciones table
        const [results, metadata] = await sequelize.query(`
      SELECT tc.constraint_name 
      FROM information_schema.table_constraints AS tc 
      JOIN information_schema.key_column_usage AS kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
      WHERE tc.constraint_type = 'FOREIGN KEY' 
        AND tc.table_name = 'asociaciones'
        AND kcu.column_name = 'id_departamento';
    `);

        if (results.length > 0) {
            const constraintName = results[0].constraint_name;
            console.log(\`Dropping foreign key constraint: \${constraintName}\`);
      await sequelize.query(\`ALTER TABLE "asociaciones" DROP CONSTRAINT IF EXISTS "\${constraintName}";\`);
    } else {
      console.log("No foreign key constraint found for id_departamento on asociaciones.");
    }

    // Drop the column
    console.log("Dropping id_departamento column...");
    await sequelize.query(\`ALTER TABLE "asociaciones" DROP COLUMN IF EXISTS "id_departamento";\`);

    // Drop the Departamentos table
    console.log("Dropping Departamentos table...");
    await sequelize.query(\`DROP TABLE IF EXISTS "departamentos" CASCADE;\`);
    await sequelize.query(\`DROP TABLE IF EXISTS "Departamentos" CASCADE;\`); // Just in case of capitalization

    console.log("Cleanup finished successfully.");
    process.exit(0);
  } catch (error) {
    console.error("Error during DB cleanup:", error);
    process.exit(1);
  }
}

removeDepartamentos();
