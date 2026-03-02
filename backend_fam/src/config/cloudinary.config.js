import { v2 as cloudinary } from 'cloudinary';
import dotenv from 'dotenv';
import streamifier from 'streamifier';

dotenv.config();

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
});

export const uploadStream = (buffer, folderName) => {
    return new Promise((resolve, reject) => {
        const uploadStream = cloudinary.uploader.upload_stream(
            {
                folder: `fam_app/${folderName}`,
                resource_type: 'image',
            },
            (error, result) => {
                if (error) return reject(error);
                resolve(result);
            }
        );
        streamifier.createReadStream(buffer).pipe(uploadStream);
    });
};

export const deleteImage = async (imageUrl) => {
    try {
        if (!imageUrl || !imageUrl.includes('cloudinary.com')) return;

        const parts = imageUrl.split('/upload/');
        if (parts.length < 2) return;

        const pathParts = parts[1].split('/');
        pathParts.shift(); // Remove version (e.g., 'v1772038241')

        const fullPath = pathParts.join('/'); // 'fam_app/miembros/a8pzm0htbgyqcwmx2wys.jpg'
        const publicId = fullPath.substring(0, fullPath.lastIndexOf('.')); // Remove extension accurately if there are multiple dots mostly

        if (publicId) {
            await cloudinary.uploader.destroy(publicId);
        }
    } catch (error) {
        console.error("Error deleting image from Cloudinary:", error);
    }
};

export default cloudinary;
