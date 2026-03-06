import 'dart:io';
import 'dart:ui'; // For blur
import 'package:flutter/material.dart';
import 'package:fam_intento1/services/api_service.dart';
import 'package:fam_intento1/services/auth_service.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/widgets/admin_drawer.dart';
import 'package:fam_intento1/pantallas/login.dart';
import 'package:fam_intento1/pantallas/Inicio.dart';
import 'package:fam_intento1/pantallas/public_main_screen.dart';

class GestionUsuariosScreen extends StatefulWidget {
  const GestionUsuariosScreen({super.key});

  @override
  State<GestionUsuariosScreen> createState() => _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  List<dynamic> _usuarios = [];
  List<dynamic> _filteredUsuarios = [];
  final TextEditingController _searchCtrl = TextEditingController();

  String _filterRole = 'Todos';
  String _filterEstado = 'Todos';

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
      _filteredUsuarios = _usuarios.where((u) {
        final nombre = (u['name'] ?? '').toString().toLowerCase();
        final email = (u['email'] ?? '').toString().toLowerCase();
        final role = (u['role'] ?? 'USER').toString().toUpperCase();
        final estado = (u['estado'] ?? 'activo').toString().toLowerCase();

        bool matchSearch = nombre.contains(query) || email.contains(query);
        bool matchRole = _filterRole == 'Todos' || role == _filterRole;
        bool matchEstado = _filterEstado == 'Todos' || 
                           (_filterEstado == 'Activo' && estado != 'inactivo') ||
                           (_filterEstado == 'Inactivo' && estado == 'inactivo');

        return matchSearch && matchRole && matchEstado;
      }).toList();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.getAllUsuarios();
      if (res['success'] == true) {
        setState(() {
          _usuarios = res['data'];
          _filteredUsuarios = List.from(_usuarios);
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

  void _showForm({Map<String, dynamic>? usuario}) {
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
                  constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
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
                  child: UsuarioForm(
                    usuario: usuario,
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
        title: const Text("Confirmar Baja", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("¿Estás seguro de inhabilitar el acceso a este usuario?"),
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
        final res = await ApiService.updateUsuario(id, {'estado': 'inactivo'});
        if (res['success'] == true || res['success'] == 'true') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Usuario dado de baja exitosamente")));
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
        content: const Text("¿Deseas reactivar el acceso a este usuario?"),
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
        final res = await ApiService.updateUsuario(id, {'estado': 'activo'});
        if (res['success'] == true || res['success'] == 'true') {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Usuario reactivado existosamente")));
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
      drawer: const AdminDrawer(currentRoute: 'Usuarios'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nuevo Usuario", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                                 "Gestión de Usuarios",
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
                       hintText: "Buscar usuario por nombre o email...",
                       hintStyle: TextStyle(color: Colors.grey.shade400),
                       prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                       border: InputBorder.none,
                       contentPadding: const EdgeInsets.symmetric(vertical: 14),
                     ),
                   ),
                 ),
               ),

               const SizedBox(height: 15),

               // FILTERS
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 20),
                 child: Row(
                   children: [
                     Expanded(
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10),
                         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100)),
                         child: DropdownButtonHideUnderline(
                           child: DropdownButton<String>(
                             isExpanded: true,
                             value: _filterRole,
                             items: ['Todos', 'ADMIN', 'FAM', 'USUARIO'].map((e) => DropdownMenuItem(value: e, child: Text(e == 'Todos' ? 'Rol: Todos' : 'Rol: $e', style: const TextStyle(fontSize: 13, color: Colors.black87)))).toList(),
                             onChanged: (v) {
                               setState(() => _filterRole = v!);
                               _filter();
                             },
                             icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                           ),
                         ),
                       ),
                     ),
                     const SizedBox(width: 10),
                     Expanded(
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10),
                         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100)),
                         child: DropdownButtonHideUnderline(
                           child: DropdownButton<String>(
                             isExpanded: true,
                             value: _filterEstado,
                             items: ['Todos', 'Activo', 'Inactivo'].map((e) => DropdownMenuItem(value: e, child: Text(e == 'Todos' ? 'Estado: Todos' : 'Estado: $e', style: const TextStyle(fontSize: 13, color: Colors.black87)))).toList(),
                             onChanged: (v) {
                               setState(() => _filterEstado = v!);
                               _filter();
                             },
                             icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                           ),
                         ),
                       ),
                     )
                   ],
                 ),
               ),
               const SizedBox(height: 20),

               // LISTA
               Expanded(
                 child: ListView.separated(
                   padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                   itemCount: _filteredUsuarios.length,
                   separatorBuilder: (ctx, i) => const SizedBox(height: 15),
                   itemBuilder: (context, index) {
                     final u = _filteredUsuarios[index];
                     return _buildUserCard(u);
                   },
                 ),
               ),
            ],
          ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> u) {
    String nombre = (u['name'] ?? 'Sin Nombre').toString();
    String email = u['email'] ?? '';
    String role = (u['role'] ?? 'USER').toString().toUpperCase();
    String initial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';

    Color roleColor = Colors.grey;
    if (role == 'ADMIN') roleColor = Colors.red;
    if (role == 'FAM') roleColor = Colors.blue;

    String estado = (u['estado'] ?? 'activo').toString().toLowerCase();
    bool isInactive = estado == 'inactivo';

    return Container(
      decoration: BoxDecoration(
        color: isInactive ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4)
          )
        ],
        border: isInactive ? Border.all(color: Colors.red.shade100) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Opacity(
            opacity: isInactive ? 0.6 : 1.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: appColores.dashTealStart.withOpacity(0.1),
                  child: Text(initial, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: appColores.dashTealStart)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(email, style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6)
                        ),
                        child: Text(role.toUpperCase(), style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 10)),
                      ),
                      if (isInactive) ...[
                        const SizedBox(height: 4),
                        Text("Inactivo / Deshabilitado", style: TextStyle(color: Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                      ]
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _showForm(usuario: u), 
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                    ),
                    const SizedBox(width: 8),
                    if (!isInactive)
                      IconButton(
                        onPressed: () => _delete(u['id']), 
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      )
                    else
                      IconButton(
                        onPressed: () => _reactivate(u['id']), 
                        icon: const Icon(Icons.refresh, color: Colors.green),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      )
                  ],
                )
              ],
            ),
          ),
         ),
      ),
    );
  }
}

class UsuarioForm extends StatefulWidget {
  final Map<String, dynamic>? usuario;
  final VoidCallback onSave;

  const UsuarioForm({super.key, this.usuario, required this.onSave});

  @override
  State<UsuarioForm> createState() => _UsuarioFormState();
}

class _UsuarioFormState extends State<UsuarioForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'USER';
  bool _isSaving = false;
  bool _obscurePass = true;

  @override
  void initState() {
    super.initState();
    if (widget.usuario != null) {
      _nombreCtrl.text = widget.usuario!['name'] ?? '';
      _emailCtrl.text = widget.usuario!['email'] ?? '';
      
      // Normalize role from backend (admin, fam, usuario) to UI (ADMIN, FAM, USER)
      final rawRole = (widget.usuario!['role'] ?? 'usuario').toString().toLowerCase();
      if (rawRole == 'admin') {
        _role = 'ADMIN';
      } else if (rawRole == 'fam') {
        _role = 'FAM';
      } else {
        _role = 'USER';
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final data = {
        'name': _nombreCtrl.text,
        'email': _emailCtrl.text,
        'role': _role == 'ADMIN' ? 'admin' : (_role == 'FAM' ? 'fam' : 'usuario')
      };
      if (_passCtrl.text.isNotEmpty) {
        data['password'] = _passCtrl.text;
      }

      final res = widget.usuario == null 
        ? await ApiService.createUsuario(data)
        : await ApiService.updateUsuario(widget.usuario!['id'], data);

      if (res['success']) widget.onSave();
      else if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));

    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if(mounted) setState(() => _isSaving = false);
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
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.usuario == null ? "Nuevo Usuario" : "Editar Usuario",
                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87),
                      ),
                      const SizedBox(height: 5),
                      Text("Administración de usuarios del sistema", style: TextStyle(fontSize: 13, color: Colors.grey.shade600))
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
            const SizedBox(height: 25),

            // Fields
            _buildTextField(_nombreCtrl, "Nombre", (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 15),
            _buildTextField(_emailCtrl, "Email", (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 15),
            _buildTextField(_passCtrl, widget.usuario == null ? "Contraseña *" : "Nueva Contraseña (Opcional)", (v) {
               if (widget.usuario == null && (v == null || v.isEmpty)) return 'Requerido para nuevos usuarios';
               return null;
            }, obscure: _obscurePass, isPassword: true),
            const SizedBox(height: 20),
            
            const Text("Rol", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF37474F))),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _role,
              items: ['ADMIN', 'FAM', 'USER'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => _role = v!),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15)
              ),
            ),

            const SizedBox(height: 30),
            
            // Buttons
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, String? Function(String?)? validator, {bool obscure = false, bool isPassword = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        suffixIcon: isPassword ? IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: () => setState(() => _obscurePass = !_obscurePass),
        ) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
         contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
         floatingLabelStyle: const TextStyle(color: Colors.blue)
      ),
    );
  }
}
