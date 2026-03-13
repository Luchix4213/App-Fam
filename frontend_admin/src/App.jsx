import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './contexts/AuthContext';
import Login from './pages/Login';
// import DashboardHome from '../pages/DashboardHome';

// Protective Route Component
const ProtectedRoute = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();

  if (loading) return <div className="min-h-screen flex items-center justify-center">Cargando...</div>;
  if (!isAuthenticated) return <Navigate to="/login" replace />;

  return children;
};

function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />

      {/* Rutas Privadas */}
      <Route path="/" element={
        <ProtectedRoute>
          {/* Aquí irá el Layout de Sidebar en el futuro */}
          <div className="p-8">
            <h1 className="text-3xl font-bold bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">
              Bienvenido al Panel de Administración
            </h1>
            <p className="mt-4 text-gray-600">Este es el dashboard. Pronto agregaremos las vistas.</p>
          </div>
        </ProtectedRoute>
      } />

      {/* Route fall-back */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default App;
