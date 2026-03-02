import 'package:flutter/material.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/widgets/admin_drawer.dart';

class SincronizarScreen extends StatefulWidget {
  const SincronizarScreen({super.key});

  @override
  State<SincronizarScreen> createState() => _SincronizarScreenState();
}

class _SincronizarScreenState extends State<SincronizarScreen> {
  bool _isSyncing = false;
  double _progress = 0.0;

  Future<void> _startSync() async {
    setState(() {
      _isSyncing = true;
      _progress = 0.0;
    });

    // Simulación de sincronización
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) setState(() => _progress = i / 100);
    }

    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sincronización completada con éxito"), backgroundColor: appColores.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColores.backgraund,
      appBar: AppBar(
        title: const Text("Sincronizar Datos", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: appColores.color1,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: const AdminDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)
                  ]
                ),
                child: Icon(
                  _isSyncing ? Icons.sync : Icons.cloud_sync,
                  size: 80,
                  color: _isSyncing ? appColores.color1 : appColores.color4,
                ),
              ),
              const SizedBox(height: 40),
              
              if (_isSyncing) ...[
                const Text("Sincronizando...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: appColores.greyText)),
                const SizedBox(height: 16),
                LinearProgressIndicator(value: _progress, minHeight: 10, borderRadius: BorderRadius.circular(10), color: appColores.color1, backgroundColor: Colors.grey[200]),
                const SizedBox(height: 8),
                Text("${(_progress * 100).toInt()}%", style: const TextStyle(color: Colors.grey)),
              ] else ...[
                 const Text(
                  "Mantén tus datos actualizados",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: appColores.color4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Presiona el botón para sincronizar la información local con el servidor.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _startSync,
                    icon: const Icon(Icons.sync, color: Colors.white),
                    label: const Text("Sincronizar Ahora", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColores.color2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
