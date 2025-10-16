import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/pantallas/buscar.dart';
import 'package:flutter/material.dart';
import 'package:fam_intento1/core/text.dart'; // tus estilos de texto
import 'package:fam_intento1/services/auth_service.dart';
import 'package:fam_intento1/pantallas/login.dart';
import 'package:fam_intento1/pantallas/departamentos.dart';

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
      backgroundColor: appColores.backgraund, // fondo limpio
      appBar: AppBar(
        backgroundColor: appColores.backgraund,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text(
              'Iniciar sesión',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => _logout(context),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Text(
                "FAM BOLIVIA",
                style: TextStyles.titulo
              ),
            ),
            const SizedBox(height: 10),
            
            Image.asset(
              "assets/images/famlogo.png",
              height: 250,
            ),

            
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Text(
                    "BUSQUEDA DE MINISTROS",
                    style: TextStyles.subtitulo,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  Padding(
                    padding: const EdgeInsets.only(left:20, right:20, bottom:10),
                    child: Text(
                      "Bienvenido a nuestra aplicación de búsqueda de ministros de la institución FAM Bolivia. ¡Acompáñanos!",
                      style: TextStyles.textosimple,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 72, 228, 33), // verde
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Navegar a departamentos
                    Navigator.push(context, MaterialPageRoute(builder:(context) => const DepartamentosScreen()));
                  },
                  child: const Text(
                    "VER DEPARTAMENTOS",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
