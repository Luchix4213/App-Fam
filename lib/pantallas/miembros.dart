import 'package:flutter/material.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/services/api_service.dart';
import 'package:fam_intento1/services/auth_service.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fam_intento1/database/databese_helper.dart';
import 'package:fam_intento1/pantallas/info_screen.dart';
import 'package:fam_intento1/pantallas/contacto_screen.dart';

class MiembrosScreen extends StatefulWidget {
  final int asociacionId;
  final String asociacionNombre;

  const MiembrosScreen({
    super.key,
    required this.asociacionId,
    required this.asociacionNombre,
  });

  @override
  State<MiembrosScreen> createState() => _MiembrosScreenState();
}

class _MiembrosScreenState extends State<MiembrosScreen> {
  List<dynamic> _miembros = [];
  List<dynamic> _filteredMiembros = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchCtrl = TextEditingController();

  static const List<String> _amdesDepartamentos = [
    'beni', 'chuquisaca', 'cochabamba', 'lapaz', 'oruro', 'pando', 'potosi', 'santacruz', 'tarija',
  ];

  @override
  void initState() {
    super.initState();
    _loadMiembros();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredMiembros = _miembros.where((m) {
        final nombre = (m['nombre'] ?? '').toLowerCase();
        final alias = (m['alias'] ?? '').toLowerCase();
        final municipio = (m['municipio'] ?? '').toLowerCase();
        return nombre.contains(query) || alias.contains(query) || municipio.contains(query);
      }).toList();
    });
  }

  Future<void> _loadMiembros() async {
    // 1. Cargar datos locales inmediatamente
    try {
      final localData = await DatabaseHelper.instance.getMinistrosByAsoc(widget.asociacionId);
      if (localData.isNotEmpty) {
        if (mounted) {
          setState(() {
            _procesarListaMiembros(localData);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() { _isLoading = true; _errorMessage = null; });
        }
      }
    } catch (e) {
      print("Warning: Error leyendo SQLite \$e");
    }

    // 2. Intentar actualizar en background desde la API
    try {
      final res = await ApiService.getMiembrosByAsociacion(widget.asociacionId);
      if (res['success'] == true) {
        final List<dynamic> data = res['data'];
        
        // Sanitizar y guardar en SQLite
        List<Map<String, dynamic>> miemClean = data.map((item) {
          Map<String, dynamic> map = Map<String, dynamic>.from(item);
          map.removeWhere((key, value) => value is Map || value is List);
          return map;
        }).toList();

        await DatabaseHelper.instance.syncMinistros(miemClean);
        
        // Actualizamos UI solo si seguimos en pantalla
        if (mounted) {
          setState(() {
            _procesarListaMiembros(data);
            _filter();
            _isLoading = false;
            _errorMessage = null;
          });
        }
      }
    } catch (apiError) {
      print("Background Fetch Error: \$apiError.");
      if (mounted && _miembros.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = "No hay miembros disponibles y no hay conexión a internet.";
        });
      }
    }
  }

  void _procesarListaMiembros(List<dynamic> data) {
    final List<dynamic> miembrosList = List<dynamic>.from(data);
    miembrosList.sort((a, b) {
      final tipoA = _detectarTipoAsociacion(a);
      final tipoB = _detectarTipoAsociacion(b);
      String keyA = tipoA == 'AMDES' ? (a['municipio'] ?? '').toString().toUpperCase() : (a['alias'] ?? '').toString().toUpperCase();
      String keyB = tipoB == 'AMDES' ? (b['municipio'] ?? '').toString().toUpperCase() : (b['alias'] ?? '').toString().toUpperCase();
      return keyA.compareTo(keyB);
    });
    _miembros = miembrosList;
    _filteredMiembros = List.from(_miembros);
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 200;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          Column(
            children: [
              //header
              Container(
                height: headerHeight,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      appColores.assocGradientTop,     // Azul oscuro
                      appColores.assocGradientMiddle,  // Azul medio
                      appColores.assocGradientBottom,  // Gris claro abajo
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    children: [
                      // Botón Volver
                      Positioned(
                        top: 10,
                        left: 10,
                        child: TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          label: const Text("Volver", style: TextStyle(color: Colors.white, fontSize: 16)),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
                        ),
                      ),
                      
                      // Contenido Central Header
                      Positioned.fill(
                        top: 30,
                        child: Column(
                          children: [
                            const Text(
                              "MIEMBROS",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                widget.asociacionNombre.toUpperCase(),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.visible, // Permitir wrapping
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 60), // Espacio para el buscador flotante
              
              // Lista
              Expanded(
                child: _buildList(),
              ),
            ],
          ),

          // Buscador Flotante (Search Pill)
          Positioned(
            top: headerHeight - 25, // Mitad en header, mitad fuera
            left: 20,
            right: 20,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25), // Pill shape
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: "Buscar por nombre o municipio...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  isDense: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: appColores.assocGradientMiddle));
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    }
    if (_filteredMiembros.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 50, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text("No se encontraron miembros", style: TextStyle(color: Colors.grey.shade400)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20), // Padding top para separar del buscador
      itemCount: _filteredMiembros.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildMiembroCard(_filteredMiembros[index]);
      },
    );
  }

  Widget _buildMiembroCard(Map<String, dynamic> miembro) {
    final tipoAsociacion = _detectarTipoAsociacion(miembro);
    final isAmdes = tipoAsociacion == 'AMDES';
    
    // Datos display
    final String mainTitle = isAmdes
        ? ((miembro['municipio'] ?? '').toString().isNotEmpty
            ? miembro['municipio']
            : (miembro['alias'] ?? miembro['nombre'] ?? 'Sin nombre'))
        : (miembro['alias'] ?? miembro['nombre'] ?? 'Sin nombre');
        
    final String? subtitle = (!isAmdes && miembro['nombre'] != null && miembro['alias'] != null)
        ? 'Municipio: ${miembro['municipio'] ?? ''}'
        : (miembro['nombre'] != null ? '${miembro['nombre']}' : null);

    final String? partido = miembro['partido_politico']; // Suponiendo este campo o similar

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row Superior: Avatar + Nombres
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Circle
                (() {
                  final rawFoto = miembro['foto']?.toString() ?? '';
                  final networkPhoto = rawFoto.isNotEmpty 
                      ? (rawFoto.startsWith('http') ? rawFoto : "${ApiService.baseUrl.replaceAll('/api', '')}$rawFoto") 
                      : null;

                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [appColores.assocGradientMiddle, appColores.blueGradientBottom], 
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: appColores.assocGradientMiddle.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3)
                        )
                      ]
                    ),
                    child: ClipOval(
                      child: networkPhoto != null
                          ? CachedNetworkImage(
                              imageUrl: networkPhoto, 
                              fit: BoxFit.cover, 
                              errorWidget: (context, url, error) => _buildInitial(mainTitle),
                              placeholder: (context, url) => const Padding(
                                padding: EdgeInsets.all(16), 
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                              ),
                            )
                          : _buildInitial(mainTitle),
                    ),
                  );
                })(),
                
                const SizedBox(width: 15),
                
                // Textos Header
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mainTitle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF263238),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                      // Tag Partido (Optional if exists)
                      if (partido != null && partido.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: appColores.badgeBlueLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            partido,
                            style: const TextStyle(
                              color: appColores.badgeBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),

            // Detalles Contacto
            _buildDetailRow(Icons.phone_outlined, "Tel. Público:", miembro['telefono_publico'], Colors.green),
            _buildDetailRow(Icons.fax_outlined, "Fax:", miembro['telefono_fax'], Colors.teal),
            _buildDetailRow(Icons.email_outlined, "Correo:", miembro['correo_publico'], Colors.blueAccent),
            _buildDetailRow(Icons.location_on_outlined, "Dirección:", miembro['direccion'], Colors.redAccent),
            


            const SizedBox(height: 15),
            
             // Badges Footer (Tipo Miembro) - SIN ACTIVO/INACTIVO
            if (miembro['tipo_miembro'] != null && miembro['tipo_miembro'].toString().isNotEmpty)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                       color: appColores.badgePurpleLight,
                       borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      miembro['tipo_miembro'].toString(),
                      style: const TextStyle(
                        color: appColores.badgePurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 12
                      ),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildInitial(String name) {
    String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value, Color iconColor) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 13, fontFamily: 'Roboto'),
                children: [
                  TextSpan(text: "$label ", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                  TextSpan(text: value, style: const TextStyle(color: Color(0xFF37474F))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers Logic (No UI) ---
  
  String _detectarTipoAsociacion(Map<String, dynamic> miembro) {
    final asociacionData = miembro['Asociacion'] ?? miembro['asociacion'] ?? <String, dynamic>{};
    final tipoAsociacion = ((asociacionData['tipo'] ?? asociacionData['Tipo'] ?? '').toString().trim().toUpperCase());
    if (tipoAsociacion.isNotEmpty) return tipoAsociacion;
    final nombreAsociacion = (widget.asociacionNombre).toLowerCase();
    if (nombreAsociacion.contains('acobol')) return 'ACOBOL';
    
    // Usamos regex \bamb\b para asegurar que "amb" sea una palabra suelta
    // y no parte de "cochabamba", o comprobamos el nombre completo explícito.
    final esAmb = RegExp(r'\bamb\b').hasMatch(nombreAsociacion) || 
                  nombreAsociacion.contains('municipalidades de bolivia');
                  
    if (esAmb && !nombreAsociacion.contains('amdes')) return 'AMB';
    return 'AMDES'; 
  }


}
