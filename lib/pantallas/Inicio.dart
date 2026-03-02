import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/widgets/gradient_scaffold.dart';
import 'package:fam_intento1/pantallas/buscar.dart';
import 'package:flutter/material.dart';
import 'package:fam_intento1/core/text.dart'; // tus estilos de texto
import 'package:fam_intento1/services/auth_service.dart';
import 'package:fam_intento1/pantallas/login.dart';
import 'package:fam_intento1/pantallas/departamentos.dart';
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
      // App Bar transparente para botones de navegación (Login/Dashboard)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (AuthService.isLoggedIn && (AuthService.user?['role'] == 'admin' || AuthService.user?['role'] == 'fam'))
            TextButton.icon(
              icon: const Icon(Icons.dashboard, color: appColores.primaryBlue),
              label: const Text('Dashboard', style: TextStyle(color: appColores.primaryBlue, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen())),
            ),
          if (!AuthService.isLoggedIn || AuthService.isGuest)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.login, size: 18, color: Colors.white),
                label: const Text('Iniciar Sesión', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColores.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 2,
                ),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
              ),
            ),
          if (AuthService.isLoggedIn && !AuthService.isGuest)
            IconButton(
              icon: const Icon(Icons.logout, color: appColores.danger),
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
                    const SizedBox(height: 20),
                    // Logo
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ]
                      ),
                      child: Image.asset(
                        "assets/images/famlogo.png",
                        height: 180,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Título Principal
                    const Text(
                      "FAM BOLIVIA",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900, // Extra Bold
                        color: appColores.primaryBlue,
                        letterSpacing: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Subtítulo
                    const Text(
                      "Federación de Asociaciones\nMunicipales",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: appColores.textDark,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Texto Descriptivo
                    const Text(
                      "Bienvenido a nuestra aplicación de\nbúsqueda de autoridades municipales de\nla institución FAM Bolivia. ¡Acompáñanos!",
                      style: TextStyle(
                        fontSize: 15,
                        color: appColores.textGrey,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Botón Principal
                    SizedBox(
                      width: 250,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColores.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                          shadowColor: appColores.primaryGreen.withOpacity(0.4),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder:(context) => const DepartamentosScreen()));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "VER DEPARTAMENTOS",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: const [
                   Text(
                    "Sistema Asociativo Municipal de Bolivia",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                   SizedBox(height: 5),
                   Text(
                    "© 2026 FAM Bolivia",
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
