import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/database/databese_helper.dart';
import 'package:fam_intento1/services/api_service.dart';
import 'package:fam_intento1/widgets/gradient_scaffold.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  List<dynamic> _personal = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPersonal();
  }

  Future<void> _loadPersonal() async {
    // 1. Cargar offline rápido
    final localData = await DatabaseHelper.instance.getAllPersonal();
    if (mounted) {
      setState(() {
        _personal = localData;
        _isLoading = _personal.isEmpty; 
      });
    }

    // 2. Fetch silencioso en background
    try {
      final res = await ApiService.getAllPersonal(estado: 'activo');
      if (res['success'] == true) {
        final List<dynamic> onlineData = res['data'];
        
        // Sincronizar la BD local con los nuevos datos
        List<Map<String, dynamic>> cleanData = onlineData.map((item) {
          Map<String, dynamic> map = Map<String, dynamic>.from(item);
          map.removeWhere((key, value) => value is Map || value is List);
          return map;
        }).toList();
        
        await DatabaseHelper.instance.deleteAllPersonal();
        await DatabaseHelper.instance.syncPersonal(cleanData);

        if (mounted) {
          setState(() {
            _personal = onlineData;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Ignorar el error para que el usuario siga viendo la UI local tranqui
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            
            // --- HEADER: DIRECTORIO MUNICIPAL ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.people_alt_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  "DIRECTORIO",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "FAM BOLIVIA",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                letterSpacing: 4.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 30),

            // --- CAROUSEL MAIN AREA ---
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _personal.isEmpty
                    ? const Center(child: Text("No hay información de personal disponible.", style: TextStyle(color: Colors.white70)))
                    : CarouselSlider.builder(
                        itemCount: _personal.length,
                        options: CarouselOptions(
                          aspectRatio: 0.65, // Responsive instead of fixed height
                          enlargeCenterPage: true,
                          autoPlay: false, // Desactivado para interactuar con calma
                          enableInfiniteScroll: _personal.length > 1,
                          viewportFraction: 0.82,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                        ),
                        itemBuilder: (context, index, realIdx) {
                          final p = _personal[index];
                          return _buildPersonalCard(p);
                        },
                      ),
            ),

            const SizedBox(height: 15),

            // --- PAGINATION INDICATORS ---
            if (!_isLoading && _personal.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chevron_left, color: Colors.white54, size: 28),
                  const SizedBox(width: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _personal.asMap().entries.map((entry) {
                      return Container(
                        width: _currentIndex == entry.key ? 22.0 : 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            color: Colors.white.withOpacity(_currentIndex == entry.key ? 0.9 : 0.2)
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.chevron_right, color: Colors.white54, size: 28),
                ],
              ),
              
            if (!_isLoading && _personal.isNotEmpty)
               Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 15),
                  child: Text(
                     "${_currentIndex + 1} / ${_personal.length}",
                     style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12)
                  )
               ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET TARJETA DE CADA PERSONA ---
  Widget _buildPersonalCard(Map<String, dynamic> p) {
    final String foto = p['foto']?.toString() ?? "";
    final String nombre = p['nombre']?.toString() ?? "Sin Nombre";
    final String cargo = p['cargo']?.toString() ?? "Sin Cargo";
    final String celular = (p['celular'] != null && p['celular'].toString().trim().isNotEmpty) ? p['celular'].toString().trim() : "No registrado";
    final String correo = (p['correo_electronico'] != null && p['correo_electronico'].toString().trim().isNotEmpty) ? p['correo_electronico'].toString().trim() : "No registrado";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF166CC8), Color(0xFF144A8C)], // Gradiente azul brillante estilo tarjeta
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // Elementos decorativos de fondo (puntos arriba a la izquierda)
            Positioned(
              top: 15,
              left: 15,
              child: Icon(Icons.apps, color: Colors.white.withOpacity(0.1), size: 35),
            ),
            
            Column(
              children: [
                const SizedBox(height: 20),
                
                // Minitarjeta escudo FAM
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: const Icon(Icons.security, color: Colors.white, size: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  "FAM - BOLIVIA",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // --- FOTO CÍRCULOS CONCÉNTRICOS ---
                Container(
                  width: 120, // Reducido de 140
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 2), // Anillo exterior
                  ),
                  child: Center(
                    child: Container(
                      width: 100, // Reducido de 115
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 3), // Anillo medio
                      ),
                      child: Center(
                        child: ClipOval(
                          child: foto.isNotEmpty 
                            ? CachedNetworkImage(
                                imageUrl: foto, 
                                fit: BoxFit.cover, 
                                width: 90, 
                                height: 90,
                                placeholder: (context, url) => Container(color: Colors.white12, child: const CircularProgressIndicator(color: Colors.white)),
                                errorWidget: (context, url, err) => Container(color: Colors.white24, child: const Icon(Icons.person, size: 45, color: Colors.white))
                              )
                            : Container(
                                width: 90, 
                                height: 90, 
                                color: Colors.white24, 
                                child: const Icon(Icons.person, size: 45, color: Colors.white)
                              ),
                        )
                      )
                    )
                  )
                ),
                
                const SizedBox(height: 20),
                
                // --- INFORMACIÓN NOMBRE / CARGO ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    nombre,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  cargo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                
                const Spacer(),
                
                // --- PANELES DE CONTACTO ---
                _buildGlassPanel(Icons.phone_outlined, "CELULAR", celular),
                _buildGlassPanel(Icons.email_outlined, "CORREO", correo),
                
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTE: PANEL DE CRISTAL PARA REDES ---
  Widget _buildGlassPanel(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)
            ),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label, 
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)
                ),
                const SizedBox(height: 2),
                Text(
                  value, 
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                ),
              ],
            ),
          )
        ],
      )
    );
  }
}
