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
    return GradientScaffold(
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
                    const SizedBox(height: 10),
                    // Logo
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ]
                      ),
                      child: Image.asset(
                        "assets/images/famlogo.png",
                        height: 110,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Título Principal
                    const Text(
                      "FAM BOLIVIA",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Subtítulo
                    const Text(
                      "Federación de Asociaciones\nMunicipales de Bolivia",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 35),

                    // Tarjeta Translúcida Central
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: const [
                          Text(
                            "Bienvenido al sistema de búsqueda de\nautoridades municipales de la institución\nFAM Bolivia.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "¡Acompáñanos!",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),

                    // Botón Principal Verde
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColores.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                          shadowColor: appColores.primaryGreen.withOpacity(0.5),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder:(context) => const AsociacionesScreen()));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "VER ASOCIACIONES",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                          ],
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