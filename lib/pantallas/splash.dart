import 'package:flutter/material.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/services/auth_service.dart';
import 'package:fam_intento1/pantallas/login.dart';
import 'package:fam_intento1/pantallas/Inicio.dart';

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

    // Esperar un poco para mostrar el splash
    await Future.delayed(const Duration(seconds: 2));

    // Verificar si hay un token válido; si no, intentar login genérico
    var isValid = await AuthService.verifyToken();
    if (!isValid) {
      final guestOk = await AuthService.loginAsGuestIfNeeded();
      if (guestOk) {
        isValid = await AuthService.verifyToken();
      }
    }

    if (mounted) {
      if (AuthService.isLoggedIn && isValid) {
        // Usuario logueado y token válido
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaInicio()),
        );
      } else {
        // Usuario no logueado o token inválido
        if (AuthService.isLoggedIn) {
          // Token inválido, hacer logout
          await AuthService.logout();
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaInicio()),
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
