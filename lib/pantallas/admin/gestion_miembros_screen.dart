import 'dart:io';
import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:fam_intento1/services/api_service.dart';
import 'package:fam_intento1/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/widgets/admin_drawer.dart';
import 'package:fam_intento1/core/image_helper.dart';
import 'package:fam_intento1/pantallas/login.dart';
import 'package:fam_intento1/pantallas/Inicio.dart';
import 'package:fam_intento1/pantallas/public_main_screen.dart';

class GestionMiembrosScreen extends StatefulWidget {
  const GestionMiembrosScreen({super.key});

  @override
  State<GestionMiembrosScreen> createState() => _GestionMiembrosScreenState();
}

class _GestionMiembrosScreenState extends State<GestionMiembrosScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  List<dynamic> _miembros = [];
  List<dynamic> _asociaciones = [];
  List<dynamic> _filteredMiembros = [];
  final TextEditingController _searchCtrl = TextEditingController();
  String _filterState = 'activo';
  String _filterAsociacion = 'todas';

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredMiembros = _miembros.where((m) {
        // Filtro por texto
        final nombre = (m['nombre'] ?? '').toLowerCase();
        final alias = (m['alias'] ?? '').toLowerCase();
        final asoc = (m['Asociacion']?['nombre'] ?? '').toLowerCase();
        final muni = (m['municipio'] ?? '').toLowerCase();
        final matchesText = nombre.contains(query) || alias.contains(query) || asoc.contains(query) || muni.contains(query);
        
        bool matchesAsoc = true;
        if (_filterAsociacion != 'todas') {
          matchesAsoc = m['id_asociacion'].toString() == _filterAsociacion;
        }

        return matchesText && matchesAsoc;
      }).toList();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        ApiService.getAllMiembros(estado: _filterState),
        ApiService.getAllAsociaciones(),
      ]);

      final miembrosRes = futures[0];
      final asocRes = futures[1];

      if (miembrosRes['success'] == true) {
        setState(() {
          _miembros = miembrosRes['data'];
          _filteredMiembros = List.from(_miembros);
        });
      }
      if (asocRes['success'] == true) {
        setState(() {
          _asociaciones = asocRes['data'];
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false
      );
    }
  }

  void _showForm({Map<String, dynamic>? miembro}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Cerrar",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.transparent),
              ),
            ),
            Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  constraints: const BoxConstraints(maxWidth: 600, maxHeight: 850),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10)
                      )
                    ]
                  ),
                  child: MiembroForm(
                    miembro: miembro,
                    asociaciones: _asociaciones,
                    onSave: () {
                      Navigator.pop(context);
                      _loadData();
                    },
                  ),
                ),
              ),
            )
          ],
        );
      }
    );
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirmar Eliminación", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("¿Estás seguro de dar de baja este miembro?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF5350)),
            child: const Text("Dar de Baja", style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        // Asumiendo deleteUsuario o similar. En ApiService vi deleteUsuario pero el user controller es otra cosa.
        // La ruta es /miembros/:id en backend. ApiService tiene createMiembro, updateMiembro... 
        // Y deleteMiembro? 
        // Revisé ApiService en step 541. NO TIENE deleteMiembro explícito, pero tiene deleteUsuario.
        // Wait, MiembroController tiene deleteMiembro. ApiService debo verificar si tiene deleteMiembro.
        // Re-checking ApiService step 541/547.
        // Tiene create, update, getAll. NO TIENE deleteMiembro! 
        // Ups. Necesito agregar deleteMiembro a ApiService. 
        // Pero bueno, agregaré la logica aqui suponiendo que lo agregaré ahora mismo.
        final res = await ApiService.updateMiembro(id, {'estado': 'inactivo'}, null); 
        if (res['success'] == true || res['success'] == 'true') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Miembro dado de baja")));
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${res['message']}")));
        }
      } catch (e) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
        if(mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _reactivate(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirmar Reactivación", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("¿Deseas reactivar este miembro?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Reactivar", style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final res = await ApiService.updateMiembro(id, {'estado': 'activo'}, null);
        if (res['success'] == true || res['success'] == 'true') {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Miembro reactivado")));
           _loadData();
        } else {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${res['message']}")));
        }
      } catch (e) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
        if(mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: appColores.backgraund,
      drawer: const AdminDrawer(currentRoute: 'Miembros'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nuevo Miembro", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: appColores.dashTealStart))
          : Column(
            children: [
               // CUSTOM HEADER
               SizedBox(
                 height: 220,
                 child: Stack(
                   children: [
                     Container(
                       height: 180,
                       decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [appColores.dashTealStart, appColores.dashTealEnd],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30)
                          )
                       ),
                       padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 0),
                       child: Column(
                         children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                                ),
                                Row(
                                  children: [
                                    Image.asset("assets/images/famlogo.png", height: 28, color: Colors.white, errorBuilder: (_,__,___) => const SizedBox()),
                                    const SizedBox(width: 8),
                                    const Text("FAM BOLIVIA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                InkWell(
                                  onTap: _handleLogout,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                                    child: const Icon(Icons.logout, color: Colors.white, size: 20),
                                  ),
                                )
                              ],
                            ),
                         ],
                       ),
                     ),

                     Positioned(
                       bottom: 0,
                       left: 20,
                       right: 20,
                       child: Container(
                         height: 70,
                         padding: const EdgeInsets.symmetric(horizontal: 20),
                         decoration: BoxDecoration(
                           gradient: LinearGradient(
                             colors: [appColores.dashTealStart, Colors.white.withOpacity(0.85)],
                             begin: Alignment.centerLeft,
                             end: Alignment.centerRight,
                           ),
                           borderRadius: BorderRadius.circular(20),
                           boxShadow: [
                             BoxShadow(
                               color: appColores.dashTealStart.withOpacity(0.3),
                               blurRadius: 15,
                               offset: const Offset(0, 8),
                             )
                           ]
                         ),
                         child: Row(
                           children: const [
                             Expanded(
                               child: Text(
                                 "Gestión de Miembros",
                                 style: TextStyle(
                                   color: Colors.white,
                                   fontSize: 20,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                             ),
                           ],
                         ),
                       ),
                     )
                   ],
                 ),
               ),
               
               const SizedBox(height: 20),

               // SEARCH BAR
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 20),
                 child: Container(
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(15),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.grey.withOpacity(0.1),
                         blurRadius: 10,
                         offset: const Offset(0, 4)
                       )
                     ],
                     border: Border.all(color: Colors.grey.shade100)
                   ),
                   child: TextField(
                     controller: _searchCtrl,
                     decoration: InputDecoration(
                       hintText: "Buscar por nombre, municipio...",
                       hintStyle: TextStyle(color: Colors.grey.shade400),
                       prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                       border: InputBorder.none,
                       contentPadding: const EdgeInsets.symmetric(vertical: 14),
                     ),
                   ),
                 ),
                ),

                const SizedBox(height: 15),

                 // FILTROS: ESTADO + ASOCIACION
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 20),
                   child: Row(
                     children: [
                       // Filtro Estado
                       Expanded(
                         flex: 4,
                         child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12),
                           decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(10),
                             border: Border.all(color: Colors.grey.shade200)
                           ),
                           child: Row(
                             children: [
                               const Icon(Icons.check_circle_outline, size: 16, color: Colors.grey),
                               const SizedBox(width: 8),
                               Expanded(
                                 child: DropdownButtonHideUnderline(
                                   child: DropdownButton<String>(
                                     value: _filterState,
                                     isExpanded: true,
                                     style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13),
                                     icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                     items: const [
                                       DropdownMenuItem(value: 'activo', child: Text("Activos")),
                                       DropdownMenuItem(value: 'inactivo', child: Text("Inactivos")),
                                       DropdownMenuItem(value: 'todos', child: Text("Todos")),
                                     ],
                                     onChanged: (val) {
                                       if (val != null) {
                                         setState(() => _filterState = val);
                                         _loadData();
                                       }
                                     },
                                   ),
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                       const SizedBox(width: 10),
                       // Filtro Asociación
                       Expanded(
                         flex: 5,
                         child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12),
                           decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(10),
                             border: Border.all(color: Colors.grey.shade200)
                           ),
                           child: Row(
                             children: [
                               const Icon(Icons.business, size: 16, color: Colors.grey),
                               const SizedBox(width: 8),
                               Expanded(
                                 child: DropdownButtonHideUnderline(
                                   child: DropdownButton<String>(
                                     value: _filterAsociacion,
                                     isExpanded: true,
                                     style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13),
                                     icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                     items: [
                                       const DropdownMenuItem(value: 'todas', child: Text("Todas")),
                                       ..._asociaciones.map((a) => DropdownMenuItem(
                                         value: a['id'].toString(),
                                         child: Text(
                                            a['alias'] ?? (a['nombre'].toString().length > 15 ? a['nombre'].toString().substring(0, 15) + '...' : a['nombre']),
                                            overflow: TextOverflow.ellipsis,
                                         ),
                                       )),
                                     ],
                                     onChanged: (val) {
                                       if (val != null) {
                                         setState(() => _filterAsociacion = val);
                                         _filter();
                                       }
                                     },
                                   ),
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                     ],
                   ),
                 ),

                 const SizedBox(height: 15),

                // LISTA DE MIEMBROS
               Expanded(
                 child: ListView.separated(
                   padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                   itemCount: _filteredMiembros.length,
                   separatorBuilder: (ctx, i) => const SizedBox(height: 15),
                   itemBuilder: (context, index) {
                     final m = _filteredMiembros[index];
                     return _buildMiembroCard(m);
                   },
                 ),
               ),
            ],
          ),
    );
  }

  Widget _buildMiembroCard(Map<String, dynamic> m) {
    final assocName = m['Asociacion'] != null ? m['Asociacion']['nombre'] : '-';
    final isActive = (m['estado'] ?? 'activo') == 'activo';
    final tipo = (m['tipo_miembro'] ?? 'ALCALDE').toString().toUpperCase();
    final alias = m['alias'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4)
          )
        ]
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: appColores.dashTealStart.withOpacity(0.1), width: 3)
                ),
                child: ImageHelper.getCircleAvatar(
                  apiPath: m['foto'], 
                  name: m['nombre'],
                  alias: m['alias'],
                  type: 'miembro',
                  radius: 35, // Prominent size
                  municipio: m['municipio'],
                  tipoMiembro: tipo,
                  deptoName: null
                ),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m['nombre'] ?? 'Sin Nombre',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF263238)),
                    ),
                    const SizedBox(height: 4),
                    if (m['municipio'] != null)
                      Text('Municipio: ${m['municipio']}', style: const TextStyle(fontSize: 13, color: Color(0xFF546E7A))),
                    if (assocName != '-')
                      Text('Asoc: $assocName', style: const TextStyle(fontSize: 12, color: Color(0xFF90A4AE))),
                    
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildBadge(tipo, const Color(0xFFEDE7F6), const Color(0xFF673AB7)), // Deep Purple
                        _buildBadge(isActive ? "ACTIVO" : "INACTIVO", isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE), isActive ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                        if(alias.isNotEmpty)
                           _buildBadge(alias, const Color(0xFFE3F2FD), const Color(0xFF1565C0)), // Blue
                      ],
                    )
                  ],
                ),
              ),
              
              // Actions
              Column(
                children: [
                   if (isActive) ...[
                      IconButton(
                        onPressed: () => _showForm(miembro: m), 
                        icon: const Icon(Icons.edit_outlined, color: Color(0xFF29B6F6)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(height: 15),
                      IconButton(
                        onPressed: () => _delete(m['id']), 
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFEF5350)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                   ] else ...[
                      ElevatedButton.icon(
                       onPressed: () => _reactivate(m['id']), 
                       icon: const Icon(Icons.refresh, size: 16), 
                       label: const Text("Reactivar"),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.green,
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                       )
                     )
                   ]
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }
}

class MiembroForm extends StatefulWidget {
  final Map<String, dynamic>? miembro;
  final List<dynamic> asociaciones;
  final VoidCallback onSave;

  const MiembroForm({super.key, this.miembro, required this.asociaciones, required this.onSave});

  @override
  State<MiembroForm> createState() => _MiembroFormState();
}

class _MiembroFormState extends State<MiembroForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _aliasCtrl = TextEditingController();
  final _municipioCtrl = TextEditingController();
  final _telPublicoCtrl = TextEditingController();
  final _telPersonalCtrl = TextEditingController();
  final _faxCtrl = TextEditingController(); // NUEVO: campo fax
  final _emailPublicoCtrl = TextEditingController();
  final _emailPersonalCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;
  int? _selectedAsocId;
  String _estado = 'activo';
  String _tipoMiembro = 'ALCALDE';

  @override
  void initState() {
    super.initState();
    if (widget.miembro != null) {
      final m = widget.miembro!;
      _nombreCtrl.text = m['nombre'] ?? '';
      _aliasCtrl.text = m['alias'] ?? '';
      _municipioCtrl.text = m['municipio'] ?? '';
      _telPublicoCtrl.text = m['telefono_publico'] ?? '';
      _telPersonalCtrl.text = m['telefono_personal'] ?? '';
      _faxCtrl.text = m['telefono_fax'] ?? ''; // NUEVO: cargar fax
      _emailPublicoCtrl.text = m['correo_publico'] ?? '';
      _emailPersonalCtrl.text = m['correo_personal'] ?? '';
      _direccionCtrl.text = m['direccion'] ?? '';
      _selectedAsocId = m['id_asociacion'];
      if (widget.asociaciones.isNotEmpty && !widget.asociaciones.any((a) => a['id'] == _selectedAsocId)) {
        _selectedAsocId = null;
      }
      _estado = m['estado'] ?? 'activo';
      _tipoMiembro = (m['tipo_miembro'] ?? 'ALCALDE').toString().toUpperCase();
      if (_tipoMiembro.contains('CONCEJAL')) _tipoMiembro = 'CONCEJALA'; // <--- CORREGIDO AQUÍ
    } else if (widget.asociaciones.isNotEmpty) {
      _selectedAsocId = widget.asociaciones.first['id'];
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imageFile = File(image.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAsocId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Seleccione una asociación")));
      return;
    }
    setState(() => _isSaving = true);

    try {
      final data = {
        'nombre': _nombreCtrl.text,
        'alias': _aliasCtrl.text,
        'municipio': _municipioCtrl.text,
        'telefono_publico': _telPublicoCtrl.text,
        'telefono_personal': _telPersonalCtrl.text,
        'telefono_fax': _faxCtrl.text, // NUEVO: enviar fax
        'correo_publico': _emailPublicoCtrl.text,
        'correo_personal': _emailPersonalCtrl.text,
        'direccion': _direccionCtrl.text,
        'id_asociacion': _selectedAsocId.toString(),
        'estado': _estado,
        'tipo_miembro': _tipoMiembro,
      };

      Map<String, dynamic> res;
      if (widget.miembro == null) {
        res = await ApiService.createMiembro(data, _imageFile?.path);
      } else {
        res = await ApiService.updateMiembro(widget.miembro!['id'], data, _imageFile?.path);
      }

      if (res['success']) widget.onSave();
      else if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));

    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if(mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // FIXED HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.miembro == null ? "Nuevo Miembro" : "Editar Miembro",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87),
                  ),
                   const SizedBox(height: 5),
                  Text(
                    "Actualiza la información del miembro",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
             Container(
              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
         const SizedBox(height: 20),

        // SCROLLABLE BODY
        Expanded(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Imagen
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                         Container(
                           decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200, width: 4),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                              ]
                           ),
                           child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: _imageFile != null 
                              ? Image.file(_imageFile!, width: 100, height: 100, fit: BoxFit.cover)
                              : (widget.miembro != null
                                  ? ImageHelper.getCircleAvatar(
                                      apiPath: widget.miembro!['foto'],
                                      name: widget.miembro!['nombre'],
                                      alias: widget.miembro!['alias'],
                                      type: 'miembro',
                                      radius: 50,
                                      municipio: widget.miembro!['municipio'],
                                      tipoMiembro: widget.miembro!['tipo_miembro'],
                                      deptoName: null,
                                    )
                                  : const Icon(Icons.camera_alt, size: 40, color: Colors.blue)),
                            ),
                           ),
                         ),
                         Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  _buildSection("Información Principal"),
                  DropdownButtonFormField<int>(
                    value: _selectedAsocId,
                    isExpanded: true,
                    menuMaxHeight: 400,
                    items: widget.asociaciones.map<DropdownMenuItem<int>>((a) => DropdownMenuItem(
                      value: a['id'], 
                      child: Text(a['nombre'], softWrap: true, style: const TextStyle(fontSize: 13)),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedAsocId = v),
                    decoration: _inputDec("Asociación"),
                  ),
                  const SizedBox(height: 12),
                   _buildTextField(_nombreCtrl, "Nombre Completo", validator: (v) => v!.isEmpty ? 'Req' : null),
                  const SizedBox(height: 12),
                  Row(children: [
                     Expanded(child: _buildTextField(_aliasCtrl, "Alias / Partido")),
                     const SizedBox(width: 10),
                     Expanded(child: _buildTextField(_municipioCtrl, "Municipio")),
                  ]),

                  const SizedBox(height: 20),
                   _buildSection("Contacto Público"),
                   Row(children: [
                     Expanded(child: _buildTextField(_telPublicoCtrl, "Tel. Público")),
                     const SizedBox(width: 8),
                     Expanded(child: _buildTextField(_faxCtrl, "Fax")), // NUEVO: campo fax
                   ]),
                   const SizedBox(height: 12),
                   Row(children: [
                     Expanded(child: _buildTextField(_emailPublicoCtrl, "Email Público")),
                   ]),
                   const SizedBox(height: 12),
                   _buildTextField(_direccionCtrl, "Dirección Institucional"),

                  const SizedBox(height: 20),
                  _buildSection("Privado (Admin/FAM)"),
                   Row(children: [
                    Expanded(child: _buildTextField(_telPersonalCtrl, "Celular Personal")),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTextField(_emailPersonalCtrl, "Email Personal")),
                  ]),

                  const SizedBox(height: 20),
                  _buildSection("Estado y Tipo"),
                  DropdownButtonFormField<String>(
                    value: _tipoMiembro,
                    items: ['ALCALDE', 'CONCEJALA', 'AMBES'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), // <--- CORREGIDO AQUÍ
                    onChanged: (v) => setState(() => _tipoMiembro = v!),
                    decoration: _inputDec("Tipo"),
                  ),

                  // Bottom space for consistent scrolling
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),

        // FIXED BOTTOM BUTTONS
        const SizedBox(height: 15),
         SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43A047), // Green
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: _isSaving 
                ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Guardar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
           const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), foregroundColor: Colors.grey),
              child: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
      ],
    );
  }

  InputDecoration _inputDec(String label) => InputDecoration(
    labelText: label,
    hintText: label,
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    floatingLabelStyle: const TextStyle(color: Colors.blue)
  );

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(color: Color(0xFF37474F), fontWeight: FontWeight.bold, fontSize: 16))),
    );
  }
   Widget _buildTextField(TextEditingController ctrl, String label, {String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      decoration: _inputDec(label),
      validator: validator,
    );
  }


}
