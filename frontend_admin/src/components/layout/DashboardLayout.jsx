import { useState } from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import Header from './Header';

const DashboardLayout = () => {
    const [collapsed, setCollapsed] = useState(false);

    return (
        <div className="min-h-screen bg-slate-50">
            <Sidebar collapsed={collapsed} setCollapsed={setCollapsed} />

            <div className={`transition-all duration-300 ${collapsed ? 'ml-20' : 'ml-64'}`}>
                <Header onToggleSidebar={() => setCollapsed(!collapsed)} />
                <main className="p-6">
                    <Outlet />
                </main>
            </div>
        </div>
    );
};

export default DashboardLayout;
