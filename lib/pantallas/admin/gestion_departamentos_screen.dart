import 'dart:io';
import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:fam_intento1/services/api_service.dart';
import 'package:fam_intento1/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/widgets/admin_drawer.dart';
import 'package:fam_intento1/pantallas/login.dart';
import 'package:fam_intento1/pantallas/Inicio.dart';
import 'package:fam_intento1/pantallas/public_main_screen.dart';

class GestionDepartamentosScreen extends StatefulWidget {
  const GestionDepartamentosScreen({super.key});

  @override
  State<GestionDepartamentosScreen> createState() => _GestionDepartamentosScreenState();
}

class _GestionDepartamentosScreenState extends State<GestionDepartamentosScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  List<dynamic> _departamentos = [];
  List<dynamic> _filteredDepartamentos = [];
  final TextEditingController _searchCtrl = TextEditingController();
  String _filterState = 'activo'; // 'activo', 'inactivo', 'todos'

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
      _filteredDepartamentos = _departamentos.where((d) {
        final nombre = (d['nombre'] ?? '').toLowerCase();
        return nombre.contains(query);
      }).toList();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.getDepartamentos(isAdmin: true, estado: _filterState);
      if (res['success'] == true) {
        setState(() {
           _departamentos = res['data'];
           _filteredDepartamentos = List.from(_departamentos);
        });
      } else {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${res['message']}")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if(mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false
        );
    }
  }

  void _showForm({Map<String, dynamic>? departamento}) {
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
                  constraints: const BoxConstraints(maxWidth: 500), // Max width for tablet/web
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
                  child: DepartamentoForm(
                    departamento: departamento,
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
        content: const Text("¿Estás seguro de dar de baja este departamento? Esto también dará de baja a sus Asociaciones y Miembros."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            child: const Text("Dar de Baja", style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final res = await ApiService.updateDepartamento(id, {'estado': 'inactivo'}, null);
        if (res['success'] == true || res['success'] == 'true') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Departamento dado de baja correctamente")));
          _loadData(); // Recargar lista
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
        content: const Text("¿Deseas reactivar este departamento?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF43A047),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            child: const Text("Reactivar", style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        // Usamos update con estado activo
        final res = await ApiService.updateDepartamento(id, {'estado': 'activo'}, null);
        if (res['success']) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Departamento reactivado correctamente")));
          _loadData(); // Recargar lista
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
      drawer: const AdminDrawer(currentRoute: 'Departamentos'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF1E88E5), // Blue prominent
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nuevo Departamento", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: appColores.dashTealStart))
          : Column(
            children: [
               // CUSTOM HEADER (Igual al Dashboard)
               SizedBox(
                 height: 220, // Reduced from 260 to move title up
                 child: Stack(
                   children: [
                     // 1. Gradient Background Panel
                     Container(
                       height: 180, // Reduced from 220
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
                            // Top Bar Row
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

                     // 2. Title Card Floating
                     Positioned(
                       bottom: 0, // Keeps it at the bottom of SizedBox
                       left: 20,
                       right: 20,
                       child: Container(
                         height: 70, // Slightly more compact
                         padding: const EdgeInsets.symmetric(horizontal: 20),
                         decoration: BoxDecoration(
                           gradient: const LinearGradient(
                             colors: [Color(0xFF0277BD), Color(0xFF00C853)], // Blue to Green Gradient
                             begin: Alignment.centerLeft,
                             end: Alignment.centerRight,
                           ),
                           borderRadius: BorderRadius.circular(20),
                           boxShadow: [
                             BoxShadow(
                               color: const Color(0xFF0277BD).withOpacity(0.3),
                               blurRadius: 15,
                               offset: const Offset(0, 8),
                             )
                           ]
                         ),
                         child: Row(
                           children: const [
                             Expanded(
                               child: Text(
                                 "Gestión de Departamentos",
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
                       hintText: "Buscar departamento...",
                       hintStyle: TextStyle(color: Colors.grey.shade400),
                       prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                       border: InputBorder.none,
                       contentPadding: const EdgeInsets.symmetric(vertical: 14),
                     ),
                   ),
                 ),
               ),

               const SizedBox(height: 20),

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
                
                const SizedBox(height: 10),

               // LISTA DE TARJETAS
               Expanded(
                 child: ListView.separated(
                   padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                   itemCount: _filteredDepartamentos.length,
                   separatorBuilder: (ctx, i) => const SizedBox(height: 15),
                   itemBuilder: (context, index) {
                     final d = _filteredDepartamentos[index];
                     return _buildDepartmentItem(d);
                   },
                 ),
               ),
            ],
          ),
    );
  }

  Widget _buildDepartmentItem(Map<String, dynamic> d) {
    // Logic to resolve image similar to ImageHelper or public view
    final foto = d['foto'];
    final hasPhoto = foto != null && foto.toString().isNotEmpty;
    
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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icono/Imagen Cuadrado Azul
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF0288D1), // Light Blue placeholder
                  borderRadius: BorderRadius.circular(12),
                  image: hasPhoto ? DecorationImage(
                    image: NetworkImage(foto.startsWith('http') ? foto : "${ApiService.baseUrl.replaceAll('/api', '')}$foto"),
                    fit: BoxFit.cover
                  ) : null
                ),
                child: hasPhoto 
                  ? null // Image is in decoration
                  : const Icon(Icons.business, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 15),
              
              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (d['nombre'] ?? 'Sin Nombre').toString().toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF263238)
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Si tienes un subtítulo (ej. Nombre completo si arriba es sigla) ponlo aquí
                    Text(
                      "Departamento", // Placeholder o data real si existe
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),

              // Actions
              Row(
                children: [
                  if (d['estado'] == 'activo') ...[
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Color(0xFF29B6F6)),
                      onPressed: () => _showForm(departamento: d),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 15),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEF5350)),
                      onPressed: () => _delete(d['id']),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ] else ...[
                     // Inactivo: Botón Reactivar
                     ElevatedButton.icon(
                       onPressed: () => _reactivate(d['id']), 
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
}

class DepartamentoForm extends StatefulWidget {
  final Map<String, dynamic>? departamento;
  final VoidCallback onSave;

  const DepartamentoForm({super.key, this.departamento, required this.onSave});

  @override
  State<DepartamentoForm> createState() => _DepartamentoFormState();
}

class _DepartamentoFormState extends State<DepartamentoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.departamento != null) {
      _nombreCtrl.text = widget.departamento!['nombre'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageFile = File(image.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final data = {'nombre': _nombreCtrl.text};
      Map<String, dynamic> res;
      if (widget.departamento == null) {
        res = await ApiService.createDepartamento(data, _imageFile?.path);
      } else {
        res = await ApiService.updateDepartamento(widget.departamento!['id'], data, _imageFile?.path);
      }

      if (res['success']) {
        widget.onSave();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Header Row with Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.departamento == null ? "Nuevo Departamento" : "Editar Departamento",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Actualiza la información del departamento",
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                )
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Imagen
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
                            : (widget.departamento != null && widget.departamento!['foto'] != null 
                                ? Image.network(
                                    widget.departamento!['foto'].toString().startsWith('http') 
                                       ? widget.departamento!['foto'] 
                                       : "${ApiService.baseUrl.replaceAll('/api', '')}${widget.departamento!['foto']}", // Ajuste ruta base
                                    width: 100, height: 100, fit: BoxFit.cover,
                                    errorBuilder: (_,__,___) => const Icon(Icons.camera_alt, color: Colors.grey),
                                  )
                                : const Icon(Icons.camera_alt, color: Colors.blue, size: 40)),
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
                         decoration: const BoxDecoration(
                           color: Colors.blue,
                           shape: BoxShape.circle
                         ),
                         child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                       ),
                     ),
                   )
                ],
              ),
            ),

            const SizedBox(height: 25),
            
            // Nombre Field
            const Text("Nombre", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF37474F), fontSize: 13)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nombreCtrl,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              decoration: InputDecoration(
                hintText: "Nombre del Departamento",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey.shade100, // Light grey background
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15)
              ),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),

            // Disclaimer about missing fields
            /*const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.2))
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text("Campos adicionales (Alias, Descripción) no disponibles actualmente.", style: TextStyle(color: Colors.blue.shade800, fontSize: 12))),
                ],
              ),
            ),*/

            const SizedBox(height: 30),
            
            // Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047), // Green
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isSaving 
                  ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Guardar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 15),
             SizedBox(
              width: double.infinity,
              height: 45,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                   foregroundColor: Colors.grey
                ),
                child: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }
}
