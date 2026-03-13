import { createContext, useContext, useState, useEffect } from 'react';
import api from '../services/api';

const AuthContext = createContext();

export const useAuth = () => useContext(AuthContext);

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        // Verificar si hay usuario almacenado al inicio
        const storedUser = localStorage.getItem('admin_user');
        const storedToken = localStorage.getItem('admin_token');

        if (storedUser && storedToken) {
            setUser(JSON.parse(storedUser));
        }
        setLoading(false);
    }, []);

    const login = async (email, password) => {
        try {
            const response = await api.post('/auth/login', { email, password });
            if (response.data.success) {
                const { token, user } = response.data;
                // Solo permitir admins
                if (user.role !== 'admin' && user.role !== 'fam') {
                    throw new Error('No tienes permisos de administrador.');
                }

                localStorage.setItem('admin_token', token);
                localStorage.setItem('admin_user', JSON.stringify(user));
                setUser(user);
                return { success: true };
            }
            return { success: false, message: response.data.message || 'Error en credenciales' };
        } catch (error) {
            const message = error.response?.data?.message || error.message || 'Error de conexión';
            return { success: false, message };
        }
    };

    const logout = () => {
        localStorage.removeItem('admin_token');
        localStorage.removeItem('admin_user');
        setUser(null);
    };

    return (
        <AuthContext.Provider value={{ user, login, logout, isAuthenticated: !!user, loading }}>
            {!loading && children}
        </AuthContext.Provider>
    );
};
