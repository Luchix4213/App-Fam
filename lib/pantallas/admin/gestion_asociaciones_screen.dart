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

class GestionAsociacionesScreen extends StatefulWidget {
  const GestionAsociacionesScreen({super.key});

  @override
  State<GestionAsociacionesScreen> createState() => _GestionAsociacionesScreenState();
}

class _GestionAsociacionesScreenState extends State<GestionAsociacionesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  List<dynamic> _asociaciones = [];
  List<dynamic> _filteredAsociaciones = [];
  final TextEditingController _searchCtrl = TextEditingController();
  String _filterState = 'activo';

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
      _filteredAsociaciones = _asociaciones.where((a) {
        final nombre = (a['nombre'] ?? '').toLowerCase();
        final alias = (a['alias'] ?? '').toLowerCase();
        return nombre.contains(query) || alias.contains(query);
      }).toList();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final asocRes = await ApiService.getAllAsociaciones(estado: _filterState);

      if (asocRes['success'] == true) {
        setState(() {
          _asociaciones = asocRes['data'];
          _filteredAsociaciones = List.from(_asociaciones);
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

  void _showForm({Map<String, dynamic>? asociacion}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // Allow clicking outside to close
      barrierLabel: "Cerrar",
      barrierColor: Colors.black.withOpacity(0.5), // Semi-transparent overlay
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Stack(
          children: [
            // Blur Effect
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.transparent),
              ),
            ),
            // Modal Content
            Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  constraints: const BoxConstraints(maxWidth: 600, maxHeight: 850), // Wider max width
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25), // Rounded
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10)
                      )
                    ]
                  ),
                  child: AsociacionForm(
                    asociacion: asociacion,
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
        content: const Text("¿Estás seguro de dar de baja esta asociación?"),
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
        final res = await ApiService.updateAsociacion(id, {'estado': 'inactivo'}, null);
        if (res['success'] == true || res['success'] == 'true') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Asociación dada de baja")));
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
        content: const Text("¿Deseas reactivar esta asociación?"),
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
        final res = await ApiService.updateAsociacion(id, {'estado': 'activo'}, null);
        if (res['success'] == true || res['success'] == 'true') { // A veces el String return 
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Asociación reactivada")));
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
      drawer: const AdminDrawer(currentRoute: 'Asociaciones'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nueva Asociación", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                     // 1. Gradient Background
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

                     // 2. Title Card
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
                                 "Gestión de Asociaciones",
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
                       hintText: "Buscar por nombre o alias...",
                       hintStyle: TextStyle(color: Colors.grey.shade400),
                       prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                       border: InputBorder.none,
                       contentPadding: const EdgeInsets.symmetric(vertical: 14),
                     ),
                   ),
                 ),
               ),

                const SizedBox(height: 15),

                // FILTRO ESTADO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text("Estado: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: _filterState,
                        underline: Container(), // clean look
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
                        }
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 15),

               // LISTA DE ASOCIACIONES
               Expanded(
                 child: ListView.separated(
                   padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                   itemCount: _filteredAsociaciones.length,
                   separatorBuilder: (ctx, i) => const SizedBox(height: 15),
                   itemBuilder: (context, index) {
                     final a = _filteredAsociaciones[index];
                     return _buildAsociacionCard(a);
                   },
                 ),
               ),
            ],
          ),
    );
  }

  Widget _buildAsociacionCard(Map<String, dynamic> a) {
    final estado = (a['estado'] ?? 'ACTIVO').toString().toUpperCase();
    final isActive = estado == 'ACTIVO';

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
          padding: const EdgeInsets.all(16.0), // Generous padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Container(
                 padding: const EdgeInsets.all(2), // Border space
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   border: Border.all(color: appColores.dashTealStart.withOpacity(0.2), width: 2)
                 ),
                 child: ImageHelper.getCircleAvatar(
                    apiPath: a['foto'], 
                    name: a['nombre'], 
                    alias: a['alias'], 
                    type: 'asociacion',
                    radius: 28 // Slightly larger
                  ),
              ),
              const SizedBox(width: 15),
              
              // Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        a['nombre'] ?? 'Sin Nombre',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF263238)),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildBadge(
                            estado, 
                          isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), 
                          isActive ? Colors.green.shade700 : Colors.red.shade700
                        ),
                      ],
                    )
                  ],
                ),
              ),
              
              // Actions Section
              Column(
                children: [
                   if (isActive) ...[
                      IconButton(
                        onPressed: () => _showForm(asociacion: a),
                        icon: const Icon(Icons.edit_outlined, color: Color(0xFF29B6F6)),
                        tooltip: "Editar",
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(height: 15),
                      IconButton(
                        onPressed: () => _delete(a['id']),
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFEF5350)),
                        tooltip: "Eliminar",
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                   ] else ...[
                      ElevatedButton.icon(
                       onPressed: () => _reactivate(a['id']), 
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
      child: Text(
        text, 
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)
      ),
    );
  }
}

class AsociacionForm extends StatefulWidget {
  final Map<String, dynamic>? asociacion;
  final VoidCallback onSave;

  const AsociacionForm({super.key, this.asociacion, required this.onSave});

  @override
  State<AsociacionForm> createState() => _AsociacionFormState();
}

class _AsociacionFormState extends State<AsociacionForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _aliasCtrl = TextEditingController();
  
  String _estado = 'ACTIVO';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.asociacion != null) {
      final a = widget.asociacion!;
      _nombreCtrl.text = a['nombre'] ?? '';
      _aliasCtrl.text = a['alias'] ?? '';
      _estado = (a['estado'] ?? 'ACTIVO').toString().toUpperCase();
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imageFile = File(image.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    try {
      final data = {
        'nombre': _nombreCtrl.text,
        'alias': _aliasCtrl.text,
        'estado': _estado.toLowerCase(),
      };
      
       Map<String, dynamic> res;
      if (widget.asociacion == null) {
        res = await ApiService.createAsociacion(data, _imageFile?.path);
      } else {
        res = await ApiService.updateAsociacion(widget.asociacion!['id'], data, _imageFile?.path);
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
      mainAxisSize: MainAxisSize.min,
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
                    widget.asociacion == null ? "Nueva Asociación" : "Editar Asociación",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Actualiza la información completa de la asociación",
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
        
        // SCROLLABLE CONTENT
        Flexible(
          fit: FlexFit.loose,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen Circular + FAB
                  Center(
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
                                  : (widget.asociacion != null
                                      ? ImageHelper.getCircleAvatar(
                                          apiPath: widget.asociacion!['foto'],
                                          name: widget.asociacion!['nombre'],
                                          alias: widget.asociacion!['alias'],
                                          type: 'asociacion',
                                          radius: 50
                                        )
                                      : const Icon(Icons.camera_alt, size: 40, color: Colors.blue)),
                             ),
                           ),
                         ),
                         Positioned(
                           bottom: 0,
                           right: 0,
                           child: GestureDetector(
                             onTap: _pickImage,
                             child: Container(
                               padding: const EdgeInsets.all(8),
                               decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                               child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                             ),
                           ),
                         )
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  _buildSectionTitle("Información General"),
                  _buildTextField(_nombreCtrl, "Nombre *", validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  const SizedBox(height: 12),
                  _buildTextField(_aliasCtrl, "Alias / Sigla"),

                  const SizedBox(height: 30),
                  
                  // Buttons are handled below the scrollview in a full screen modal?? 
                  // No, we are inside a limited container, let's keep them here but maybe sticky bottom? 
                  // For simplicity, keep them at the bottom of scroll view.
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(color: Color(0xFF37474F), fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, {String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      decoration: _inputDec(label),
      validator: validator,
    );
  }

  InputDecoration _inputDec(String label) => InputDecoration(
    labelText: label, // We use hintText inside styling? No, labelText makes it float.
    hintText: label,
    filled: true,
    fillColor: Colors.grey.shade100, // Lighter background
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), // Clearer border
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    floatingLabelStyle: const TextStyle(color: Colors.blue),
  );
}
