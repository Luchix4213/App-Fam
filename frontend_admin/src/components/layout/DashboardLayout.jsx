import { useState, useEffect } from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import Header from './Header';

const DashboardLayout = () => {
    const [collapsed, setCollapsed] = useState(window.innerWidth < 768);

    useEffect(() => {
        const handleResize = () => {
            if (window.innerWidth < 768) {
                setCollapsed(true);
            }
        };
        window.addEventListener('resize', handleResize);
        return () => window.removeEventListener('resize', handleResize);
    }, []);

    return (
        <div className="min-h-screen bg-slate-50 flex">
            {/* Mobile Overlay */}
            {!collapsed && (
                <div 
                    className="fixed inset-0 bg-slate-900/50 z-40 md:hidden" 
                    onClick={() => setCollapsed(true)} 
                />
            )}

            <Sidebar collapsed={collapsed} setCollapsed={setCollapsed} />

            <div className={`flex-1 transition-all duration-300 w-full ${collapsed ? 'md:ml-20' : 'md:ml-64'}`}>
                <Header onToggleSidebar={() => setCollapsed(!collapsed)} />
                <main className="p-4 md:p-6 overflow-x-hidden">
                    <Outlet />
                </main>
            </div>
        </div>
    );
};

export default DashboardLayout;
