import 'package:flutter/material.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/services/api_service.dart'; // Mantener imports originales por si acaso
// import 'package:fam_intento1/pantallas/asociaciones.dart'; // Ya no se usa
import 'package:fam_intento1/pantallas/miembros.dart'; // Nueva navegación directa
import 'package:fam_intento1/database/databese_helper.dart';
import 'package:fam_intento1/pantallas/info_screen.dart';
import 'package:fam_intento1/pantallas/contacto_screen.dart';

class DepartamentosScreen extends StatefulWidget {
  const DepartamentosScreen({super.key});

  @override
  State<DepartamentosScreen> createState() => _DepartamentosScreenState();
}

class _DepartamentosScreenState extends State<DepartamentosScreen> {
  // --- Lógica Original ---
  List<dynamic> _departamentos = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<dynamic> _filteredDepartamentos = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDepartamentos();
    _searchCtrl.addListener(_filterDepartamentos);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filterDepartamentos() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredDepartamentos = _departamentos.where((d) {
        final nombre = (d['nombre'] ?? '').toLowerCase();
        return nombre.contains(query);
      }).toList();
    });
  }

  Future<void> _loadDepartamentos() async {
    setState(() { // Asegurar loading state al recargar
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await DatabaseHelper.instance.getAllDepartamentos();
      setState(() {
        _isLoading = false;
        _departamentos = data;
        _filteredDepartamentos = data;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error cargando datos locales: $e";
      });
    }
  }

  // --- UI Construcción ---

  @override
  Widget build(BuildContext context) {
    // Definimos altura del header
    const double headerHeight = 220; 

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // Fondo gris muy claro limpio
      body: Stack(
        children: [
          // 1. Column principal con Header y contenido
          Column(
            children: [
              // Header Gradient
              Container(
                height: headerHeight,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [appColores.headerTealStart, appColores.headerTealEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        // NavBar Superior
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Logo e Izquierda
                            Row(
                              children: [
                                // Placeholder para logo pequeño si existe, sino icono
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.people_alt, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "FAM BOLIVIA",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            // Botón Iniciar Sesión Clean
                            TextButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              icon: const Text(
                                "Iniciar Sesión",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              label: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Espaciador para empujar la lista hacia abajo y dejar espacio a la tarjeta flotante
              // La tarjeta flotante medirá aprox 160-180.
              // El header mide 220. 
              // Queremos que la lista empiece debajo de la tarjeta.
              const SizedBox(height: 80), // Ajustable según diseño
              
              // Lista de Departamentos
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: appColores.primaryGreen))
                    : _buildList(),
              ),
            ],
          ),

          // 2. Tarjeta Flotante "Departamentos" (Positioned)
          Positioned(
            top: 100, // Ajustar posición vertical sobre el header
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Info Card Principal
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [appColores.cardLimeStart, appColores.cardLimeEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B5E20).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Departamentos",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Icono decorativo sutil
                          Icon(Icons.map_outlined, color: Colors.white.withOpacity(0.3), size: 40),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Sistema Asociativo Municipal. Selecciona un departamento para ver las asociaciones municipales.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Barra de Búsqueda Flotante (Justo debajo o sobrelapada)
                Transform.translate(
                  offset: const Offset(0, -25), // Subir un poco para montarse en la tarjeta anterior o dejarla debajo
                  // En la foto 1: La búsqueda parece estar aparte abajo. 
                  // En la descripción del usuario: "Incluye icono de búsqueda justo debajo".
                  // Vamos a ponerla separada debajo con un poco de margen.
                  child: Container(
                    margin: const EdgeInsets.only(top: 40), // Margen respecto al contenido de la tarjeta
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: "Buscar departamento...",
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: appColores.primaryGreen, width: 1),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
             if (index == 0) {
               // Ya estamos en inicio/departamentos, quizás scroll up?
             } else if (index == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const InfoScreen()));
             } else if (index == 2) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactoScreen()));
             }
          },
          selectedItemColor: appColores.primaryGreen,
          unselectedItemColor: Colors.grey.shade400,
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled), 
              label: 'Inicio'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline_rounded), 
              label: 'Info'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.phone_outlined), 
              label: 'Contacto'
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 10),
            Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
            TextButton(onPressed: _loadDepartamentos, child: const Text("Reintentar"))
          ],
        ),
      );
    }
    if (_filteredDepartamentos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text("No encontrado", style: TextStyle(color: Colors.grey.shade400)),
          ],
        ),
      );
    }

    // Calcular padding top para la lista: 
    // Header (220) + Tarjeta (aprox 200) - Overlap
    // Usamos un padding generoso arriba porque la lista está en un Expanded debajo de un SizedBox(80).
    // Pero la tarjeta Positioned está encima.
    // La tarjeta empieza en top:100. Altura aprox 250 (Card + Search). Fin aprox 350.
    // El Column tiene Header(220) + SizedBox(80) = 300.
    // Necesitamos más espacio arriba en la lista.
    
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20), // Top padding extra para librar la búsqueda
      itemCount: _filteredDepartamentos.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildDepartamentoCard(_filteredDepartamentos[index]);
      },
    );
  }

  Widget _buildDepartamentoCard(Map<String, dynamic> departamento) {
    final nombreDepartamento = departamento['nombre'] ?? 'Sin nombre';
    // Solo forzamos modo "Logo" si realmente queremos que se vea pequeño/contenido.
    final isLogo = nombreDepartamento.toLowerCase().contains('acobol') || nombreDepartamento.toLowerCase().contains('amb');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            // CORRECCIÓN NAVEGACIÓN: Consultar ID de asociación real
            // El ID del departamento NO SIEMPRE es el ID de la asociación.
            try {
              final asociaciones = await DatabaseHelper.instance.getAsociacionesByDepto(departamento['id']);
              
              if (asociaciones.isEmpty) {
                 if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("No hay asociaciones registradas para este departamento"))
                   );
                 }
                 return;
              }

              if (asociaciones.length == 1) {
                // Caso ideal: 1 Depto -> 1 Asoc (ej. Pando -> AMDEPANDO)
                final asoc = asociaciones.first;
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MiembrosScreen(
                        asociacionId: asoc['id'],
                        asociacionNombre: asoc['nombre'], // Usar nombre de la asociación (ej. AMDEBENI)
                      ),
                    ),
                  );
                }
              } else {
                // Caso múltiple: Mostrar selector
                if (context.mounted) {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (ctx) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Seleccionar Asociación", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          ...asociaciones.map((a) => ListTile(
                            leading: const Icon(Icons.business),
                            title: Text(a['nombre']),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pop(ctx); // Cerrar modal
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MiembrosScreen(
                                    asociacionId: a['id'],
                                    asociacionNombre: a['nombre'],
                                  ),
                                ),
                              );
                            },
                          )),
                        ],
                      ),
                    ),
                  );
                }
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error buscando asociaciones: $e")));
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                // Imagen/Logo Card
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.white, // Fondo blanco limpio para evitar bordes azules en logos transparentes
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(color: Colors.grey.shade100), // Borde sutil
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildDepartmentImage(departamento, isLogo),
                  ),
                ),
                
                const SizedBox(width: 18),
                
                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreDepartamento,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF263238),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Ver asociaciones municipales",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: appColores.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "DEPARTAMENTO",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: appColores.primaryGreen,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentImage(Map<String, dynamic> depto, bool isLogo) {
    // 1. Si viene URL de API (y no es nula/vacía)
    if (depto['foto'] != null && depto['foto'].toString().isNotEmpty) {
      String url = depto['foto'];
      // Ajustar URL si es relativa
      if (!url.startsWith('http')) {
        // Asegurar slash
        if (!url.startsWith('/')) url = '/$url';
        url = '${ApiService.baseUrl.replaceAll('/api', '')}$url';
      }
      
      return Image.network(
        url,
        fit: isLogo ? BoxFit.contain : BoxFit.cover, // Cover para fotos de paisaje (Deptos), Contain para Logos
        loadingBuilder: (_, child, p) => p == null ? child : const Center(child: Icon(Icons.refresh, size: 20, color: Colors.grey)),
        errorBuilder: (_, __, ___) => Icon(isLogo ? Icons.business : Icons.location_city, color: Colors.grey, size: 30),
      );
    }
    
    // 2. Fallback sin foto
    return Icon(isLogo ? Icons.business : Icons.location_city, color: Colors.grey, size: 30);
  }
}
