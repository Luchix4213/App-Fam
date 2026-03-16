import { useState } from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import {
    LayoutDashboard, Building2, Users, UserCog, Newspaper, Contact,
    LogOut, ChevronLeft, ChevronRight, Menu
} from 'lucide-react';

const navItems = [
    { to: '/', icon: LayoutDashboard, label: 'Dashboard' },
    { to: '/asociaciones', icon: Building2, label: 'Asociaciones' },
    { to: '/miembros', icon: Users, label: 'Miembros' },
    { to: '/personal', icon: Contact, label: 'Personal' },
    { to: '/noticias', icon: Newspaper, label: 'Noticias' },
    { to: '/usuarios', icon: UserCog, label: 'Usuarios', adminOnly: true },
];

const Sidebar = ({ collapsed, setCollapsed }) => {
    const { logout, user } = useAuth();
    const navigate = useNavigate();

    // Filtrar items según rol del usuario
    const visibleItems = navItems.filter(item => !item.adminOnly || user?.role === 'admin');

    const handleLogout = () => {
        logout();
        navigate('/login');
    };

    return (
        <aside className={`fixed top-0 left-0 h-screen bg-slate-900 text-white transition-all duration-300 z-50
      ${collapsed ? 'w-20' : 'w-64'} flex flex-col`}>

            {/* Logo */}
            <div className="flex items-center justify-between p-4 border-b border-slate-700/50">
                {!collapsed && (
                    <div className="flex items-center gap-3">
                        <div className="w-9 h-9 bg-gradient-to-br from-teal-400 to-emerald-500 rounded-lg flex items-center justify-center font-bold text-sm">
                            F
                        </div>
                        <span className="font-bold text-lg tracking-wide">FAM Bolivia</span>
                    </div>
                )}
                <button onClick={() => setCollapsed(!collapsed)}
                    className="p-2 rounded-lg hover:bg-slate-700/50 transition-colors ml-auto">
                    {collapsed ? <ChevronRight size={18} /> : <ChevronLeft size={18} />}
                </button>
            </div>

            {/* Navigation */}
            <nav className="flex-1 py-4 px-3 space-y-1 overflow-y-auto">
                {!collapsed && (
                    <p className="px-3 mb-3 text-[11px] font-semibold uppercase tracking-wider text-slate-500">
                        Administración
                    </p>
                )}
                {visibleItems.map(({ to, icon: Icon, label }) => (
                    <NavLink key={to} to={to} end={to === '/'}
                        className={({ isActive }) =>
                            `flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-200
              ${isActive
                                ? 'bg-gradient-to-r from-teal-500/20 to-emerald-500/10 text-teal-400 shadow-sm'
                                : 'text-slate-400 hover:text-white hover:bg-slate-800'
                            } ${collapsed ? 'justify-center' : ''}`
                        }
                    >
                        <Icon size={20} />
                        {!collapsed && <span>{label}</span>}
                    </NavLink>
                ))}
            </nav>

            {/* Logout */}
            <div className="p-3 border-t border-slate-700/50">
                <button onClick={handleLogout}
                    className={`flex items-center gap-3 w-full px-3 py-2.5 rounded-xl text-sm font-medium
          text-slate-400 hover:text-red-400 hover:bg-red-500/10 transition-all duration-200
          ${collapsed ? 'justify-center' : ''}`}>
                    <LogOut size={20} />
                    {!collapsed && <span>Cerrar Sesión</span>}
                </button>
            </div>
        </aside>
    );
};

export default Sidebar;
