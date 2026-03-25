import { useState, useEffect } from 'react';
import api from '../../services/api';
import { Plus, Pencil, Trash2, RotateCcw, Search, X, Upload, Users as UsersIcon } from 'lucide-react';

const API_BASE = 'https://api-fambolivia.onrender.com';

const MiembrosList = () => {
    const [data, setData] = useState([]);
    const [asociaciones, setAsociaciones] = useState([]);
    const [filtered, setFiltered] = useState([]);
    const [search, setSearch] = useState('');
    const [filterAsoc, setFilterAsoc] = useState('');
    const [loading, setLoading] = useState(true);
    const [showForm, setShowForm] = useState(false);
    const [editing, setEditing] = useState(null);
    const [filterEstado, setFilterEstado] = useState('activo');

    const fetchData = async () => {
        setLoading(true);
        try {
            let url = '/miembros';
            if (filterEstado === 'activo') {
                url = '/miembros?estado=activo';
            }
            if (filterEstado === 'inactivo') {
                url = '/miembros?estado=inactivo';
            }
            const [mRes, aRes] = await Promise.all([api.get(url), api.get('/asociaciones')]);
            setData(Array.isArray(mRes.data) ? mRes.data : (mRes.data?.data || []));
            setAsociaciones(Array.isArray(aRes.data) ? aRes.data : (aRes.data?.data || []));
        } catch (e) { console.error(e); }
        setLoading(false);
    };

    useEffect(() => { fetchData(); }, [filterEstado]);

    useEffect(() => {
        let list = [...data];
        if (filterEstado === 'activo') {
            list = list.filter(m => String(m.estado).toLowerCase().trim() === 'activo' || !m.estado);
        }
        if (filterEstado === 'inactivo') {
            list = list.filter(m => String(m.estado).toLowerCase().trim() === 'inactivo');
        }
        if (filterAsoc) list = list.filter(m => String(m.id_asociacion) === filterAsoc);
        if (search) {
            const q = search.toLowerCase();
            list = list.filter(m =>
                (m.nombre || '').toLowerCase().includes(q) ||
                (m.alias || '').toLowerCase().includes(q) ||
                (m.municipio || '').toLowerCase().includes(q)
            );
        }
        setFiltered(list);
    }, [data, search, filterAsoc, filterEstado]);

    const handleDelete = async (id) => {
        if (!confirm('¿Deseas desactivar este miembro?')) return;
        try { await api.put(`/miembros/${id}`, { estado: 'inactivo' }); fetchData(); } catch (e) { alert('Error al desactivar'); }
    };

    const handleReactivate = async (id) => {
        try { await api.put(`/miembros/${id}`, { estado: 'activo' }); fetchData(); } catch (e) { alert('Error al reactivar'); }
    };

    const getAsocName = (id) => asociaciones.find(a => a.id === id)?.alias || asociaciones.find(a => a.id === id)?.nombre || '—';

    return (
        <div>
            <div className="flex flex-col sm:flex-row sm:items-center justify-between mb-6 gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Miembros</h1>
                    <p className="text-slate-500 text-sm mt-1">Gestión de miembros de las asociaciones</p>
                </div>
                <button onClick={() => { setEditing(null); setShowForm(true); }}
                    className="flex items-center gap-2 bg-gradient-to-r from-teal-500 to-emerald-500 text-white px-5 py-2.5 rounded-xl font-medium shadow-md hover:shadow-lg transform hover:scale-[1.02] transition-all">
                    <Plus size={18} /> Nuevo Miembro
                </button>
            </div>

            {/* Filters */}
            <div className="bg-white rounded-2xl p-4 shadow-sm border border-slate-100 mb-6 flex flex-col sm:flex-row gap-3">
                <div className="relative flex-1">
                    <Search size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                    <input type="text" placeholder="Buscar por nombre, alias o municipio..." value={search} onChange={e => setSearch(e.target.value)}
                        className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 focus:border-teal-500 outline-none transition" />
                </div>
                <select value={filterAsoc} onChange={e => setFilterAsoc(e.target.value)}
                    className="px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 outline-none">
                    <option value="">Todas las asociaciones</option>
                    {asociaciones.filter(a => a.estado !== 'inactivo').map(a => <option key={a.id} value={a.id}>{a.alias || a.nombre}</option>)}
                </select>
                <select value={filterEstado} onChange={e => setFilterEstado(e.target.value)}
                    className="px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 outline-none">
                    <option value="">Todos los estados</option>
                    <option value="activo">Solo Activos</option>
                    <option value="inactivo">Solo Inactivos</option>
                </select>
            </div>

            {/* Table */}
            {loading ? (
                <div className="text-center py-20"><div className="w-8 h-8 border-4 border-teal-500 border-t-transparent rounded-full animate-spin mx-auto"></div></div>
            ) : (
                <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead>
                                <tr className="bg-slate-50 border-b border-slate-100">
                                    <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase">Miembro</th>
                                    <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase">Municipio</th>
                                    <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase">Asociación</th>
                                    <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase">Tipo</th>
                                    <th className="text-left p-4 text-xs font-semibold text-slate-500 uppercase">Estado</th>
                                    <th className="text-right p-4 text-xs font-semibold text-slate-500 uppercase">Acciones</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {filtered.map(m => (
                                    <tr key={m.id} className="hover:bg-slate-50/50 transition-colors">
                                        <td className="p-4">
                                            <div className="flex items-center gap-3">
                                                {m.foto ? (
                                                    <img src={m.foto.startsWith('http') ? m.foto : `${API_BASE}${m.foto}`}
                                                        className="w-10 h-10 rounded-full object-cover border border-slate-200" alt="" />
                                                ) : (
                                                    <div className="w-10 h-10 bg-gradient-to-br from-teal-400 to-emerald-500 rounded-full flex items-center justify-center text-white font-bold text-sm">
                                                        {(m.nombre || '?')[0]?.toUpperCase()}
                                                    </div>
                                                )}
                                                <div>
                                                    <p className="font-medium text-slate-700 text-sm">{m.nombre || 'Sin nombre'}</p>
                                                    {m.alias && <p className="text-xs text-slate-400">{m.alias}</p>}
                                                </div>
                                            </div>
                                        </td>
                                        <td className="p-4 text-sm text-slate-500">{m.municipio || '—'}</td>
                                        <td className="p-4 text-sm text-slate-500">{getAsocName(m.id_asociacion)}</td>
                                        <td className="p-4"><span className="px-2 py-1 bg-indigo-50 text-indigo-600 rounded-lg text-xs font-semibold">{m.tipo_miembro || '—'}</span></td>
                                        <td className="p-4">
                                            <span className={`px-3 py-1 rounded-full text-xs font-semibold ${String(m.estado).toLowerCase().trim() === 'inactivo' ? 'bg-red-50 text-red-600' : 'bg-emerald-50 text-emerald-600'}`}>
                                                {String(m.estado).toLowerCase().trim() === 'inactivo' ? 'Inactivo' : 'Activo'}
                                            </span>
                                        </td>
                                        <td className="p-4">
                                            <div className="flex items-center justify-end gap-2">
                                                <button onClick={() => { setEditing(m); setShowForm(true); }} className="p-2 rounded-lg text-slate-400 hover:text-blue-600 hover:bg-blue-50 transition-colors"><Pencil size={16} /></button>
                                                {String(m.estado).toLowerCase().trim() === 'inactivo' ? (
                                                    <button onClick={() => handleReactivate(m.id)} className="p-2 rounded-lg text-slate-400 hover:text-emerald-600 hover:bg-emerald-50 transition-colors"><RotateCcw size={16} /></button>
                                                ) : (
                                                    <button onClick={() => handleDelete(m.id)} className="p-2 rounded-lg text-slate-400 hover:text-red-600 hover:bg-red-50 transition-colors"><Trash2 size={16} /></button>
                                                )}
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                                {filtered.length === 0 && <tr><td colSpan={6} className="p-10 text-center text-slate-400">No se encontraron miembros</td></tr>}
                            </tbody>
                        </table>
                    </div>
                </div>
            )}

            {showForm && (
                <MiembroForm miembro={editing} asociaciones={asociaciones} onClose={() => setShowForm(false)}
                    onSaved={() => { setShowForm(false); fetchData(); }} />
            )}
        </div>
    );
};

/* ===== FORM MODAL ===== */
const MiembroForm = ({ miembro, asociaciones, onClose, onSaved }) => {
    const [form, setForm] = useState({
        nombre: miembro?.nombre || '', alias: miembro?.alias || '', municipio: miembro?.municipio || '',
        telefono_publico: miembro?.telefono_publico || '', telefono_personal: miembro?.telefono_personal || '',
        telefono_fax: miembro?.telefono_fax || '', correo_publico: miembro?.correo_publico || '',
        correo_personal: miembro?.correo_personal || '', direccion: miembro?.direccion || '',
        id_asociacion: miembro?.id_asociacion || (asociaciones[0]?.id || ''),
        tipo_miembro: miembro?.tipo_miembro || 'ALCALDE',
    });
    const [imageFile, setImageFile] = useState(null);
    const [preview, setPreview] = useState(miembro?.foto ? (miembro.foto.startsWith('http') ? miembro.foto : `${API_BASE}${miembro.foto}`) : null);
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState('');

    const update = (key, val) => setForm(prev => ({ ...prev, [key]: val }));

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!form.nombre.trim()) { setError('El nombre es obligatorio'); return; }
        setSaving(true); setError('');
        try {
            const fd = new FormData();
            Object.entries(form).forEach(([k, v]) => fd.append(k, v));
            fd.append('estado', miembro?.estado || 'activo');
            if (imageFile) fd.append('foto', imageFile);
            if (miembro) await api.put(`/miembros/${miembro.id}`, fd, { headers: { 'Content-Type': 'multipart/form-data' } });
            else await api.post('/miembros', fd, { headers: { 'Content-Type': 'multipart/form-data' } });
            onSaved();
        } catch (err) { setError(err.response?.data?.message || 'Error al guardar'); }
        setSaving(false);
    };

    return (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-[60] p-4" onClick={onClose}>
            <div className="bg-white rounded-2xl w-full max-w-2xl shadow-2xl max-h-[90vh] overflow-y-auto" onClick={e => e.stopPropagation()}>
                <div className="flex items-center justify-between p-6 border-b border-slate-100">
                    <h3 className="text-lg font-bold text-slate-800">{miembro ? 'Editar Miembro' : 'Nuevo Miembro'}</h3>
                    <button onClick={onClose} className="p-2 hover:bg-slate-100 rounded-lg"><X size={18} /></button>
                </div>
                <form onSubmit={handleSubmit} className="p-6 space-y-4">
                    {error && <div className="bg-red-50 text-red-600 p-3 rounded-xl text-sm">{error}</div>}

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <Field label="Nombre *" value={form.nombre} onChange={v => update('nombre', v)} required />
                        <Field label="Alias / Partido" value={form.alias} onChange={v => update('alias', v)} />
                        <Field label="Municipio" value={form.municipio} onChange={v => update('municipio', v)} />
                        <div>
                            <label className="block text-sm font-medium text-slate-700 mb-1.5">Asociación *</label>
                            <select value={form.id_asociacion} onChange={e => update('id_asociacion', e.target.value)}
                                className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 outline-none">
                                {asociaciones.filter(a => a.estado !== 'inactivo').map(a => <option key={a.id} value={a.id}>{a.alias || a.nombre}</option>)}
                            </select>
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-slate-700 mb-1.5">Tipo de Miembro</label>
                            <select value={form.tipo_miembro} onChange={e => update('tipo_miembro', e.target.value)}
                                className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 outline-none">
                                {['ALCALDE', 'ALCALDESA', 'CONCEJALA', 'CONCEJAL', 'ASAMBLEISTA', 'OTRO'].map(t => <option key={t} value={t}>{t}</option>)}
                            </select>
                        </div>
                        <Field label="Teléfono Público" value={form.telefono_publico} onChange={v => update('telefono_publico', v)} />
                        <Field label="Teléfono Personal" value={form.telefono_personal} onChange={v => update('telefono_personal', v)} />
                        <Field label="Fax" value={form.telefono_fax} onChange={v => update('telefono_fax', v)} />
                        <Field label="Correo Público" value={form.correo_publico} onChange={v => update('correo_publico', v)} />
                        <Field label="Correo Personal" value={form.correo_personal} onChange={v => update('correo_personal', v)} />
                    </div>
                    <Field label="Dirección" value={form.direccion} onChange={v => update('direccion', v)} />

                    {/* Image */}
                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1.5">Foto</label>
                        <div className="border-2 border-dashed border-slate-200 rounded-xl p-4 text-center hover:border-teal-400 transition-colors">
                            {preview ? (
                                <div className="relative inline-block">
                                    <img src={preview} alt="Preview" className="w-20 h-20 object-cover rounded-full mx-auto" />
                                    <button type="button" onClick={() => { setPreview(null); setImageFile(null); }}
                                        className="absolute -top-1 -right-1 bg-red-500 text-white rounded-full w-5 h-5 flex items-center justify-center text-xs"><X size={10} /></button>
                                </div>
                            ) : (
                                <label className="cursor-pointer block">
                                    <Upload size={28} className="mx-auto text-slate-300 mb-1" />
                                    <p className="text-sm text-slate-400">Click para subir foto</p>
                                    <input type="file" accept="image/*" onChange={e => { const f = e.target.files[0]; if (f) { setImageFile(f); setPreview(URL.createObjectURL(f)) } }} className="hidden" />
                                </label>
                            )}
                            {preview && <label className="cursor-pointer block mt-2 text-sm text-teal-600 font-medium">Cambiar<input type="file" accept="image/*" onChange={e => { const f = e.target.files[0]; if (f) { setImageFile(f); setPreview(URL.createObjectURL(f)) } }} className="hidden" /></label>}
                        </div>
                    </div>

                    <div className="flex gap-3 pt-2">
                        <button type="button" onClick={onClose} className="flex-1 px-4 py-2.5 border border-slate-200 rounded-xl text-sm font-medium text-slate-600 hover:bg-slate-50">Cancelar</button>
                        <button type="submit" disabled={saving} className="flex-1 px-4 py-2.5 bg-gradient-to-r from-teal-500 to-emerald-500 text-white rounded-xl text-sm font-bold shadow-md disabled:opacity-60">
                            {saving ? 'Guardando...' : (miembro ? 'Actualizar' : 'Crear')}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

const Field = ({ label, value, onChange, required }) => (
    <div>
        <label className="block text-sm font-medium text-slate-700 mb-1.5">{label}</label>
        <input type="text" value={value} onChange={e => onChange(e.target.value)} required={required}
            className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 focus:border-teal-500 outline-none transition" />
    </div>
);

export default MiembrosList;
