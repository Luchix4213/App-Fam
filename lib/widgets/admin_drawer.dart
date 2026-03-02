import 'package:flutter/material.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/services/auth_service.dart';
import 'package:fam_intento1/pantallas/login.dart';
import 'package:fam_intento1/pantallas/admin/dashboard_screen.dart';
import 'package:fam_intento1/pantallas/admin/gestion_departamentos_screen.dart';
import 'package:fam_intento1/pantallas/admin/gestion_asociaciones_screen.dart';
import 'package:fam_intento1/pantallas/admin/gestion_miembros_screen.dart';
import 'package:fam_intento1/pantallas/admin/gestion_usuarios_screen.dart';
import 'package:fam_intento1/pantallas/Inicio.dart';

class AdminDrawer extends StatelessWidget {
  final String currentRoute; 

  const AdminDrawer({super.key, this.currentRoute = 'Dashboard'});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.user;
    final name = user?['name']?.toString() ?? 'Admin FAM';
    final role = (user?['role'] ?? 'ADMIN').toString().toUpperCase();

    // Determinamos la ruta actual si no se pasa explícitamente (rudimentario)
    // Lo ideal es pasar el índice o nombre desde la screen padre.

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 1. Header del Drawer (Custom)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [appColores.dashTealStart, appColores.dashTealEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/images/famlogo.png",
                      height: 30,
                      color: Colors.white, // Forzar blanco si es posible, o usar original
                      errorBuilder: (_,__,___) => const Icon(Icons.security, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("FAM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("BOLIVIA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 13)),
                      ],
                    )
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),

          // 2. Info Usuario Sticky top
          Padding(
            padding: const EdgeInsets.all(25),
            child: Row(
              children: [
                Container(
                   width: 50, height: 50,
                   alignment: Alignment.center,
                   decoration: BoxDecoration(
                     color: Color(0xFFE3F2FD),
                     shape: BoxShape.circle,
                     border: Border.all(color: Colors.blue.withOpacity(0.2))
                   ),
                   child: Text(
                     name.isNotEmpty ? name[0].toUpperCase() : 'A',
                     style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                   ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Hola,", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF102027))),
                    const SizedBox(height: 2),
                    Text("ROL: $role", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),

          // 3. Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  text: "Dashboard",
                  isActive: context.widget.toString() == 'DashboardScreen' || currentRoute == 'Dashboard', // Simple check
                  onTap: () => _navigate(context, const DashboardScreen()),
                ),
                _DrawerItem(
                  icon: Icons.business_outlined,
                  text: "Departamentos",
                  isActive: context.widget.toString() == 'GestionDepartamentosScreen' || currentRoute == 'Departamentos',
                  onTap: () => _navigate(context, const GestionDepartamentosScreen()),
                ),
                _DrawerItem(
                  icon: Icons.layers_outlined,
                  text: "Asociaciones",
                  isActive: context.widget.toString() == 'GestionAsociacionesScreen' || currentRoute == 'Asociaciones',
                  onTap: () => _navigate(context, const GestionAsociacionesScreen()),
                ),
                _DrawerItem(
                  icon: Icons.people_outline,
                  text: "Miembros",
                  isActive: context.widget.toString() == 'GestionMiembrosScreen' || currentRoute == 'Miembros',
                  onTap: () => _navigate(context, const GestionMiembrosScreen()),
                ),
                if (role == 'ADMIN')
                  _DrawerItem(
                    icon: Icons.admin_panel_settings_outlined,
                    text: "Usuarios",
                    isActive: context.widget.toString() == 'GestionUsuariosScreen' || currentRoute == 'Usuarios',
                    onTap: () => _navigate(context, const GestionUsuariosScreen()),
                  ),
              ],
            ),
          ),

          // 4. Footer Logout

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.pop(context); // Close drawer
    // Replace to avoid stack buildup
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.text, this.isActive = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? appColores.dashTealStart : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: isActive ? Colors.white : appColores.drawerInactiveText, size: 22),
                const SizedBox(width: 15),
                Text(
                  text,
                  style: TextStyle(
                    color: isActive ? Colors.white : appColores.drawerInactiveText,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
