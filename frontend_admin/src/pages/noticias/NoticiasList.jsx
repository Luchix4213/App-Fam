import { useState, useEffect } from 'react';
import api from '../../services/api';
import { Plus, Pencil, Trash2, RotateCcw, Search, X, Upload, Newspaper } from 'lucide-react';

const API_BASE = 'https://api-fambolivia.onrender.com';

const NoticiasList = () => {
    const [data, setData] = useState([]);
    const [filtered, setFiltered] = useState([]);
    const [search, setSearch] = useState('');
    const [loading, setLoading] = useState(true);
    const [showForm, setShowForm] = useState(false);
    const [editing, setEditing] = useState(null);
    const [filterEstado, setFilterEstado] = useState('activo');

    const fetchData = async () => {
        setLoading(true);
        try { const res = await api.get('/noticias'); setData(Array.isArray(res.data) ? res.data : (res.data?.data || [])); } catch (e) { console.error(e); }
        setLoading(false);
    };

    useEffect(() => { fetchData(); }, []);

    useEffect(() => {
        let list = data;
        if (filterEstado === 'activo') list = list.filter(n => n.activa !== false && n.activa !== 'false');
        if (filterEstado === 'inactivo') list = list.filter(n => n.activa === false || n.activa === 'false');
        if (search) {
            const q = search.toLowerCase();
            list = list.filter(n => (n.titulo || '').toLowerCase().includes(q) || (n.descripcion || '').toLowerCase().includes(q));
        }
        setFiltered(list);
    }, [data, search, filterEstado]);

    const handleDelete = async (id) => {
        if (!confirm('¿Deseas desactivar esta noticia?')) return;
        try { await api.delete(`/noticias/${id}`); fetchData(); } catch (e) { alert('Error'); }
    };
    const handleReactivate = async (id) => {
        try { await api.put(`/noticias/${id}`, { activa: true }); fetchData(); } catch (e) { alert('Error'); }
    };

    return (
        <div>
            <div className="flex flex-col sm:flex-row sm:items-center justify-between mb-6 gap-4">
                <div><h1 className="text-2xl font-bold text-slate-800">Noticias</h1><p className="text-slate-500 text-sm mt-1">Gestión de noticias y anuncios</p></div>
                <button onClick={() => { setEditing(null); setShowForm(true); }} className="flex items-center gap-2 bg-gradient-to-r from-teal-500 to-emerald-500 text-white px-5 py-2.5 rounded-xl font-medium shadow-md hover:shadow-lg transform hover:scale-[1.02] transition-all">
                    <Plus size={18} /> Nueva Noticia
                </button>
            </div>

            <div className="bg-white rounded-2xl p-4 shadow-sm border border-slate-100 mb-6 flex flex-col sm:flex-row gap-3">
                <div className="relative flex-1">
                    <Search size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                    <input type="text" placeholder="Buscar por título o descripción..." value={search} onChange={e => setSearch(e.target.value)}
                        className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 focus:border-teal-500 outline-none transition" />
                </div>
                <select value={filterEstado} onChange={e => setFilterEstado(e.target.value)}
                    className="px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 outline-none">
                    <option value="">Todos los estados</option>
                    <option value="activo">Solo Activas</option>
                    <option value="inactivo">Solo Inactivas</option>
                </select>
            </div>

            {loading ? (
                <div className="text-center py-20"><div className="w-8 h-8 border-4 border-teal-500 border-t-transparent rounded-full animate-spin mx-auto"></div></div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {filtered.map(n => (
                        <div key={n.id} className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden hover:shadow-md transition-shadow group">
                            {n.imagen_url ? (
                                <div className="h-40 overflow-hidden">
                                    <img src={n.imagen_url.startsWith('http') ? n.imagen_url : `${API_BASE}${n.imagen_url}`}
                                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" alt="" />
                                </div>
                            ) : (
                                <div className="h-40 bg-gradient-to-br from-slate-100 to-slate-200 flex items-center justify-center">
                                    <Newspaper size={40} className="text-slate-300" />
                                </div>
                            )}
                            <div className="p-5">
                                <div className="flex items-start justify-between gap-2 mb-2">
                                    <h3 className="font-bold text-slate-800 text-sm line-clamp-2">{n.titulo}</h3>
                                    <span className={`px-2 py-0.5 rounded-full text-[10px] font-semibold whitespace-nowrap
                    ${(n.activa === false || n.activa === 'false') ? 'bg-red-50 text-red-600' : 'bg-emerald-50 text-emerald-600'}`}>
                                        {(n.activa === false || n.activa === 'false') ? 'Inactiva' : 'Activa'}
                                    </span>
                                </div>
                                <p className="text-xs text-slate-400 line-clamp-3 mb-4">{n.descripcion || 'Sin descripción'}</p>
                                <div className="flex gap-2">
                                    <button onClick={() => { setEditing(n); setShowForm(true); }} className="flex-1 flex items-center justify-center gap-1 px-3 py-2 bg-blue-50 text-blue-600 rounded-xl text-xs font-semibold hover:bg-blue-100 transition-colors">
                                        <Pencil size={14} /> Editar
                                    </button>
                                    {(n.activa === false || n.activa === 'false') ? (
                                        <button onClick={() => handleReactivate(n.id)} className="flex-1 flex items-center justify-center gap-1 px-3 py-2 bg-emerald-50 text-emerald-600 rounded-xl text-xs font-semibold hover:bg-emerald-100 transition-colors">
                                            <RotateCcw size={14} /> Reactivar
                                        </button>
                                    ) : (
                                        <button onClick={() => handleDelete(n.id)} className="flex-1 flex items-center justify-center gap-1 px-3 py-2 bg-red-50 text-red-600 rounded-xl text-xs font-semibold hover:bg-red-100 transition-colors">
                                            <Trash2 size={14} /> Desactivar
                                        </button>
                                    )}
                                </div>
                            </div>
                        </div>
                    ))}
                    {filtered.length === 0 && (
                        <div className="col-span-full text-center py-20 text-slate-400">No se encontraron noticias</div>
                    )}
                </div>
            )}

            {showForm && <NoticiaForm noticia={editing} onClose={() => setShowForm(false)} onSaved={() => { setShowForm(false); fetchData(); }} />}
        </div>
    );
};

const NoticiaForm = ({ noticia, onClose, onSaved }) => {
    const [titulo, setTitulo] = useState(noticia?.titulo || '');
    const [descripcion, setDescripcion] = useState(noticia?.descripcion || '');
    const [imageFile, setImageFile] = useState(null);
    const [preview, setPreview] = useState(noticia?.imagen_url ? (noticia.imagen_url.startsWith('http') ? noticia.imagen_url : `${API_BASE}${noticia.imagen_url}`) : null);
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState('');

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!titulo.trim()) { setError('El título es obligatorio'); return; }
        if (!noticia && !imageFile) { setError('Debes subir una imagen para la noticia'); return; }
        setSaving(true); setError('');
        try {
            const fd = new FormData();
            fd.append('titulo', titulo); fd.append('descripcion', descripcion);
            fd.append('activa', noticia ? String(noticia.activa) : 'true');
            if (imageFile) fd.append('foto', imageFile);
            if (noticia) await api.put(`/noticias/${noticia.id}`, fd, { headers: { 'Content-Type': 'multipart/form-data' } });
            else await api.post('/noticias', fd, { headers: { 'Content-Type': 'multipart/form-data' } });
            onSaved();
        } catch (err) { setError(err.response?.data?.message || 'Error al guardar'); }
        setSaving(false);
    };

    return (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-[60] p-4" onClick={onClose}>
            <div className="bg-white rounded-2xl w-full max-w-lg shadow-2xl max-h-[90vh] overflow-y-auto" onClick={e => e.stopPropagation()}>
                <div className="flex items-center justify-between p-6 border-b border-slate-100">
                    <h3 className="text-lg font-bold text-slate-800">{noticia ? 'Editar Noticia' : 'Nueva Noticia'}</h3>
                    <button onClick={onClose} className="p-2 hover:bg-slate-100 rounded-lg"><X size={18} /></button>
                </div>
                <form onSubmit={handleSubmit} className="p-6 space-y-4">
                    {error && <div className="bg-red-50 text-red-600 p-3 rounded-xl text-sm">{error}</div>}
                    <div><label className="block text-sm font-medium text-slate-700 mb-1.5">Título *</label><input type="text" value={titulo} onChange={e => setTitulo(e.target.value)} required className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 outline-none" /></div>
                    <div><label className="block text-sm font-medium text-slate-700 mb-1.5">Descripción</label><textarea value={descripcion} onChange={e => setDescripcion(e.target.value)} rows={4} className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500 outline-none resize-none" /></div>
                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1.5">Imagen {!noticia && '*'}</label>
                        <div className="border-2 border-dashed border-slate-200 rounded-xl p-4 text-center hover:border-teal-400 transition-colors">
                            {preview ? <div className="relative inline-block"><img src={preview} alt="" className="w-full max-h-40 object-cover rounded-xl mx-auto" /><button type="button" onClick={() => { setPreview(null); setImageFile(null) }} className="absolute top-1 right-1 bg-red-500 text-white rounded-full w-5 h-5 flex items-center justify-center text-xs"><X size={10} /></button></div>
                                : <label className="cursor-pointer block"><Upload size={28} className="mx-auto text-slate-300 mb-1" /><p className="text-sm text-slate-400">Click para subir imagen</p><input type="file" accept="image/*" onChange={e => { const f = e.target.files[0]; if (f) { setImageFile(f); setPreview(URL.createObjectURL(f)) } }} className="hidden" /></label>}
                            {preview && <label className="cursor-pointer block mt-2 text-sm text-teal-600 font-medium">Cambiar imagen<input type="file" accept="image/*" onChange={e => { const f = e.target.files[0]; if (f) { setImageFile(f); setPreview(URL.createObjectURL(f)) } }} className="hidden" /></label>}
                        </div>
                    </div>
                    <div className="flex gap-3 pt-2">
                        <button type="button" onClick={onClose} className="flex-1 px-4 py-2.5 border border-slate-200 rounded-xl text-sm font-medium text-slate-600 hover:bg-slate-50">Cancelar</button>
                        <button type="submit" disabled={saving} className="flex-1 px-4 py-2.5 bg-gradient-to-r from-teal-500 to-emerald-500 text-white rounded-xl text-sm font-bold shadow-md disabled:opacity-60">{saving ? 'Guardando...' : (noticia ? 'Actualizar' : 'Crear')}</button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default NoticiasList;
