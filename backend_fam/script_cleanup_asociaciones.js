import sequelize from './src/config/db.js';

async function dropExtraColumns() {
    try {
        await sequelize.authenticate();
        console.log('Connection has been established successfully.');

        const queryInterface = sequelize.getQueryInterface();

        const columnsToDrop = [
            'presidente',
            'telefono_personal',
            'telefono_publico',
            'municipio',
            'telefono_fax',
            'correo_personal',
            'correo_publico',
            'tipo',
            'direccion'
        ];

        for (const column of columnsToDrop) {
            try {
                await queryInterface.removeColumn('asociaciones', column);
                console.log(`Successfully dropped column: ${column}`);
            } catch (colErr) {
                console.log(`Could not drop column ${column}:`, colErr.message);
            }
        }

        console.log('Finished dropping columns.');
        process.exit(0);
    } catch (error) {
        console.error('Unable to drop columns:', error);
        process.exit(1);
    }
}

dropExtraColumns();
