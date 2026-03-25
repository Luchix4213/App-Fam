import { useState, useEffect } from 'react';
import api from '../../services/api';
import { Plus, Pencil, Trash2, RotateCcw, Search, X, Upload } from 'lucide-react';

const API_BASE = 'https://api-fambolivia.onrender.com';

const PersonalList = () => {
    const [data, setData] = useState([]);
    const [filtered, setFiltered] = useState([]);
    const [search, setSearch] = useState('');
    const [loading, setLoading] = useState(true);
    const [showForm, setShowForm] = useState(false);
    const [editing, setEditing] = useState(null);
    const [filterEstado, setFilterEstado] = useState('activo');

    const fetchData = async () => {
        setLoading(true);
        try { const res = await api.get('/personal'); setData(Array.isArray(res.data) ? res.data : (res.data?.data || [])); } catch (e) { console.error(e); }
        setLoading(false);
    };

    useEffect(() => { fetchData(); }, []);

    useEffect(() => {
        let list = [...data];

        if (filterEstado === 'activo') {
            list = list.filter(p => String(p.estado).toLowerCase() === 'activo');
        }

        if (filterEstado === 'inactivo') {
            list = list.filter(p => String(p.estado).toLowerCase() === 'inactivo');
        }

        if (search) {
            const q = search.toLowerCase();
            list = list.filter(p =>
                (p.nombre || '').toLowerCase().includes(q) ||
                (p.cargo || '').toLowerCase().includes(q)
            );
        }

        setFiltered(list);
    }, [data, search, filterEstado]);

    const handleDelete = async (id) => {
        if (!confirm('¿Deseas desactivar este personal?')) return;
        try { await api.put(`/personal/${id}`, { estado: 'inactivo' }); fetchData(); } catch (e) { alert('Error al desactivar'); }
    };
    const handleReactivate = async (id) => {
        try { await api.put(`/personal/${id}`, { estado: 'activo' }); fetchData(); } catch (e) { alert('Error'); }
    };

    return (
        <div>
            <div className="flex flex-col sm:flex-row sm:items-center justify-between mb-6 gap-4">
                <div><h1 className="text-2xl font-bold text-slate-800">Personal</h1><p className="text-slate-500 text-sm mt-1">Directorio de personal FAM</p></div>
                <button onClick={() => { setEditing(null); setShowForm(true); }} className="flex items-center gap-2 bg-gradient-to-r from-teal-500 to-emerald-500 text-white px-5 py-2.5 rounded-xl font-medium shadow-md hover:shadow-lg transform hover:scale-[1.02] transition-all">
                    <Plus size={18} /> Nuevo Personal
                </button>
            </div>

            <div className="bg-white rounded-2xl p-4 shadow-sm border border-slate-100 mb-6 flex flex-col sm:flex-row gap-3">
                <div className="relative flex-1">
                    <Search size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                    <input type="text" placeholder="Buscar por nombre o cargo..." value={search} onChange={e => setSearch(e.target.value)}
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
                                <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase">Personal</th>
                                <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase">Cargo</th>
                                <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase">Celular</th>
                                <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase">Correo</th>
                                <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase">Estado</th>
                                <th className="text-right p-4 text-xs font-semibold text-slate-500 uppercase">Acciones</th>
                            </tr></thead>
                            <tbody className="divide-y divide-slate-100">
                                {filtered.map(p => (
                                    <tr key={p.id} className="hover:bg-slate-50/50 transition-colors">
                                        <td className="p-4">
                                            <div className="flex items-center gap-3">
                                                {p.foto ? <img src={p.foto.startsWith('http') ? p.foto : `${API_BASE}${p.foto}`} className="w-10 h-10 rounded-full object-cover border" alt="" />
                                                    : <div className="w-10 h-10 bg-gradient-to-br from-purple-400 to-indigo-500 rounded-full flex items-center justify-center text-white font-bold text-sm">{(p.nombre || '?')[0]?.toUpperCase()}</div>}
                                                <span className="font-medium text-slate-700 text-sm">{p.nombre}</span>
                                            </div>
                                        </td>
                                        <td className="p-4 text-sm text-slate-500">{p.cargo || '—'}</td>
                                        <td className="p-4 text-sm text-slate-500">{p.celular || '—'}</td>
                                        <td className="p-4 text-sm text-slate-500">{p.correo_electronico || '—'}</td>
                                        <td className="p-4"><span className={`px-3 py-1 rounded-full text-xs font-semibold ${String(p.estado).toLowerCase() === 'inactivo' ? 'bg-red-50 text-red-600' : 'bg-emerald-50 text-emerald-600'}`}>{String(p.estado).toLowerCase() === 'inactivo' ? 'Inactivo' : 'Activo'}</span></td>
                                        <td className="p-4"><div className="flex items-center justify-end gap-2">
                                            <button onClick={() => { setEditing(p); setShowForm(true); }} className="p-2 rounded-lg text-slate-400 hover:text-blue-600 hover:bg-blue-50 transition-colors"><Pencil size={16} /></button>
                                            {String(p.estado).toLowerCase() === 'inactivo' ? <button onClick={() => handleReactivate(p.id)} className="p-2 rounded-lg text-slate-400 hover:text-emerald-600 hover:bg-emerald-50 transition-colors"><RotateCcw size={16} /></button>
                                                : <button onClick={() => handleDelete(p.id)} className="p-2 rounded-lg text-slate-400 hover:text-red-600 hover:bg-red-50 transition-colors"><Trash2 size={16} /></button>}
                                        </div></td>
                                    </tr>
                                ))}
                                {filtered.length === 0 && <tr><td colSpan={6} className="p-10 text-center text-slate-400">No se encontró personal</td></tr>}
                            </tbody>
                        </table>
                    </div>
                </div>
            )}

            {showForm && <PersonalForm personal={editing} onClose={() => setShowForm(false)} onSaved={() => { setShowForm(false); fetchData(); }} />}
        </div>
    );
};

const PersonalForm = ({ personal, onClose, onSaved }) => {
    const [nombre, setNombre] = useState(personal?.nombre || '');
    const [cargo, setCargo] = useState(personal?.cargo || '');
    const [celular, setCelular] = useState(personal?.celular || '');
    const [correo, setCorreo] = useState(personal?.correo_electronico || '');
    const [imageFile, setImageFile] = useState(null);
    const [preview, setPreview] = useState(personal?.foto ? (personal.foto.startsWith('http') ? personal.foto : `${API_BASE}${personal.foto}`) : null);
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState('');

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!nombre.trim()) { setError('El nombre es obligatorio'); return; }
        setSaving(true); setError('');
        try {
            const fd = new FormData();
            fd.append('nombre', nombre); fd.append('cargo', cargo); fd.append('celular', celular);
            fd.append('correo_electronico', correo); fd.append('estado', personal?.estado || 'activo');
            if (imageFile) fd.append('foto', imageFile);
            if (personal) await api.put(`/personal/${personal.id}`, fd, { headers: { 'Content-Type': 'multipart/form-data' } });
            else await api.post('/personal', fd, { headers: { 'Content-Type': 'multipart/form-data' } });
            onSaved();
        } catch (err) { setError(err.response?.data?.message || 'Error al guardar'); }
        setSaving(false);
    };

    return (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-[60] p-4" onClick={onClose}>
            <div className="bg-white rounded-2xl w-full max-w-lg shadow-2xl max-h-[90vh] overflow-y-auto" onClick={e => e.stopPropagation()}>
                <div className="flex items-center justify-between p-6 border-b border-slate-100">
                    <h3 className="text-lg font-bold text-slate-800">{personal ? 'Editar Personal' : 'Nuevo Personal'}</h3>
                    <button onClick={onClose} className="p-2 hover:bg-slate-100 rounded-lg"><X size={18} /></button>
                </div>
                <form onSubmit={handleSubmit} className="p-6 space-y-4">
                    {error && <div className="bg-red-50 text-red-600 p-3 rounded-xl text-sm">{error}</div>}
                    <div><label className="block text-sm font-medium text-slate-700 mb-1.5">Nombre *</label><input type="text" value={nombre} onChange={e => setNombre(e.target.value)} required className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 outline-none" /></div>
                    <div><label className="block text-sm font-medium text-slate-700 mb-1.5">Cargo</label><input type="text" value={cargo} onChange={e => setCargo(e.target.value)} className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 outline-none" /></div>
                    <div><label className="block text-sm font-medium text-slate-700 mb-1.5">Celular</label><input type="text" value={celular} onChange={e => setCelular(e.target.value)} className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 outline-none" /></div>
                    <div><label className="block text-sm font-medium text-slate-700 mb-1.5">Correo Electrónico</label><input type="email" value={correo} onChange={e => setCorreo(e.target.value)} className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 outline-none" /></div>
                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1.5">Foto</label>
                        <div className="border-2 border-dashed border-slate-200 rounded-xl p-4 text-center hover:border-teal-400 transition-colors">
                            {preview ? <div className="relative inline-block"><img src={preview} alt="" className="w-20 h-20 object-cover rounded-full mx-auto" /><button type="button" onClick={() => { setPreview(null); setImageFile(null) }} className="absolute -top-1 -right-1 bg-red-500 text-white rounded-full w-5 h-5 flex items-center justify-center text-xs"><X size={10} /></button></div>
                                : <label className="cursor-pointer block"><Upload size={28} className="mx-auto text-slate-300 mb-1" /><p className="text-sm text-slate-400">Click para subir foto</p><input type="file" accept="image/*" onChange={e => { const f = e.target.files[0]; if (f) { setImageFile(f); setPreview(URL.createObjectURL(f)) } }} className="hidden" /></label>}
                            {preview && <label className="cursor-pointer block mt-2 text-sm text-teal-600 font-medium">Cambiar<input type="file" accept="image/*" onChange={e => { const f = e.target.files[0]; if (f) { setImageFile(f); setPreview(URL.createObjectURL(f)) } }} className="hidden" /></label>}
                        </div>
                    </div>
                    <div className="flex gap-3 pt-2">
                        <button type="button" onClick={onClose} className="flex-1 px-4 py-2.5 border border-slate-200 rounded-xl text-sm font-medium text-slate-600 hover:bg-slate-50">Cancelar</button>
                        <button type="submit" disabled={saving} className="flex-1 px-4 py-2.5 bg-gradient-to-r from-teal-500 to-emerald-500 text-white rounded-xl text-sm font-bold shadow-md disabled:opacity-60">{saving ? 'Guardando...' : (personal ? 'Actualizar' : 'Crear')}</button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default PersonalList;
