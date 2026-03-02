import 'package:flutter/material.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/services/auth_service.dart';
import 'package:fam_intento1/pantallas/login.dart';
import 'package:fam_intento1/pantallas/Inicio.dart';
import 'package:fam_intento1/services/sync_service.dart';
import 'package:fam_intento1/pantallas/public_main_screen.dart';
import 'package:fam_intento1/pantallas/admin/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}



class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Inicializar el servicio de autenticación
    await AuthService.initialize();

    // Sincronizar datos en segundo plano (no bloqueante o con timeout corto si se desea)
    // Para asegurar datos frescos al inicio, podríamos esperar.
    // Usaremos un "fire and forget" seguro o esperamos si queremos garantizar datos.
    // Dado que existe JSON local, no bloqueamos demasiado.
    SyncService.syncAll(); 

    // Esperar un poco para mostrar el splash
    await Future.delayed(const Duration(seconds: 2));

    // Verificar si hay un token válido
    var isValid = await AuthService.verifyToken();

    if (mounted) {
      if (AuthService.isLoggedIn && isValid) {
        // Usuario logueado y token válido
        final role = await AuthService.getUserRole();
        final isAdmin = role != null && (role.toLowerCase() == 'admin' || role.toLowerCase() == 'superadmin' || role.toLowerCase() == 'fam');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => isAdmin ? const DashboardScreen() : const PublicMainScreen(),
          ),
        );
      } else {
        // Usuario no logueado o token inválido
        if (AuthService.isLoggedIn) {
          // Token inválido, hacer logout
          await AuthService.logout();
        }
        // Exigir login para todos (ya sea admin o usuario público)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColores.backgraund,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/famlogo.png",
              height: 200,
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Color.fromARGB(255, 72, 228, 33),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cargando...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
