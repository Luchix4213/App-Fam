import 'package:flutter/material.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/pantallas/Inicio.dart';
import 'package:fam_intento1/pantallas/info_screen.dart';
import 'package:fam_intento1/pantallas/contacto_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fam_intento1/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';

class PublicMainScreen extends StatefulWidget {
  const PublicMainScreen({super.key});

  @override
  State<PublicMainScreen> createState() => _PublicMainScreenState();
}

class _PublicMainScreenState extends State<PublicMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PantallaInicio(), // Tab 0: Inicio
    const InfoScreen(),     // Tab 1: Info (Placeholder)
    const ContactoScreen(), // Tab 2: Contacto (Placeholder)
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowNoticias();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkAndShowNoticias() async {
    try {
      final res = await ApiService.getAllNoticias(activas: true);
      if (res['success'] == true) {
        final List noticias = res['data'] ?? [];
        if (noticias.isNotEmpty) {
          // Tomar la primera noticia (la mas reciente activa)
          final noticia = noticias.first;
          final int id = noticia['id'];
          final String cacheKey = 'noticia_vista_tiempo_$id';
          
          final prefs = await SharedPreferences.getInstance();
          final int lastSeenMs = prefs.getInt(cacheKey) ?? 0;
          final int nowMs = DateTime.now().millisecondsSinceEpoch;
          
          // 2 horas = 2 * 60 * 60 * 1000 = 7,200,000 milisegundos
          final bool mostrarNoticia = (nowMs - lastSeenMs) > 7200000;
          
          if (mostrarNoticia) {
             if (mounted) {
               await _showNoticiaPopup(noticia);
               await prefs.setInt(cacheKey, nowMs); // Guardar el momento de la última vista
             }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching noticias en popup: $e");
    }
  }

  Future<void> _showNoticiaPopup(Map<String, dynamic> noticia) async {
    final titulo = noticia['titulo'] ?? '';
    final descripcion = noticia['descripcion'] ?? '';
    final imgUrl = noticia['imagen_url'] ?? '';

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Cerrar anuncio",
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(color: Colors.transparent),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                  ]
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Imagen Superior
                    if (imgUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                        child: CachedNetworkImage(
                          imageUrl: imgUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 220,
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator(color: appColores.dashTealStart)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 220,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                          ),
                        ),
                      ),
                    
                    // Cuerpo Texto
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                      child: Column(
                        children: [
                          Text(
                            titulo,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: appColores.dashTealStart),
                          ),
                          if (descripcion.isNotEmpty) ...[
                            const SizedBox(height: 15),
                            Text(
                              descripcion,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15, color: Colors.black54),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appColores.dashTealStart,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 5,
                              ),
                              child: const Text("Entendido", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Boton Floante (X) para cerrar
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1)
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            )
          ],
        );
      },
       transitionBuilder: (context, anim, secondaryAnim, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ]
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: appColores.primaryGreen,
          unselectedItemColor: Colors.grey,
          backgroundColor: appColores.white,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              activeIcon: Icon(Icons.info),
              label: 'Info',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.phone_outlined),
              activeIcon: Icon(Icons.phone),
              label: 'Contacto',
            ),
          ],
        ),
      ),
    );
  }
}
