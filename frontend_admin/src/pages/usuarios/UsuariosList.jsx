import { useState, useEffect } from 'react';
import api from '../../services/api';
import { Plus, Pencil, Trash2, RotateCcw, Search, X } from 'lucide-react';

const UsuariosList = () => {
    const [data, setData] = useState([]);
    const [filtered, setFiltered] = useState([]);
    const [search, setSearch] = useState('');
    const [loading, setLoading] = useState(true);
    const [showForm, setShowForm] = useState(false);
    const [editing, setEditing] = useState(null);
    const [filterEstado, setFilterEstado] = useState('activo');

    const fetchData = async () => {
        setLoading(true);
        try {
            let url = '/users';
            if (filterEstado === 'activo') url = '/users?estado=activo';
            if (filterEstado === 'inactivo') url = '/users?estado=inactivo';
            const res = await api.get(url);
            setData(Array.isArray(res.data) ? res.data : (res.data?.data || []));
        } catch (e) { console.error(e); }
        setLoading(false);
    };

    useEffect(() => { fetchData(); }, [filterEstado]);

    useEffect(() => {
        let list = [...data];
        if (filterEstado === 'activo') {
            list = list.filter(u => String(u.estado).toLowerCase().trim() === 'activo' || !u.estado);
        }
        if (filterEstado === 'inactivo') {
            list = list.filter(u => String(u.estado).toLowerCase().trim() === 'inactivo');
        }
        if (search) {
            const q = search.toLowerCase();
            list = list.filter(u => (u.name || '').toLowerCase().includes(q) || (u.email || '').toLowerCase().includes(q));
        }
        setFiltered(list);
    }, [data, search, filterEstado]);

    const handleDelete = async (id) => {
        if (!confirm('¿Deseas desactivar este usuario?')) return;
        try { await api.put(`/usuarios/${id}`, { estado: 'inactivo' }); fetchData(); } catch (e) { alert('Error al desactivar'); }
    };
    const handleReactivate = async (id) => {
        try { await api.put(`/users/${id}`, { estado: 'activo' }); fetchData(); } catch (e) { alert('Error'); }
    };

    const roleBadge = (role) => {
        const colors = { admin: 'bg-red-50 text-red-600', fam: 'bg-blue-50 text-blue-600', usuario: 'bg-slate-100 text-slate-600' };
        const c = colors[role] || colors.usuario;
        return <span className={`px-3 py-1 rounded-full text-xs font-semibold ${c}`}>{(role || 'usuario').toUpperCase()}</span>;
    };

    return (
        <div>
            <div className="flex flex-col sm:flex-row sm:items-center justify-between mb-6 gap-4">
                <div><h1 className="text-2xl font-bold text-slate-800">Usuarios</h1><p className="text-slate-500 text-sm mt-1">Gestión de usuarios del sistema</p></div>
                <button onClick={() => { setEditing(null); setShowForm(true); }} className="flex items-center gap-2 bg-gradient-to-r from-teal-500 to-emerald-500 text-white px-5 py-2.5 rounded-xl font-medium shadow-md hover:shadow-lg transform hover:scale-[1.02] transition-all">
                    <Plus size={18} /> Nuevo Usuario
                </button>
            </div>

            <div className="bg-white rounded-2xl p-4 shadow-sm border border-slate-100 mb-6 flex flex-col sm:flex-row gap-3">
                <div className="relative flex-1">
                    <Search size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                    <input type="text" placeholder="Buscar por nombre o email..." value={search} onChange={e => setSearch(e.target.value)}
                        className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 focus:border-teal-500 outline-none transition" />
                </div>
                <select value={filterEstado} onChange={e => setFilterEstado(e.target.value)}
                    className="px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 outline-none">
                    <option value="">Todos los estados</option>
                    <option value="activo">Solo Activos</option>
                    <option value="inactivo">Solo Inactivos</option>
                </select>
            </div>

            {loading ? (
                <div className="text-center py-20"><div className="w-8 h-8 border-4 border-teal-500 border-t-transparent rounded-full animate-spin mx-auto"></div></div>
            ) : (
                <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead><tr className="bg-slate-50 border-b border-slate-100">
                                <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase">Usuario</th>
                                <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase">Email</th>
                                <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase">Rol</th>
                                <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase">Estado</th>
                                <th className="text-right p-4 text-xs font-semibold text-slate-500 uppercase">Acciones</th>
                            </tr></thead>
                            <tbody className="divide-y divide-slate-100">
                                {filtered.map(u => (
                                    <tr key={u.id} className="hover:bg-slate-50/50 transition-colors">
                                        <td className="p-4">
                                            <div className="flex items-center gap-3">
                                                <div className="w-10 h-10 bg-gradient-to-br from-amber-400 to-orange-500 rounded-full flex items-center justify-center text-white font-bold text-sm">
                                                    {(u.name || '?')[0]?.toUpperCase()}
                                                </div>
                                                <span className="font-medium text-slate-700 text-sm">{u.name}</span>
                                            </div>
                                        </td>
                                        <td className="p-4 text-sm text-slate-500">{u.email}</td>
                                        <td className="p-4">{roleBadge(u.role)}</td>
                                        <td className="p-4"><span className={`px-3 py-1 rounded-full text-xs font-semibold ${String(u.estado).toLowerCase().trim() === 'inactivo' ? 'bg-red-50 text-red-600' : 'bg-emerald-50 text-emerald-600'}`}>{String(u.estado).toLowerCase().trim() === 'inactivo' ? 'Inactivo' : 'Activo'}</span></td>
                                        <td className="p-4"><div className="flex items-center justify-end gap-2">
                                            <button onClick={() => { setEditing(u); setShowForm(true); }} className="p-2 rounded-lg text-slate-400 hover:text-blue-600 hover:bg-blue-50 transition-colors"><Pencil size={16} /></button>
                                            {String(u.estado).toLowerCase().trim() === 'inactivo' ? <button onClick={() => handleReactivate(u.id)} className="p-2 rounded-lg text-slate-400 hover:text-emerald-600 hover:bg-emerald-50 transition-colors"><RotateCcw size={16} /></button>
                                                : <button onClick={() => handleDelete(u.id)} className="p-2 rounded-lg text-slate-400 hover:text-red-600 hover:bg-red-50 transition-colors"><Trash2 size={16} /></button>}
                                        </div></td>
                                    </tr>
                                ))}
                                {filtered.length === 0 && <tr><td colSpan={5} className="p-10 text-center text-slate-400">No se encontraron usuarios</td></tr>}
                            </tbody>
                        </table>
                    </div>
                </div>
            )}

            {showForm && <UsuarioForm usuario={editing} onClose={() => setShowForm(false)} onSaved={() => { setShowForm(false); fetchData(); }} />}
        </div>
    );
};

const UsuarioForm = ({ usuario, onClose, onSaved }) => {
    const [name, setName] = useState(usuario?.name || '');
    const [email, setEmail] = useState(usuario?.email || '');
    const [password, setPassword] = useState('');
    const [role, setRole] = useState(() => {
        const r = (usuario?.role || 'usuario').toLowerCase();
        if (r === 'admin') return 'ADMIN';
        if (r === 'fam') return 'FAM';
        return 'USER';
    });
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState('');

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!name.trim() || !email.trim()) { setError('Nombre y email son obligatorios'); return; }
        if (!usuario && !password) { setError('La contraseña es obligatoria para nuevos usuarios'); return; }
        setSaving(true); setError('');
        try {
            const data = { name, email, role: role === 'ADMIN' ? 'admin' : role === 'FAM' ? 'fam' : 'usuario' };
            if (password) data.password = password;
            if (usuario) await api.put(`/users/${usuario.id}`, data);
            else await api.post('/users', data);
            onSaved();
        } catch (err) { setError(err.response?.data?.message || 'Error al guardar'); }
        setSaving(false);
    };

    return (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-[60] p-4" onClick={onClose}>
            <div className="bg-white rounded-2xl w-full max-w-lg shadow-2xl max-h-[90vh] overflow-y-auto" onClick={e => e.stopPropagation()}>
                <div className="flex items-center justify-between p-6 border-b border-slate-100">
                    <h3 className="text-lg font-bold text-slate-800">{usuario ? 'Editar Usuario' : 'Nuevo Usuario'}</h3>
                    <button onClick={onClose} className="p-2 hover:bg-slate-100 rounded-lg"><X size={18} /></button>
                </div>
                <form onSubmit={handleSubmit} className="p-6 space-y-4">
                    {error && <div className="bg-red-50 text-red-600 p-3 rounded-xl text-sm">{error}</div>}
                    <div><label className="block text-sm font-medium text-slate-700 mb-1.5">Nombre *</label><input type="text" value={name} onChange={e => setName(e.target.value)} required className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 outline-none" /></div>
                    <div><label className="block text-sm font-medium text-slate-700 mb-1.5">Correo Electrónico *</label><input type="email" value={email} onChange={e => setEmail(e.target.value)} required className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 outline-none" /></div>
                    <div><label className="block text-sm font-medium text-slate-700 mb-1.5">Contraseña {usuario ? '(dejar vacío para no cambiar)' : '*'}</label><input type="password" value={password} onChange={e => setPassword(e.target.value)} className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 outline-none" placeholder={usuario ? '••••••••' : ''} /></div>
                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1.5">Rol</label>
                        <select value={role} onChange={e => setRole(e.target.value)} className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 outline-none">
                            <option value="ADMIN">Administrador</option>
                            <option value="FAM">FAM</option>
                            <option value="USER">Usuario</option>
                        </select>
                    </div>
                    <div className="flex gap-3 pt-2">
                        <button type="button" onClick={onClose} className="flex-1 px-4 py-2.5 border border-slate-200 rounded-xl text-sm font-medium text-slate-600 hover:bg-slate-50">Cancelar</button>
                        <button type="submit" disabled={saving} className="flex-1 px-4 py-2.5 bg-gradient-to-r from-teal-500 to-emerald-500 text-white rounded-xl text-sm font-bold shadow-md disabled:opacity-60">{saving ? 'Guardando...' : (usuario ? 'Actualizar' : 'Crear')}</button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default UsuariosList;
