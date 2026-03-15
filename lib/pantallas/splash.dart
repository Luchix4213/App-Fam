import 'package:flutter/material.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/services/sync_service.dart';
import 'package:fam_intento1/database/databese_helper.dart';
import 'package:fam_intento1/pantallas/public_main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    bool hasLocalData = false;
    try {
      // 1. Consulta rápida a SQLite
      final asocLocales = await DatabaseHelper.instance.getAllAsociaciones();
      if (asocLocales.isNotEmpty) {
        hasLocalData = true;
      }
    } catch (e) {
      debugPrint("Error leyendo SQLite en Splash: $e");
    }

    if (hasLocalData) {
      // SI HAY DATOS: Splash rápido (1.2 segundos por estética)
      await Future.delayed(const Duration(milliseconds: 1200));

      // Disparar sincronización DE FONDO, sin hacer 'await' para no colgar el UI
      SyncService.syncAll().catchError((e) => debugPrint("Error sync de fondo: $e"));

      // Ir directo a la app
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PublicMainScreen()),
        );
      }
    } else {
      // SI NO HAY DATOS (Primera instalación): Obligamos a esperar
      try {
        await SyncService.syncAll();
      } catch (e) {
        debugPrint("Error sync primera vez: $e");
      }

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PublicMainScreen()),
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
              'Conectado al servidor puede tardar unos segundos...',
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
