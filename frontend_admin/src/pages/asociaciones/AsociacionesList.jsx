import { useState, useEffect } from 'react';
import api from '../../services/api';
import { Plus, Pencil, Trash2, RotateCcw, Search, X, Upload, Building2 } from 'lucide-react';

const API_BASE = 'https://api-fambolivia.onrender.com';

const AsociacionesList = () => {
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
            const res = await api.get('/asociaciones');
            const list = Array.isArray(res.data) ? res.data : (res.data?.data || []);
            setData(list);
        } catch (e) { console.error(e); }
        setLoading(false);
    };

    useEffect(() => { fetchData(); }, []);

    useEffect(() => {
        let list = data;
        if (filterEstado === 'activo') list = list.filter(a => a.estado !== 'inactivo');
        if (filterEstado === 'inactivo') list = list.filter(a => a.estado === 'inactivo');
        if (search) {
            const q = search.toLowerCase();
            list = list.filter(a => (a.nombre || '').toLowerCase().includes(q) || (a.alias || '').toLowerCase().includes(q));
        }
        setFiltered(list);
    }, [data, search, filterEstado]);

    const handleDelete = async (id) => {
        if (!confirm('¿Deseas desactivar esta asociación?')) return;
        try { await api.delete(`/asociaciones/${id}`); fetchData(); } catch (e) { alert('Error al eliminar'); }
    };

    const handleReactivate = async (id) => {
        try { await api.put(`/asociaciones/${id}`, { estado: 'activo' }); fetchData(); } catch (e) { alert('Error al reactivar'); }
    };

    const openEdit = (a) => { setEditing(a); setShowForm(true); };
    const openCreate = () => { setEditing(null); setShowForm(true); };

    return (
        <div>
            <div className="flex flex-col sm:flex-row sm:items-center justify-between mb-6 gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Asociaciones</h1>
                    <p className="text-slate-500 text-sm mt-1">Gestión de asociaciones de FAM Bolivia</p>
                </div>
                <button onClick={openCreate}
                    className="flex items-center gap-2 bg-gradient-to-r from-teal-500 to-emerald-500 text-white px-5 py-2.5 rounded-xl font-medium shadow-md hover:shadow-lg transform hover:scale-[1.02] transition-all">
                    <Plus size={18} /> Nueva Asociación
                </button>
            </div>

            {/* Filters */}
            <div className="bg-white rounded-2xl p-4 shadow-sm border border-slate-100 mb-6 flex flex-col sm:flex-row gap-3">
                <div className="relative flex-1">
                    <Search size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                    <input type="text" placeholder="Buscar por nombre o alias..." value={search} onChange={e => setSearch(e.target.value)}
                        className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 focus:border-teal-500 outline-none transition" />
                </div>
                <select value={filterEstado} onChange={e => setFilterEstado(e.target.value)}
                    className="px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 outline-none">
                    <option value="">Todos los estados</option>
                    <option value="activo">Solo Activos</option>
                    <option value="inactivo">Solo Inactivos</option>
                </select>
            </div>

            {/* Table */}
            {loading ? (
                <div className="text-center py-20">
                    <div className="w-8 h-8 border-4 border-teal-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
                    <p className="text-slate-400 mt-4">Cargando asociaciones...</p>
                </div>
            ) : (
                <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead>
                                <tr className="bg-slate-50 border-b border-slate-100">
                                    <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase tracking-wider">Asociación</th>
                                    <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase tracking-wider">Alias</th>
                                    <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase tracking-wider">Color</th>
                                    <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase tracking-wider">Estado</th>
                                    <th className="text-right p-4 text-xs font-semibold text-slate-500 uppercase tracking-wider">Acciones</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {filtered.map(a => (
                                    <tr key={a.id} className="hover:bg-slate-50/50 transition-colors">
                                        <td className="p-4">
                                            <div className="flex items-center gap-3">
                                                {a.logo ? (
                                                    <img src={a.logo.startsWith('http') ? a.logo : `${API_BASE}${a.logo}`}
                                                        className="w-10 h-10 rounded-xl object-cover border border-slate-200" alt="" />
                                                ) : (
                                                    <div className="w-10 h-10 bg-slate-100 rounded-xl flex items-center justify-center">
                                                        <Building2 size={18} className="text-slate-400" />
                                                    </div>
                                                )}
                                                <span className="font-medium text-slate-700 text-sm">{a.nombre}</span>
                                            </div>
                                        </td>
                                        <td className="p-4 text-sm text-slate-500">{a.alias || '—'}</td>
                                        <td className="p-4">
                                            {a.color ? (
                                                <div className="flex items-center gap-2">
                                                    <div className="w-7 h-7 rounded-lg border border-slate-200 shadow-inner"
                                                        style={{ backgroundColor: a.color }}></div>
                                                    <span className="text-xs text-slate-400 font-mono">{a.color}</span>
                                                </div>
                                            ) : <span className="text-xs text-slate-400">Sin color</span>}
                                        </td>
                                        <td className="p-4">
                                            <span className={`px-3 py-1 rounded-full text-xs font-semibold
                        ${a.estado === 'inactivo' ? 'bg-red-50 text-red-600' : 'bg-emerald-50 text-emerald-600'}`}>
                                                {a.estado === 'inactivo' ? 'Inactivo' : 'Activo'}
                                            </span>
                                        </td>
                                        <td className="p-4">
                                            <div className="flex items-center justify-end gap-2">
                                                <button onClick={() => openEdit(a)} title="Editar"
                                                    className="p-2 rounded-lg text-slate-400 hover:text-blue-600 hover:bg-blue-50 transition-colors">
                                                    <Pencil size={16} />
                                                </button>
                                                {a.estado === 'inactivo' ? (
                                                    <button onClick={() => handleReactivate(a.id)} title="Reactivar"
                                                        className="p-2 rounded-lg text-slate-400 hover:text-emerald-600 hover:bg-emerald-50 transition-colors">
                                                        <RotateCcw size={16} />
                                                    </button>
                                                ) : (
                                                    <button onClick={() => handleDelete(a.id)} title="Desactivar"
                                                        className="p-2 rounded-lg text-slate-400 hover:text-red-600 hover:bg-red-50 transition-colors">
                                                        <Trash2 size={16} />
                                                    </button>
                                                )}
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                                {filtered.length === 0 && (
                                    <tr><td colSpan={5} className="p-10 text-center text-slate-400">No se encontraron asociaciones</td></tr>
                                )}
                            </tbody>
                        </table>
                    </div>
                </div>
            )}

            {/* Form Modal */}
            {showForm && (
                <AsociacionForm asociacion={editing} onClose={() => setShowForm(false)}
                    onSaved={() => { setShowForm(false); fetchData(); }} />
            )}
        </div>
    );
};

/* ===== FORM MODAL ===== */
const AsociacionForm = ({ asociacion, onClose, onSaved }) => {
    const [nombre, setNombre] = useState(asociacion?.nombre || '');
    const [alias, setAlias] = useState(asociacion?.alias || '');
    const [color, setColor] = useState(asociacion?.color || '#0ea5e9');
    const [imageFile, setImageFile] = useState(null);
    const [preview, setPreview] = useState(asociacion?.logo ? (asociacion.logo.startsWith('http') ? asociacion.logo : `${API_BASE}${asociacion.logo}`) : null);
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState('');

    const handleFileChange = (e) => {
        const file = e.target.files[0];
        if (file) {
            setImageFile(file);
            setPreview(URL.createObjectURL(file));
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!nombre.trim()) { setError('El nombre es obligatorio'); return; }
        setSaving(true);
        setError('');

        try {
            const formData = new FormData();
            formData.append('nombre', nombre);
            formData.append('alias', alias);
            formData.append('color', color);
            formData.append('estado', asociacion?.estado || 'activo');
            if (imageFile) formData.append('foto', imageFile);

            if (asociacion) {
                await api.put(`/asociaciones/${asociacion.id}`, formData, { headers: { 'Content-Type': 'multipart/form-data' } });
            } else {
                await api.post('/asociaciones', formData, { headers: { 'Content-Type': 'multipart/form-data' } });
            }
            onSaved();
        } catch (err) {
            setError(err.response?.data?.message || 'Error al guardar');
        }
        setSaving(false);
    };

    return (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-[60] p-4" onClick={onClose}>
            <div className="bg-white rounded-2xl w-full max-w-lg shadow-2xl max-h-[90vh] overflow-y-auto" onClick={e => e.stopPropagation()}>
                <div className="flex items-center justify-between p-6 border-b border-slate-100">
                    <h3 className="text-lg font-bold text-slate-800">{asociacion ? 'Editar Asociación' : 'Nueva Asociación'}</h3>
                    <button onClick={onClose} className="p-2 hover:bg-slate-100 rounded-lg transition-colors"><X size={18} /></button>
                </div>

                <form onSubmit={handleSubmit} className="p-6 space-y-5">
                    {error && <div className="bg-red-50 text-red-600 p-3 rounded-xl text-sm">{error}</div>}

                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1.5">Nombre *</label>
                        <input type="text" value={nombre} onChange={e => setNombre(e.target.value)} required
                            className="w-full px-4 py-2.5 border border-slate-200 rounded-xl bg-slate-50 focus:ring-2 focus:ring-teal-500 focus:border-teal-500 outline-none text-sm transition" />
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1.5">Alias</label>
                        <input type="text" value={alias} onChange={e => setAlias(e.target.value)}
                            className="w-full px-4 py-2.5 border border-slate-200 rounded-xl bg-slate-50 focus:ring-2 focus:ring-teal-500 focus:border-teal-500 outline-none text-sm transition" />
                    </div>

                    {/* Color Picker */}
                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1.5">Color de la Asociación</label>
                        <div className="flex items-center gap-4">
                            <input type="color" value={color} onChange={e => setColor(e.target.value)}
                                className="w-14 h-14 rounded-xl cursor-pointer border-2 border-slate-200 p-1" />
                            <div className="flex-1">
                                <input type="text" value={color} onChange={e => setColor(e.target.value)}
                                    className="w-full px-4 py-2.5 border border-slate-200 rounded-xl bg-slate-50 font-mono text-sm focus:ring-2 focus:ring-teal-500 focus:border-teal-500 outline-none transition"
                                    placeholder="#0ea5e9" />
                                <div className="mt-2 h-3 rounded-full" style={{ backgroundColor: color }}></div>
                            </div>
                        </div>
                    </div>

                    {/* Image Upload */}
                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1.5">Logo / Imagen</label>
                        <div className="border-2 border-dashed border-slate-200 rounded-xl p-4 text-center hover:border-teal-400 transition-colors">
                            {preview ? (
                                <div className="relative inline-block">
                                    <img src={preview} alt="Preview" className="w-24 h-24 object-cover rounded-xl mx-auto" />
                                    <button type="button" onClick={() => { setPreview(null); setImageFile(null); }}
                                        className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-xs hover:bg-red-600">
                                        <X size={12} />
                                    </button>
                                </div>
                            ) : (
                                <label className="cursor-pointer block">
                                    <Upload size={32} className="mx-auto text-slate-300 mb-2" />
                                    <p className="text-sm text-slate-400">Click para subir imagen</p>
                                    <input type="file" accept="image/*" onChange={handleFileChange} className="hidden" />
                                </label>
                            )}
                            {preview && (
                                <label className="cursor-pointer block mt-3 text-sm text-teal-600 hover:text-teal-700 font-medium">
                                    Cambiar imagen
                                    <input type="file" accept="image/*" onChange={handleFileChange} className="hidden" />
                                </label>
                            )}
                        </div>
                    </div>

                    <div className="flex gap-3 pt-2">
                        <button type="button" onClick={onClose}
                            className="flex-1 px-4 py-2.5 border border-slate-200 rounded-xl text-sm font-medium text-slate-600 hover:bg-slate-50 transition-colors">
                            Cancelar
                        </button>
                        <button type="submit" disabled={saving}
                            className="flex-1 px-4 py-2.5 bg-gradient-to-r from-teal-500 to-emerald-500 text-white rounded-xl text-sm font-bold shadow-md hover:shadow-lg transition-all disabled:opacity-60">
                            {saving ? 'Guardando...' : (asociacion ? 'Actualizar' : 'Crear')}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default AsociacionesList;
