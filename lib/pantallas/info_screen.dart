import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fam_intento1/database/databese_helper.dart';
import 'package:fam_intento1/services/api_service.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  List<dynamic> _personal = [];
  bool _isLoading = true;

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
    return Scaffold(
      backgroundColor: const Color(0xFF135685),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            
            // --- HEADER: DIRECTORIO ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_alt_outlined, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                const Text(
                  "DIRECTORIO",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "FAM BOLIVIA",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
                letterSpacing: 3.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 30),

            // --- LIST MAIN AREA ---
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _personal.isEmpty
                    ? const Center(child: Text("No hay información de personal disponible.", style: TextStyle(color: Colors.white70)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: _personal.length + 1, // +1 para la tarjeta de Vision y Mision
                        itemBuilder: (context, index) {
                          if (index == _personal.length) {
                             return _buildVisionMissionCard();
                          }
                          final p = _personal[index];
                          return _buildPersonalCard(p);
                        },
                      ),
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
      margin: const EdgeInsets.only(bottom: 25),
      // La tarjeta tiene borde redondeado en todos sus lados. 
      // El fondo de la tarjeta es blanco.
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          // Mitad superior azul oscuro (#135685)
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFF054D9E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Container(
                  // Para dar el efecto de "borde" del container superior como en la imagen,
                  // que a pesar de ser del mismo color que el fondo, se distingue. Se puede agregar un margen y borderRadius mas pequeño o un borde blanco.
                  margin: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFF135685),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(23)),
                  ),
                ),
              ),
              // Borde blanco interior de la parte superior
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                )
              ),
              // Foto de perfil sobre la linea
              Positioned(
                bottom: -45, // Mitad de la foto
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFFFFFFF), width: 1),
                      ),
                      child: ClipOval(
                        child: foto.isNotEmpty 
                          ? CachedNetworkImage(
                              imageUrl: foto, 
                              fit: BoxFit.cover, 
                              placeholder: (context, url) => const CircularProgressIndicator(color: Color(0xFF6EC6D8)),
                              errorWidget: (context, url, err) => const Icon(Icons.person, size: 45, color: Colors.grey)
                            )
                          : const Icon(Icons.person, size: 45, color: Colors.grey),
                      ),
                    ),
                    // Icono redondito celestial
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6EC6D8),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF135685), width: 1.5),
                        ),
                        child: const Icon(Icons.people_alt, color: Colors.white, size: 14),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          
          // Mitad blanca abajo
          const SizedBox(height: 55), // Espacio para la foto
          Padding(
             padding: const EdgeInsets.symmetric(horizontal: 10),
             child: Text(
               nombre,
               textAlign: TextAlign.center,
               style: const TextStyle(
                 color: Color(0xFF135685),
                 fontSize: 20,
                 fontWeight: FontWeight.bold,
               ),
             ),
          ),
          const SizedBox(height: 5),
          Padding(
             padding: const EdgeInsets.symmetric(horizontal: 10),
             child: Text(
               cargo,
               textAlign: TextAlign.center,
               style: const TextStyle(
                 color: Color(0xFF6EC6D8),
                 fontSize: 14,
               ),
             ),
          ),
          
          const SizedBox(height: 10),
          
          // Paneles de celular y correo
          _buildContactBox(Icons.phone, "CELULAR", celular),
          _buildContactBox(Icons.email_outlined, "CORREO", correo),
          
          const SizedBox(height: 25),
        ],
      )
    );
  }

  // --- COMPONENTE: CAJA DE CONTACTO ---
  Widget _buildContactBox(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
         color: const Color(0xFFF2F7F9), // Celeste agrisado como en el mockup
         borderRadius: BorderRadius.circular(15),
         border: Border.all(color: const Color(0xFF6EC6D8).withOpacity(0.3)), // Un celeste sutil
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF135685), // Azul oscuro
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6EC6D8), // Celeste cyan
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF135685),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- COMPONENTE: TARJETA DE VISIÓN Y MISIÓN ---
  Widget _buildVisionMissionCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 25, top: 10),
      // Borde redondeado y fondo blanco
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Cabecera Azul Oscuro ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF135685),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            width: double.infinity,
            child: Column(
              children: [
                const Text(
                  "VISIÓN Y MISIÓN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "FAM BOLIVIA",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
          
          // --- Sección Misión ---
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Misión:",
                  style: TextStyle(
                    color: Color(0xFF135685),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Representar a los Gobiernos Autónomos Municipales precautelando el pleno ejercicio de su autonomía, con capacidad técnica, administrativa y con protagonismo en el Desarrollo del Estado Plurinacional de Bolivia.",
                  style: TextStyle(
                    color: Color(0xFF135685),
                    fontSize: 14.5,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          
          // Línea divisoria suave
          Divider(color: Colors.grey.withOpacity(0.2), indent: 25, endIndent: 25, height: 1),
          
          // --- Sección Visión ---
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Visión:",
                  style: TextStyle(
                    color: Color(0xFF135685),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "La FAM-Bolivia es una entidad inclusiva, con institucionalidad sustentada por Ley, de administración descentralizada, con sostenibilidad técnica-financiera, modelo y líder del Asociativismo de Gobiernos Municipales en Latinoamérica.",
                  style: TextStyle(
                    color: Color(0xFF135685),
                    fontSize: 14.5,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

