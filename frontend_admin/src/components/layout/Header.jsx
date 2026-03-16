import { useAuth } from '../../contexts/AuthContext';
import { Menu, Bell } from 'lucide-react';

const Header = ({ onToggleSidebar }) => {
    const { user } = useAuth();

    return (
        <header className="sticky top-0 z-40 bg-white/80 backdrop-blur-lg border-b border-slate-200/60">
            <div className="flex items-center justify-between h-16 px-6">
                <div className="flex items-center gap-4">
                    <button onClick={onToggleSidebar}
                        className="lg:hidden p-2 rounded-lg hover:bg-slate-100 transition-colors">
                        <Menu size={20} className="text-slate-600" />
                    </button>
                    <div>
                        <h2 className="text-sm font-semibold text-slate-800">Panel Administrativo</h2>
                        <p className="text-xs text-slate-400">FAM Bolivia</p>
                    </div>
                </div>

                <div className="flex items-center gap-3">
                    <div className="flex items-center gap-3 pl-3 border-l border-slate-200">
                        <div className="w-9 h-9 bg-gradient-to-br from-teal-500 to-emerald-500 rounded-full flex items-center justify-center text-white font-bold text-sm">
                            {user?.name?.charAt(0)?.toUpperCase() || 'A'}
                        </div>
                        <div className="hidden sm:block">
                            <p className="text-sm font-medium text-slate-700">{user?.name || 'Admin'}</p>
                            <p className="text-xs text-slate-400 capitalize">{user?.role || 'admin'}</p>
                        </div>
                    </div>
                </div>
            </div>
        </header>
    );
};

export default Header;
