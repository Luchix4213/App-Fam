import 'package:flutter/material.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/services/api_service.dart';
import 'package:fam_intento1/services/sync_service.dart';
import 'package:fam_intento1/database/databese_helper.dart';
import 'package:fam_intento1/pantallas/miembros.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AsociacionesScreen extends StatefulWidget {
  const AsociacionesScreen({super.key});

  @override
  State<AsociacionesScreen> createState() => _AsociacionesScreenState();
}

class _AsociacionesScreenState extends State<AsociacionesScreen> {
  // --- Lógica Original ---
  List<dynamic> _asociaciones = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<dynamic> _filteredAsociaciones = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAsociaciones();
    _searchCtrl.addListener(_filterAsociaciones);
    SyncService.onDataUpdated.addListener(_onDataUpdated);
  }

  @override
  void dispose() {
    SyncService.onDataUpdated.removeListener(_onDataUpdated);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onDataUpdated() {
    if (mounted) {
      _loadAsociaciones(forceLocalOnly: true);
    }
  }

  void _filterAsociaciones() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredAsociaciones = _asociaciones.where((a) {
        final nombre = (a['nombre'] ?? '').toLowerCase();
        final alias = (a['alias'] ?? '').toLowerCase();
        return nombre.contains(query) || alias.contains(query);
      }).toList();
    });
  }

  List<dynamic> _sortAsociaciones(List<dynamic> list) {
    final sortedList = List<dynamic>.from(list);
    sortedList.sort((a, b) {
      final nameA = (a['alias'] ?? a['nombre'] ?? '').toString().toUpperCase();
      final nameB = (b['alias'] ?? b['nombre'] ?? '').toString().toUpperCase();
      
      int getPriority(String name) {
        // Usa RegExp con word boundaries para exactamente "AMB" o su nombre largo
        if (name == 'FAM BOLIVIA') return 1;
        if (name.contains('ACOBOL')) return 2;
        if (RegExp(r'\bAMB\b').hasMatch(name) || name.contains('MUNICIPALIDADES DE BOLIVIA')) return 3;
        return 4;
      }
      
      final priorityA = getPriority(nameA);
      final priorityB = getPriority(nameB);
      
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      return nameA.compareTo(nameB);
    });
    return sortedList;
  }

  Future<void> _loadAsociaciones({bool forceLocalOnly = false}) async {
    // 1. Cargar datos locales inmediatamente (Ultra rápido)
    try {
      final localData = await DatabaseHelper.instance.getAllAsociaciones();
      if (localData.isNotEmpty) {
         setState(() {
          _asociaciones = _sortAsociaciones(localData);
          _filteredAsociaciones = List.from(_asociaciones);
          _isLoading = false;
        });
      } else {
        // Solo mostramos loading si el caché local está verdaderamente vacío
        setState(() { _isLoading = true; _errorMessage = null; });
      }
    } catch (e) {
      print("Warning: Error leyendo SQLite \${e}");
    }

    // 2. Intentar actualizar en background desde la API (Silencioso)
    if (!forceLocalOnly) {
      try {
        final res = await ApiService.getAllAsociaciones();
        if (res['success'] == true) {
          final List<dynamic> data = res['data'];
          
          // Sanitizar y guardar en SQLite
          List<Map<String, dynamic>> asocClean = data.map((item) {
            Map<String, dynamic> map = Map<String, dynamic>.from(item);
            map.removeWhere((key, value) => value is Map || value is List);
            return map;
          }).toList();
          
          // Actualizamos la copia local
          await DatabaseHelper.instance.syncAsociaciones(asocClean);
          
          // Actualizamos UI solo si seguimos en pantalla
          if (mounted) {
             setState(() {
              _asociaciones = _sortAsociaciones(data);
              // Si el usuario estaba buscando algo, re-aplicamos el filtro
              _filterAsociaciones(); 
              _isLoading = false;
              _errorMessage = null;
            });
          }
        } else {
          // El backend devolvió success=false (Ej: base de datos vacía o error 404/500)
          print("Fallo de API: \${res['message']}");
          if (mounted) {
            setState(() {
              _isLoading = false;
              if (_asociaciones.isEmpty) {
                _errorMessage = res['message'] ?? "No se encontraron datos en el servidor.";
              }
            });
          }
        }
      } catch (apiError) {
        // 3. Fallo de red. Manejamos en silencio si ya teníamos datos, o mostramos error si estaba vacío.
        print("Background Fetch Error: \$apiError.");
        if (mounted) {
          setState(() {
            _isLoading = false;
            if (_asociaciones.isEmpty) {
              _errorMessage = "No hay asociaciones disponibles y no hay conexión a internet.";
            }
          });
        }
      }
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
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      appColores.assocGradientTop,     // Azul oscuro
                      appColores.assocGradientMiddle,  // Azul medio
                      appColores.assocGradientBottom,  // Gris claro abajo
                    ],
                    stops: [0.0, 0.5, 1.0],            // Distribución suave
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
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: () => Navigator.pop(context),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 10),
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
                            // Sin Botón "Iniciar Sesión" (fue eliminado a pedido del usuario previamente, pero el layout de Departamentos lo tenía. Lo quitamos como pidió antes).
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 80), // Ajustable según diseño
              
              // Lista de Asociaciones
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: appColores.primaryGreen))
                    : _buildList(),
              ),
            ],
          ),

          // 2. Tarjeta Flotante "Asociaciones" (Positioned)
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
                    color: const Color(0xFF2A6FA8),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white, 
                      width: 0.6, 
                    ),
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
                            "Asociaciones",
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
                      Text(
                        "Sistema Asociativo Municipal. Selecciona una asociación para ver sus municipios.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Barra de Búsqueda Flotante
                Transform.translate(
                  offset: const Offset(0, -25),
                  child: Container(
                    margin: const EdgeInsets.only(top: 40),
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
                        hintText: "Buscar asociación...",
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
                          borderSide: const BorderSide(color: appColores.assocGradientMiddle, width: 1),
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
            TextButton(
              onPressed: _loadAsociaciones,
              child: const Text("Reintentar", style: TextStyle(color: appColores.primaryGreen)),
            )
          ],
        ),
      );
    }
    if (_filteredAsociaciones.isEmpty) {
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

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      itemCount: _filteredAsociaciones.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildAsociacionCard(_filteredAsociaciones[index]);
      },
    );
  }

  Widget _buildAsociacionCard(Map<String, dynamic> asociacion) {
    // Usamos el alias o nombre
    final nombreAsoc = asociacion['alias'] ?? asociacion['nombre'] ?? 'Sin nombre';
    final imageUrl = asociacion['foto'] ?? '';
    // Si contiene ciertas palabras (como ACOBOL, AMB) u otro prefijo asocia a logos
    bool isLogo = true; // Por default asumimos logo para asociaciones
    
    // Extraer color
    Color? asociacionColor;
    final colorHex = asociacion['color'];
    if (colorHex != null && colorHex.toString().isNotEmpty) {
      String hex = colorHex.toString().replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      asociacionColor = Color(int.parse(hex, radix: 16));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: asociacionColor != null 
            ? Border.all(color: asociacionColor, width: 2) 
            : null,
        boxShadow: [
          BoxShadow(
            color: asociacionColor?.withOpacity(0.2) ?? const Color(0xFF90A4AE).withOpacity(0.15),
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
          onTap: () {            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MiembrosScreen(
                  asociacionId: asociacion['id'],
                  asociacionNombre: nombreAsoc,
                  asociacionColor: asociacionColor,
                ),
              ),
            );
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(color: Colors.grey.shade100), 
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildAsociacionImage(imageUrl, isLogo),
                  ),
                ),
                
                const SizedBox(width: 18),
                
                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreAsoc,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF263238),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Ver miembros de la asociación",
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
                          color: appColores.assocGradientMiddle.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "ASOCIACIÓN",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: appColores.assocGradientMiddle,
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

  Widget _buildAsociacionImage(String imageUrl, bool isLogo) {
    if (imageUrl.isNotEmpty) {
      String url = imageUrl;
      if (!url.startsWith('http')) {
        if (!url.startsWith('/')) url = '/\$url';
        url = '${ApiService.baseUrl.replaceAll('/api', '')}\$url';
      }
      
      return CachedNetworkImage(
        imageUrl: url,
        fit: isLogo ? BoxFit.contain : BoxFit.cover,
        placeholder: (context, ref) => const Center(child: Icon(Icons.refresh, size: 20, color: Colors.grey)),
        errorWidget: (context, ref, error) => const Icon(Icons.business, color: Colors.grey, size: 30),
      );
    }
    return const Icon(Icons.business, color: Colors.grey, size: 30);
  }
}
