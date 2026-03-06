import sequelize from "./src/config/db.js";
import User from "./src/models/user.model.js";

async function runSync() {
    try {
        await User.sync({ alter: true });
        console.log("Tabla usuarios sincronizada exitosamente con alter:true");
    } catch (error) {
        console.error("Error sincronizando base de datos:", error);
    } finally {
        process.exit();
    }
}

runSync();
