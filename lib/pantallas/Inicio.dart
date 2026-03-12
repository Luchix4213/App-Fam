import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/widgets/gradient_scaffold.dart';
import 'package:fam_intento1/pantallas/buscar.dart';
import 'package:flutter/material.dart';
import 'package:fam_intento1/core/text.dart'; // tus estilos de texto
import 'package:fam_intento1/services/auth_service.dart';
import 'package:fam_intento1/pantallas/login.dart';
import 'package:fam_intento1/pantallas/asociaciones.dart';
import 'package:fam_intento1/pantallas/admin/dashboard_screen.dart';

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF135685),
      // App Bar transparente para botones de navegación (Login/Dashboard/Cerrar Sesión)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (AuthService.isLoggedIn && (AuthService.user?['role'] == 'admin' || AuthService.user?['role'] == 'fam'))
            TextButton.icon(
              icon: const Icon(Icons.dashboard, color: Colors.white),
              label: const Text('Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen())),
            ),
          if (!AuthService.isLoggedIn || AuthService.isGuest)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: TextButton.icon(
                icon: const Icon(Icons.login, size: 18, color: Colors.white),
                label: const Text('Iniciar Sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
              ),
            ),
          if (AuthService.isLoggedIn && !AuthService.isGuest)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () => _logout(context),
              tooltip: 'Cerrar sesión',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //const SizedBox(height: 10),
                    // Logo
                    Image.asset(
                      "assets/icon/icono2.png",
                      height: 220,
                      width: 220,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),

                    // Tarjeta Translúcida Central (Ahora con gradiente)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF4AC2E3), // Celeste claro
                            Color(0xFF035E9B), // Azul medio oscuro
                          ],
                        ),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Bienvenido",
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "al sistema de busqueda de\nautoridades municipales de\nBolivia.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              height: 1.5,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 25),
                          Container(
                            height: 1.5,
                            width: 150,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),

                    // Botón Principal Celeste Brillante
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF6DE4F1), // Celeste bien claro brillante
                              Color(0xFF09A6D8), // Celeste intermedio
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder:(context) => const AsociacionesScreen()));
                          },
                          child: const Text(
                            "VER ASOCIACIONES",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Footer Text integrado en el scroll
                    Text(
                      "Sistema Asociativo Municipal de Bolivia",
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "© 2026 FAM Bolivia",
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}