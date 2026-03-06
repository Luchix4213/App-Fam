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

class GestionNoticiasScreen extends StatefulWidget {
  const GestionNoticiasScreen({super.key});

  @override
  State<GestionNoticiasScreen> createState() => _GestionNoticiasScreenState();
}

class _GestionNoticiasScreenState extends State<GestionNoticiasScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  List<dynamic> _noticias = [];
  List<dynamic> _filteredNoticias = [];
  final TextEditingController _searchCtrl = TextEditingController();
  bool? _filterActive; // null = todas, true = activas, false = inactivas

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
      _filteredNoticias = _noticias.where((p) {
        final titulo = (p['titulo'] ?? '').toString().toLowerCase();
        
        bool matchesQuery = titulo.contains(query);
        bool matchesStatus = true;
        if (_filterActive != null) {
          matchesStatus = (p['activa'] == _filterActive);
        }
        return matchesQuery && matchesStatus;
      }).toList();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.getAllNoticias(); // The api gives all by default for admin
      if (res['success'] == true) {
        setState(() {
          _noticias = res['data'];
          _filteredNoticias = List.from(_noticias);
        });
        _filter(); // reapply filters
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

  void _showForm({Map<String, dynamic>? noticiaInfo}) {
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
                  child: NoticiaForm(
                    noticia: noticiaInfo,
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
        title: const Text("Confirmar Baja Lógica", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("¿Estás seguro de dar de baja esta noticia?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF5350)),
            child: const Text("Dar de baja", style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final currentNoticia = _noticias.firstWhere((n) => n['id'] == id);
      final data = {
        'titulo': currentNoticia['titulo'].toString(),
        'descripcion': (currentNoticia['descripcion'] ?? '').toString(),
        'activa': 'false',
      };
      final res = await ApiService.updateNoticia(id, data, null);
      if (res['success']) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Noticia dada de baja")));
        _loadData();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${res['message']}")));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _reactivate(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirmar Reactivación", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("¿Deseas reactivar esta noticia?"),
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
      final currentNoticia = _noticias.firstWhere((n) => n['id'] == id);
      final data = {
        'titulo': currentNoticia['titulo'].toString(),
        'descripcion': (currentNoticia['descripcion'] ?? '').toString(),
        'activa': 'true',
      };
      final res = await ApiService.updateNoticia(id, data, null);
      if (res['success']) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Noticia reactivada")));
         _loadData();
      } else {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${res['message']}")));
         setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: appColores.backgraund,
      drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nueva Noticia", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                                 "Gestión de Noticias",
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
                       hintText: "Buscar noticia...",
                       hintStyle: TextStyle(color: Colors.grey.shade400),
                       prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                       border: InputBorder.none,
                       contentPadding: const EdgeInsets.symmetric(vertical: 14),
                     ),
                   ),
                 ),
               ),

               const SizedBox(height: 15),

               // LISTA DE NOTICIAS CON CABECERA DE FILTRO
               Expanded(
                 child: _buildList(),
               ),
            ],
          ),
    );
  }

  Widget _buildList() {
    if (_filteredNoticias.isEmpty) {
      return const Center(
        child: Text("No se encontraron noticias.", style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredNoticias.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 15),
                const Text("Estado: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(width: 6),
                DropdownButton<String>(
                  value: _filterActive == null ? 'todas' : (_filterActive == true ? 'activas' : 'inactivas'),
                  underline: Container(),
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  items: const [
                    DropdownMenuItem(value: 'todas', child: Text("Todas")),
                    DropdownMenuItem(value: 'activas', child: Text("Activas")),
                    DropdownMenuItem(value: 'inactivas', child: Text("Inactivas")),
                  ],
                  onChanged: (val) {
                    setState(() {
                      if (val == 'todas') _filterActive = null;
                      else if (val == 'activas') _filterActive = true;
                      else if (val == 'inactivas') _filterActive = false;
                      _filter();
                    });
                  },
                ),
              ],
            ),
          );
        }

        final noticia = _filteredNoticias[index - 1];
        final id = noticia['id'];
        final titulo = noticia['titulo'] ?? '';
        final desc = noticia['descripcion'] ?? '';
        final imgUrl = noticia['imagen_url'];
        final activa = noticia['activa'] == true;

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
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
                  // Imagen miniatura
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imgUrl != null && imgUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imgUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                            )
                          : const Icon(Icons.newspaper, color: Colors.grey, size: 30),
                    ),
                  ),
                  const SizedBox(width: 15),
                  
                  // Información
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF263238)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (desc.isNotEmpty) ...[
                           const SizedBox(height: 4),
                           Text(
                             desc,
                             style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                           ),
                        ],
                        const SizedBox(height: 8),
                        _buildBadge(
                          activa ? 'ACTIVA' : 'INACTIVA',
                          activa ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          activa ? Colors.green.shade700 : Colors.red.shade700
                        ),
                      ],
                    ),
                  ),
                  
                  // Acciones
                  Column(
                    children: [
                      if (activa) ...[
                        IconButton(
                          onPressed: () => _showForm(noticiaInfo: noticia),
                          icon: const Icon(Icons.edit_outlined, color: Color(0xFF29B6F6)),
                          tooltip: "Editar",
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(height: 15),
                        IconButton(
                          onPressed: () => _delete(id),
                          icon: const Icon(Icons.delete_outline, color: Color(0xFFEF5350)),
                          tooltip: "Dar de baja",
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ] else ...[
                        IconButton(
                          onPressed: () => _reactivate(id),
                          icon: const Icon(Icons.restore, color: Colors.green),
                          tooltip: "Reactivar",
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ]
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }
}

// -------------------------------------------------------------
// Formulario de Creación/Edición
// -------------------------------------------------------------
class NoticiaForm extends StatefulWidget {
  final Map<String, dynamic>? noticia;
  final VoidCallback onSave;

  const NoticiaForm({super.key, this.noticia, required this.onSave});

  @override
  State<NoticiaForm> createState() => _NoticiaFormState();
}

class _NoticiaFormState extends State<NoticiaForm> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  File? _imageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.noticia != null) {
      _tituloCtrl.text = widget.noticia!['titulo'] ?? '';
      _descCtrl.text = widget.noticia!['descripcion'] ?? '';
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    // For new creation, image is required
    if (widget.noticia == null && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Debes seleccionar una imagen para la noticia.")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final data = {
        'titulo': _tituloCtrl.text,
        'descripcion': _descCtrl.text,
        // Activa is true by default and can be deactivated by logic deletion from the list
        'activa': widget.noticia != null ? widget.noticia!['activa'].toString() : 'true',
      };

      Map<String, dynamic> res;
      if (widget.noticia == null) {
        res = await ApiService.createNoticia(data, _imageFile?.path);
      } else {
        res = await ApiService.updateNoticia(widget.noticia!['id'], data, _imageFile?.path);
      }

      if (res['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Guardado correctamente", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        widget.onSave();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${res['message']}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSaving) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator(color: appColores.dashTealStart)),
      );
    }

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(
                   widget.noticia == null ? "Nueva Noticia" : "Editar Noticia",
                   style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: appColores.dashTealStart),
                 ),
                 IconButton(
                   icon: const Icon(Icons.close, color: Colors.grey),
                   onPressed: () => Navigator.pop(context),
                 )
               ],
             ),
             const SizedBox(height: 15),

             // Selector de Imagen
             Center(
               child: Stack(
                 children: [
                   Container(
                     height: 180,
                     width: double.infinity,
                     decoration: BoxDecoration(
                       color: Colors.grey[200],
                       borderRadius: BorderRadius.circular(20),
                       image: _imageFile != null 
                             ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                             : (widget.noticia?['imagen_url'] != null
                                ? DecorationImage(image: CachedNetworkImageProvider(widget.noticia!['imagen_url']), fit: BoxFit.cover)
                                : null),
                     ),
                     child: (_imageFile == null && widget.noticia?['imagen_url'] == null)
                         ? const Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                               SizedBox(height: 10),
                               Text("Subir Imagen (Obligatorio)", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                             ],
                           ) : null,
                   ),
                   Positioned(
                     bottom: 10,
                     right: 10,
                     child: FloatingActionButton.small(
                       onPressed: _pickImage,
                       backgroundColor: appColores.dashTealStart,
                       child: const Icon(Icons.camera_alt, color: Colors.white),
                     ),
                   )
                 ],
               ),
             ),
             const SizedBox(height: 25),

             _buildTextField(label: "Título", icon: Icons.title, controller: _tituloCtrl, isRequired: true),
             const SizedBox(height: 15),
             _buildTextField(label: "Descripción (Opcional)", icon: Icons.description, controller: _descCtrl, maxLines: 4),

             const SizedBox(height: 30),
             ElevatedButton(
               onPressed: _save,
               style: ElevatedButton.styleFrom(
                 backgroundColor: appColores.dashTealStart,
                 padding: const EdgeInsets.symmetric(vertical: 18),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                 elevation: 8,
                 shadowColor: appColores.dashTealStart.withOpacity(0.5)
               ),
               child: const Text("Guardar Noticia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1)),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label, 
    required IconData icon, 
    required TextEditingController controller, 
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon, color: appColores.dashTealStart) : Padding(padding: const EdgeInsets.only(bottom: 50), child: Icon(icon, color: appColores.dashTealStart)),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: appColores.dashTealStart, width: 2)),
      ),
      validator: isRequired ? (v) => v!.isEmpty ? "Este campo es requerido" : null : null,
    );
  }
}
