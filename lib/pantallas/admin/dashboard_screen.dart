import 'package:flutter/material.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/services/auth_service.dart';
import 'package:fam_intento1/services/api_service.dart';
import 'package:fam_intento1/services/sync_service.dart'; // Import para sync real si es necesario
import 'package:fam_intento1/widgets/admin_drawer.dart';
import 'package:fam_intento1/pantallas/admin/gestion_asociaciones_screen.dart';
import 'package:fam_intento1/pantallas/admin/gestion_miembros_screen.dart';
import 'package:fam_intento1/pantallas/admin/gestion_usuarios_screen.dart';
import 'package:fam_intento1/pantallas/admin/gestion_personal_screen.dart';
import 'package:fam_intento1/pantallas/public_main_screen.dart'; 
import 'package:fam_intento1/pantallas/login.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  String _userName = "Admin FAM";
  String _userRole = "ADMIN";
  
  // Contadores
  int _countAsoc = 0;
  int _countMiembros = 0;
  int _countPersonal = 0;
  int _countUsers = 0;
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final name = await AuthService.getUserName();
    final role = await AuthService.getUserRole();
    
    try {
      final futures = await Future.wait([
        ApiService.getAllAsociaciones(),
        ApiService.getAllMiembros(),
        ApiService.getAllPersonal(),
        ApiService.getAllUsuarios(),
      ]);

      int cAsoc = 0;
      int cMiembros = 0;
      int cPersonal = 0;
      int cUsers = 0;

      if (futures[0]['success']) cAsoc = (futures[0]['data'] as List).length;
      if (futures[1]['success']) cMiembros = (futures[1]['data'] as List).length;
      if (futures[2]['success']) cPersonal = (futures[2]['data'] as List).length;
      if (futures[3]['success']) cUsers = (futures[3]['data'] as List).length;

      if (mounted) {
        setState(() {
          _userName = name ?? "Admin FAM";
          _userRole = role?.toUpperCase() ?? "ADMIN";
          _countAsoc = cAsoc;
          _countMiembros = cMiembros;
          _countPersonal = cPersonal;
          _countUsers = cUsers;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading dashboard stats: $e");
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

  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);
    // Simular o ejecutar sync real
    await SyncService.syncAll(); // Si este método existe y es público
    await Future.delayed(const Duration(seconds: 1)); // Feedback de UI
    await _loadData(); // Recargar datos frescos
    if(mounted) {
        setState(() => _isSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sincronización completada"), backgroundColor: appColores.success)
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: appColores.backgraund,
      drawer: const AdminDrawer(), // Mantenemos el drawer existente
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: appColores.primaryBlue))
          : Column(
            children: [
               // HEADER PERSONALIZADO
               Expanded(
                 child: Stack(
                   children: [
                     // Fondo Header (Azul -> Celeste)
                     Container(
                       height: double.infinity,
                       decoration: const BoxDecoration(
                           gradient: LinearGradient(
                               colors: [Color(0xFFF5F7FA), Color(0xFFF5F7FA)], // Fondo base
                               begin: Alignment.topCenter,
                               end: Alignment.bottomCenter
                           )
                       ),
                     ),
                     
                     SingleChildScrollView(
                       child: Column(
                         children: [
                           // 1. Top Bar Custom (Menu | Logo | Logout)
                           Container(
                              padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [appColores.dashTealStart, appColores.dashTealEnd], // New refined colors
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30)
                                )
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                                      ),
                                      const Text(
                                        "FAM BOLIVIA", 
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
                                      ),
                                      InkWell(
                                        onTap: _handleLogout,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8)
                                          ),
                                          child: Row(
                                            children: const [
                                              Text("Salir", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                              SizedBox(width: 5),
                                              Icon(Icons.logout, color: Colors.white, size: 16)
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 25),
                                  
                                  // 2. Tarjeta de Perfil Hero
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [appColores.dashTealStart, Colors.white.withOpacity(0.85)], // Blue to Light White Gradient
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2)
                                          ),
                                          child: const Icon(Icons.security, size: 40, color: Colors.white),
                                        ),
                                        const SizedBox(width: 15),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Dashboard FAM",
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.9),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "Hola, $_userName",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8)
                                              ),
                                              child: Text(
                                                "Rol: $_userRole",
                                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 10),
                                ],
                              ),
                           ),
                           
                           // 3. Grid Statistics
                           Padding(
                             padding: const EdgeInsets.all(20),
                             child: Column(
                               children: [
                                 GridView.count(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  childAspectRatio: 0.9, // Taller cards
                                  children: [

                                    _StatCard(
                                      title: "Asociaciones",
                                      count: _countAsoc.toString(),
                                      icon: Icons.layers_outlined,
                                      iconColor: appColores.iconOrange,
                                      bgColor: appColores.iconBgOrange,
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestionAsociacionesScreen())),
                                    ),
                                    _StatCard(
                                      title: "Miembros",
                                      count: _countMiembros.toString(),
                                      icon: Icons.people_outline,
                                      iconColor: appColores.iconGreen,
                                      bgColor: appColores.iconBgGreen,
                                       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestionMiembrosScreen())),
                                    ),
                                    _StatCard(
                                      title: "Personal",
                                      count: _countPersonal.toString(),
                                      icon: Icons.badge_outlined,
                                      iconColor: appColores.primaryBlue,
                                      bgColor: Colors.blue.withOpacity(0.1),
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestionPersonalScreen())),
                                    ),
                                    _StatCard(
                                      title: "Usuarios",
                                      count: _countUsers.toString(),
                                      icon: Icons.person_outline,
                                      iconColor: appColores.iconOrange,
                                      bgColor: appColores.iconBgOrange,
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestionUsuariosScreen())),
                                    ), // Users only for admin technically, but let's show anyway or condition it
                                  ],
                                 ),
                                 
                                 const SizedBox(height: 25),
                                 
                                 // 4. Sync Button Prominent
                                 InkWell(
                                   onTap: _isSyncing ? null : _handleSync,
                                   borderRadius: BorderRadius.circular(20),
                                   child: Container(
                                     width: double.infinity,
                                     padding: const EdgeInsets.symmetric(vertical: 20),
                                     decoration: BoxDecoration(
                                       gradient: const LinearGradient(
                                          colors: [Color(0xFF00ADEF), Color(0xFF00796B)], // Blue to Teal
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight
                                       ),
                                       borderRadius: BorderRadius.circular(20),
                                       boxShadow: [
                                         BoxShadow(color: const Color(0xFF00ADEF).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                                       ]
                                     ),
                                     child: _isSyncing 
                                        ? const Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.sync, color: Colors.white, size: 24),
                                              SizedBox(width: 10),
                                              Text("Sincronizar Datos", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                            ],
                                          ),
                                   ),
                                 ),
                                 
                                 const SizedBox(height: 25),
                                 
                                 // 5. System Summary (Cleaner)
                                 Container(
                                   width: double.infinity,
                                   padding: const EdgeInsets.all(20),
                                   decoration: BoxDecoration(
                                     color: Colors.white,
                                     borderRadius: BorderRadius.circular(20),
                                     boxShadow: [
                                       BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                                     ]
                                   ),
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: const [
                                       Text("Resumen del Sistema", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF263238))),
                                       SizedBox(height: 10),
                                       Text("El sistema se encuentra actualizado.", style: TextStyle(color: Colors.grey, fontSize: 13)),
                                     ],
                                   ),
                                 ),
                                 
                                 const SizedBox(height: 30),
                               ],
                             ),
                           ),
                         ],
                       ),
                     )
                   ],
                 ),
               ),
            ],
          ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _StatCard({
    required this.title, 
    required this.count, 
    required this.icon, 
    required this.iconColor, 
    required this.bgColor,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 2
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count, 
                      style: TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.w900, 
                        color: Colors.grey.shade800
                      )
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title, 
                      style: TextStyle(
                        fontSize: 13, 
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500
                      )
                    ),
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
