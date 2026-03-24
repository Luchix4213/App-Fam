import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './contexts/AuthContext';
import Login from './pages/Login';
import DashboardLayout from './components/layout/DashboardLayout';
import DashboardHome from './pages/DashboardHome';
import AsociacionesList from './pages/asociaciones/AsociacionesList';
import MiembrosList from './pages/miembros/MiembrosList';
import PersonalList from './pages/personal/PersonalList';
import NoticiasList from './pages/noticias/NoticiasList';
import UsuariosList from './pages/usuarios/UsuariosList';

const ProtectedRoute = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();
  if (loading) return <div className="min-h-screen flex items-center justify-center"><div className="w-8 h-8 border-4 border-teal-500 border-t-transparent rounded-full animate-spin"></div></div>;
  if (!isAuthenticated) return <Navigate to="/login" replace />;
  return children;
};

function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />

      {/* Dashboard Routes */}
      <Route path="/" element={
        <ProtectedRoute>
          <DashboardLayout />
        </ProtectedRoute>
      }>
        <Route index element={<DashboardHome />} />
        <Route path="asociaciones" element={<AsociacionesList />} />
        <Route path="miembros" element={<MiembrosList />} />
        <Route path="personal" element={<PersonalList />} />
        <Route path="noticias" element={<NoticiasList />} />
        <Route path="usuarios" element={<UsuariosList />} />
      </Route>

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default App;
