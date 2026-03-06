import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fam_intento1/services/api_service.dart';
import 'package:fam_intento1/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/widgets/admin_drawer.dart';
import 'package:fam_intento1/pantallas/login.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GestionPersonalScreen extends StatefulWidget {
  const GestionPersonalScreen({super.key});

  @override
  State<GestionPersonalScreen> createState() => _GestionPersonalScreenState();
}

class _GestionPersonalScreenState extends State<GestionPersonalScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  List<dynamic> _personal = [];
  List<dynamic> _filteredPersonal = [];
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
      _filteredPersonal = _personal.where((p) {
        final nombre = (p['nombre'] ?? '').toString().toLowerCase();
        final cargo = (p['cargo'] ?? '').toString().toLowerCase();
        return nombre.contains(query) || cargo.contains(query);
      }).toList();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.getAllPersonal(estado: _filterState);
      if (res['success'] == true) {
        setState(() {
          _personal = res['data'];
          _filteredPersonal = List.from(_personal);
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

  void _showForm({Map<String, dynamic>? personalInfo}) {
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
                  child: PersonalForm(
                    personal: personalInfo,
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
        content: const Text("¿Estás seguro de dar de baja a este personal?"),
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
        final res = await ApiService.updatePersonal(id, {'estado': 'inactivo'}, null);
        if (res['success'] == true || res['success'] == 'true') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Personal dado de baja")));
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
        content: const Text("¿Deseas reactivar a este personal?"),
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
        final res = await ApiService.updatePersonal(id, {'estado': 'activo'}, null);
        if (res['success'] == true || res['success'] == 'true') {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Personal reactivado")));
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
      drawer: const AdminDrawer(currentRoute: 'Personal FAM'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF1E88E5), // Blue 600
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nuevo Personal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                       decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [appColores.headerTealStart, appColores.headerTealEnd],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
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
                                 "Gestión de Personal",
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
                       hintText: "Buscar por nombre o cargo...",
                       hintStyle: TextStyle(color: Colors.grey.shade400),
                       prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                       border: InputBorder.none,
                       contentPadding: const EdgeInsets.symmetric(vertical: 14),
                     ),
                   ),
                 ),
                ),

                const SizedBox(height: 15),

                 // FILTROS: ESTADO
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 20),
                   child: Row(
                     children: [
                       // Filtro Estado
                       Expanded(
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
                     ],
                   ),
                 ),

                 const SizedBox(height: 15),

                // LISTA DE PERSONAL
               Expanded(
                 child: ListView.separated(
                   padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                   itemCount: _filteredPersonal.length,
                   separatorBuilder: (ctx, i) => const SizedBox(height: 15),
                   itemBuilder: (context, index) {
                     final p = _filteredPersonal[index];
                     return _buildPersonalCard(p);
                   },
                 ),
               ),
            ],
          ),
    );
  }

  Widget _buildPersonalCard(Map<String, dynamic> p) {
    final isActive = (p['estado'] ?? 'activo') == 'activo';
    final cargo = (p['cargo'] ?? 'SIN CARGO').toString();

    final String fotoUrl = p['foto']?.toString() ?? "";

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
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: fotoUrl.isNotEmpty 
                      ? CachedNetworkImageProvider(fotoUrl.startsWith('http') ? fotoUrl : "${ApiService.baseUrl.replaceAll('/api', '')}$fotoUrl") as ImageProvider
                      : null,
                  child: fotoUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.grey, size: 30)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['nombre'] ?? 'Sin Nombre',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF263238)),
                    ),
                    const SizedBox(height: 4),
                    Text(cargo, style: const TextStyle(fontSize: 13, color: appColores.dashTealStart, fontWeight: FontWeight.bold)),
                    
                    if (p['celular'] != null && p['celular'].toString().isNotEmpty)
                      Text('Cel: ${p['celular']}', style: const TextStyle(fontSize: 12, color: Color(0xFF90A4AE))),
                    if (p['correo_electronico'] != null && p['correo_electronico'].toString().isNotEmpty)
                      Text('✉️ ${p['correo_electronico']}', style: const TextStyle(fontSize: 12, color: Color(0xFF90A4AE))),
                    
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildBadge(isActive ? "ACTIVO" : "INACTIVO", isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE), isActive ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
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
                        onPressed: () => _showForm(personalInfo: p), 
                        icon: const Icon(Icons.edit_outlined, color: Color(0xFF29B6F6)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(height: 15),
                      IconButton(
                        onPressed: () => _delete(p['id']), 
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFEF5350)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                   ] else ...[
                      ElevatedButton.icon(
                       onPressed: () => _reactivate(p['id']), 
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

class PersonalForm extends StatefulWidget {
  final Map<String, dynamic>? personal;
  final VoidCallback onSave;

  const PersonalForm({super.key, this.personal, required this.onSave});

  @override
  State<PersonalForm> createState() => _PersonalFormState();
}

class _PersonalFormState extends State<PersonalForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _cargoCtrl = TextEditingController();
  final _celularCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.personal != null) {
      final p = widget.personal!;
      _nombreCtrl.text = p['nombre'] ?? '';
      _cargoCtrl.text = p['cargo'] ?? '';
      _celularCtrl.text = p['celular'] ?? '';
      _correoCtrl.text = p['correo_electronico'] ?? '';
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
        'cargo': _cargoCtrl.text,
        'celular': _celularCtrl.text,
        'correo_electronico': _correoCtrl.text,
        'estado': 'activo',
      };

      Map<String, dynamic> res;
      if (widget.personal == null) {
        res = await ApiService.createPersonal(data, _imageFile?.path);
      } else {
        res = await ApiService.updatePersonal(widget.personal!['id'], data, _imageFile?.path);
      }

      if (res['success'] == true) {
         widget.onSave();
      }
      else if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
      }
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
                    widget.personal == null ? "Nuevo Personal" : "Editar Personal",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87),
                  ),
                   const SizedBox(height: 5),
                  Text(
                    "Actualiza la información del funcionario",
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
        Flexible(
          fit: FlexFit.loose,
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
                              : (widget.personal != null && widget.personal!['foto'] != null && widget.personal!['foto'].toString().isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: widget.personal!['foto'].toString().startsWith('http') 
                                          ? widget.personal!['foto'] 
                                          : "${ApiService.baseUrl.replaceAll('/api', '')}${widget.personal!['foto']}", 
                                      width: 100, 
                                      height: 100, 
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => const Icon(Icons.person, size: 40, color: Colors.blue),
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
                   _buildTextField(_nombreCtrl, "Nombre Completo", validator: (v) => v!.isEmpty ? 'Req' : null),
                  const SizedBox(height: 12),
                   _buildTextField(_cargoCtrl, "Cargo Institucional (Ej. Director Ejecutivo)", validator: (v) => v!.isEmpty ? 'Req' : null),

                  const SizedBox(height: 20),
                   _buildSection("Contacto"),
                   Row(children: [
                     Expanded(child: _buildTextField(_celularCtrl, "Celular")),
                   ]),
                   const SizedBox(height: 12),
                   Row(children: [
                     Expanded(child: _buildTextField(_correoCtrl, "Email Institucional")),
                   ]),

                  // Bottom space for consistent scrolling
                  const SizedBox(height: 30),
                  
                  // Botones Fixed Area (dentro del scroll por diseño modal ajustado)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                             side: BorderSide(color: Colors.grey.shade300)
                          ),
                          child: const Text("Cancelar", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF43A047), // Green Save
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isSaving 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Guardar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF37474F))),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 1)),
      ),
    );
  }
}
