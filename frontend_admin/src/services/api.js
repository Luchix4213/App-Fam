import axios from 'axios';

const api = axios.create({
    // baseURL: 'http://localhost:4000/api', // Desarrollo local
    baseURL: 'https://api-fambolivia.onrender.com/api', // Producción
});

// Interceptor para añadir el token en cada petición
api.interceptors.request.use((config) => {
    const token = localStorage.getItem('admin_token');
    if (token) {
        config.headers.Authorization = 'Bearer ' + token;
    }
    return config;
});

// Interceptor para manejar tokens expirados (solo 401, NO 403)
api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401) {
            // Token expirado o inválido → cerrar sesión
            localStorage.removeItem('admin_token');
            localStorage.removeItem('admin_user');
            window.location.href = '/login';
        }
        // 403 = sin permisos, NO cerrar sesión, solo rechazar la petición
        return Promise.reject(error);
    }
);

export default api;
