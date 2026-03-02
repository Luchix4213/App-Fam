import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Función factory para crear middleware con carpeta específica
export const upload = (folderName = 'uploads') => {
    // Definir ruta de destino dinámica
    // Se guardará en public/images/{folderName} (o public/{folderName} si prefieres)
    // El usuario pidió: assets/images/departamentos -> en backend mapearemos a public/images/departamentos

    const storage = multer.memoryStorage();

    const fileFilter = (req, file, cb) => {
        if (file.mimetype.startsWith('image/')) {
            cb(null, true);
        } else {
            cb(new Error('No es una imagen! Por favor sube solo imágenes.'), false);
        }
    };

    return multer({
        storage: storage,
        fileFilter: fileFilter,
        limits: { fileSize: 10 * 1024 * 1024 } // 10MB es más razonable para memoria
    });
};
