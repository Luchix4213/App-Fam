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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  String _statusMessage = 'Iniciando...';
  bool _isSuccess = false;
  bool _isError = false;
  late AnimationController _logoController;
  late Animation<double> _logoAnim;

  @override
  void initState() {
    super.initState();
    // Animación de aparición del logo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoAnim = CurvedAnimation(parent: _logoController, curve: Curves.easeOut);
    _logoController.forward();

    _initApp();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  void _setStatus(String msg, {bool success = false, bool error = false}) {
    if (mounted) {
      setState(() {
        _statusMessage = msg;
        _isSuccess = success;
        _isError = error;
      });
    }
  }

  Future<void> _initApp() async {
    // Pequeña pausa para que el logo aparezca primero
    await Future.delayed(const Duration(milliseconds: 600));
    _setStatus('Conectando al servidor...');

    bool syncOk = false;

    try {
      // Intentar sincronizar con el backend
      await SyncService.syncAll();

      // Verificar si realmente pudimos traer datos
      final asociaciones = await DatabaseHelper.instance.getAllAsociaciones();
      if (asociaciones.isNotEmpty) {
        syncOk = true;
        _setStatus('Conexion exitosa', success: true);
      } else {
        // El sync corrió pero no hay nada en local (primera instalación sin red)
        _setStatus(
          'Sin datos disponibles. Verifica tu conexión.',
          error: true,
        );
      }
    } catch (e) {
      // Error de red: intentar con datos locales
      _setStatus('Sin conexión. Cargando datos locales...');
      await Future.delayed(const Duration(milliseconds: 800));

      try {
        final localData = await DatabaseHelper.instance.getAllAsociaciones();
        if (localData.isNotEmpty) {
          _setStatus('✓ Datos cargados desde caché local', success: true);
          syncOk = true;
        } else {
          _setStatus(
            '⚠ Sin internet y sin datos locales disponibles.',
            error: true,
          );
        }
      } catch (_) {
        _setStatus('⚠ Error al leer los datos locales.', error: true);
      }
    }

    // Esperar un momento para que el usuario lea el mensaje final
    await Future.delayed(Duration(seconds: syncOk ? 1 : 2));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PublicMainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _isSuccess
        ? const Color(0xFF4CAF50) // Verde éxito
        : _isError
        ? const Color(0xFFEF5350) // Rojo error
        : Colors.grey.shade500;   // Gris neutral

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            // Logo ocupa la mayor parte de la pantalla
            Expanded(
              child: Center(
                child: ScaleTransition(
                  scale: _logoAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/famlogo.png',
                        height: 160,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Directorio Municipal',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: appColores.dashTealStart,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'FAM Bolivia',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Zona de estado inferior
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 48),
              child: Column(
                children: [
                  // Indicador de carga (solo visible cuando no hay resultado final)
                  if (!_isSuccess && !_isError)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: appColores.dashTealStart,
                      ),
                    )
                  else
                    Icon(
                      _isSuccess ? Icons.check_circle_rounded : Icons.warning_rounded,
                      color: statusColor,
                      size: 24,
                    ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Text(
                      _statusMessage,
                      key: ValueKey(_statusMessage),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
