import { useState, useEffect } from 'react';
import api from '../services/api';
import { Building2, Users, Contact, Newspaper } from 'lucide-react';

const DashboardHome = () => {
    const [stats, setStats] = useState({ asociaciones: 0, miembros: 0, personal: 0 });

    useEffect(() => {
        const fetchStats = async () => {
            try {
                const [aRes, mRes, pRes] = await Promise.all([
                    api.get('/asociaciones'),
                    api.get('/miembros'),
                    api.get('/personal'),
                ]);
                const aData = Array.isArray(aRes.data) ? aRes.data : (aRes.data?.data || []);
                const mData = Array.isArray(mRes.data) ? mRes.data : (mRes.data?.data || []);
                const pData = Array.isArray(pRes.data) ? pRes.data : (pRes.data?.data || []);
                setStats({
                    asociaciones: aData.length,
                    miembros: mData.length,
                    personal: pData.length,
                });
            } catch (e) { console.error(e); }
        };
        fetchStats();
    }, []);

    const cards = [
        { label: 'Asociaciones', value: stats.asociaciones, icon: Building2, color: 'from-blue-500 to-blue-600' },
        { label: 'Miembros', value: stats.miembros, icon: Users, color: 'from-emerald-500 to-teal-600' },
        { label: 'Personal', value: stats.personal, icon: Contact, color: 'from-purple-500 to-indigo-600' },
    ];

    return (
        <div>
            <div className="mb-8">
                <h1 className="text-2xl font-bold text-slate-800">Dashboard General</h1>
                <p className="text-slate-500 mt-1">Vista general del sistema FAM Bolivia</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {cards.map((c, i) => (
                    <div key={i} className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100 hover:shadow-md transition-shadow">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm font-medium text-slate-500 uppercase tracking-wide">{c.label}</p>
                                <p className="text-3xl font-bold text-slate-800 mt-2">{c.value}</p>
                            </div>
                            <div className={`w-12 h-12 bg-gradient-to-br ${c.color} rounded-xl flex items-center justify-center`}>
                                <c.icon size={24} className="text-white" />
                            </div>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
};

export default DashboardHome;
