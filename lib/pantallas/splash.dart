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
    // Inicializar el servicio para guardar offline/cache y configs básicos
    await AuthService.initialize();

    // Sincronizar datos silenciosamente
    try {
      await SyncService.syncAll();
    } catch(e) {
      debugPrint("Error sync al inicio: $e");
    }

    // Esperar un poco para mostrar el splash (animacion)
    await Future.delayed(const Duration(seconds: 2));

    // Todo mundo entra directamente a la app publica sin preguntar login
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaInicio()),
      );
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
