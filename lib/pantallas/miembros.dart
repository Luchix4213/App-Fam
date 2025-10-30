import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/core/text.dart';
import 'package:fam_intento1/services/api_service.dart';
import 'package:fam_intento1/services/auth_service.dart';

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
  bool _isLoading = true;
  String? _errorMessage;

  static const List<String> _amdesDepartamentos = [
    'beni',
    'chuquisaca',
    'cochabamba',
    'lapaz',
    'oruro',
    'pando',
    'potosi',
    'santacruz',
    'tarija',
  ];

  @override
  void initState() {
    super.initState();
    _loadMiembros();
  }

  Future<void> _loadMiembros() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.getMiembrosByAsociacion(widget.asociacionId);
    
    setState(() {
      _isLoading = false;
      if (result['success']) {
        final List<dynamic> data = List<dynamic>.from(result['data']);
        // Ordenar: AMDES por municipio; ACOBOL/AMB por alias
        data.sort((a, b) {
          final tipoA = _detectarTipoAsociacion(a);
          final tipoB = _detectarTipoAsociacion(b);

          String keyA;
          String keyB;

          if (tipoA == 'AMDES') {
            keyA = (a['municipio'] ?? '').toString().toUpperCase();
          } else {
            keyA = (a['alias'] ?? '').toString().toUpperCase();
          }

          if (tipoB == 'AMDES') {
            keyB = (b['municipio'] ?? '').toString().toUpperCase();
          } else {
            keyB = (b['alias'] ?? '').toString().toUpperCase();
          }

          return keyA.compareTo(keyB);
        });
        _miembros = data;
      } else {
        _errorMessage = result['message'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColores.backgraund,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 72, 228, 33),
        title: Text(
          widget.asociacionNombre,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 72, 228, 33),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMiembros,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 72, 228, 33),
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_miembros.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.person,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hay miembros disponibles',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 72, 228, 33),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.people,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                'Miembros',
                style: TextStyles.titulo.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Información de contacto de los miembros',
                style: TextStyles.textosimple.copyWith(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Lista de miembros
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _miembros.length,
            itemBuilder: (context, index) {
              final miembro = _miembros[index];
              return _buildMiembroCard(miembro);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMiembroCard(Map<String, dynamic> miembro) {
    final userRole = AuthService.user?['role'] ?? 'usuario';
    final isAdminOrFam = userRole == 'admin' || userRole == 'fam';
    final tipoAsociacion = _detectarTipoAsociacion(miembro);
    final isAmdes = tipoAsociacion == 'AMDES';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FutureBuilder<String?>(
                  future: _resolverRutaFotoMiembro(miembro),
                  builder: (context, snapshot) {
                    final ruta = snapshot.data;
                    if (ruta == null || snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 72, 228, 33).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color.fromARGB(255, 72, 228, 33),
                          size: 24,
                        ),
                      );
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        ruta,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 72, 228, 33).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color.fromARGB(255, 72, 228, 33),
                              size: 24,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // Para AMDES mostrar municipio, caso contrario alias (o nombre)
                        isAmdes
                            ? ((miembro['municipio'] ?? '').toString().isNotEmpty
                                ? miembro['municipio']
                                : (miembro['alias'] ?? miembro['nombre'] ?? 'Sin nombre'))
                            : (miembro['alias'] ?? miembro['nombre'] ?? 'Sin nombre'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (!isAmdes && miembro['nombre'] != null && miembro['alias'] != null)
                        Text(
                          'Municipio: ${miembro['municipio']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      if (isAmdes && (miembro['alias'] ?? '').toString().isNotEmpty)
                        Text(
                          miembro['alias'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      if (miembro['nombre'] != null)
                        Text(
                          'Nombre: ${miembro['nombre']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Información de contacto básica (visible para todos)
            _buildInfoRow(Icons.phone, 'Tel. Público', miembro['telefono_publico']),
            _buildInfoRow(Icons.fax, 'Fax', miembro['telefono_fax']),
            _buildInfoRow(Icons.email, 'Correo Público', miembro['correo_publico']),
            _buildInfoRow(Icons.location_on, 'Dirección', miembro['direccion']),

            // Información adicional para usuarios FAM y admin
            if (isAdminOrFam) ...[
              const Divider(height: 20),
              Text(
                'Información adicional',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.phone_android, 'Tel. Personal', miembro['telefono_personal']),
              _buildInfoRow(Icons.email_outlined, 'Correo Personal', miembro['correo_personal']),
              if (miembro['tipo_miembro'] != null)
                _buildInfoRow(Icons.badge, 'Tipo', miembro['tipo_miembro']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on _MiembrosScreenState {
  String _detectarTipoAsociacion(Map<String, dynamic> miembro) {
    final asociacionData = miembro['Asociacion'] ?? miembro['asociacion'] ?? <String, dynamic>{};
    final tipoAsociacion = ((asociacionData['tipo'] ?? asociacionData['Tipo'] ?? '').toString().trim().toUpperCase());
    if (tipoAsociacion.isNotEmpty) return tipoAsociacion;
    final nombreAsociacion = (widget.asociacionNombre).toLowerCase();
    if (nombreAsociacion.contains('amdes')) return 'AMDES';
    if (nombreAsociacion.contains('acobol')) return 'ACOBOL';
    if (nombreAsociacion.contains('amb')) return 'AMB';
    return '';
  }

  Future<String?> _resolverRutaFotoMiembro(Map<String, dynamic> miembro) async {
    // Obtener tipo de asociación desde los datos del miembro
    // Sequelize puede devolver las relaciones con diferentes casos
    final asociacionData = miembro['Asociacion'] ?? miembro['asociacion'] ?? <String, dynamic>{};
    final tipoAsociacion = ((asociacionData['tipo'] ?? asociacionData['Tipo'] ?? '').toString().trim().toUpperCase());
    final alias = (miembro['alias'] ?? '').toString().trim();
    final municipio = (miembro['municipio'] ?? '').toString().trim();
    
    // Mapeo de nombres de departamento a nombres de carpetas
    final Map<String, String> deptoNamesMap = {
      'LA PAZ': 'lapaz',
      'COCHABAMBA': 'cochabamba',
      'SANTA CRUZ': 'santacruz',
      'POTOSÍ': 'potosi',
      'POTOSI': 'potosi',
      'ORURO': 'oruro',
      'CHUQUISACA': 'chuquisaca',
      'BENI': 'beni',
      'PANDO': 'pando',
      'TARIJA': 'tarija',
    };

    // Si no hay tipo, intentar detectar por nombre de asociación como fallback
    String? tipoDetectado = tipoAsociacion.isNotEmpty 
        ? tipoAsociacion 
        : null;
    
    if (tipoDetectado == null) {
      final nombreAsociacion = (widget.asociacionNombre).toLowerCase();
      if (nombreAsociacion.contains('amdes')) {
        tipoDetectado = 'AMDES';
      } else if (nombreAsociacion.contains('acobol')) {
        tipoDetectado = 'ACOBOL';
      } else if (nombreAsociacion.contains('amb')) {
        tipoDetectado = 'AMB';
      }
    }

    // AMDES: buscar por municipio en la carpeta del departamento
    if (tipoDetectado == 'AMDES') {
      if (municipio.isEmpty) return null;
      
      // Obtener nombre del departamento de la asociación
      final departamentoData = asociacionData['Departamento'] ?? 
                               asociacionData['departamento'] ?? 
                               {};
      final nombreDepto = ((departamentoData['nombre'] ?? departamentoData['Nombre'] ?? '').toString().trim().toUpperCase());
      
      // Normalizar nombre del departamento a nombre de carpeta
      String carpetaDepto = deptoNamesMap[nombreDepto] ?? 
          nombreDepto.toLowerCase().replaceAll(' ', '');
      
      // Si no se encuentra el mapeo, intentar con todos los departamentos
      final deptosABuscar = carpetaDepto.isNotEmpty && 
          _MiembrosScreenState._amdesDepartamentos.contains(carpetaDepto)
          ? [carpetaDepto]
          : _MiembrosScreenState._amdesDepartamentos;
      
      final nombres = <String>{
        municipio,
        municipio.toUpperCase(),
        municipio.toLowerCase(),
      }..removeWhere((e) => e.isEmpty);
      
      final extensiones = ['.JPG', '.jpg', '.png'];
      
      for (final depto in deptosABuscar) {
        for (final nombreArchivo in nombres) {
          for (final ext in extensiones) {
            final ruta = 'assets/images/miembros/amdes/$depto/$nombreArchivo$ext';
            if (await _assetExiste(ruta)) return ruta;
          }
        }
      }
      return null;
    }

    // ACOBOL: buscar por alias
    if (tipoDetectado == 'ACOBOL') {
      if (alias.isEmpty) return null;
      final variantes = <String>[
        alias,
        alias.toUpperCase(),
        alias.toLowerCase(),
      ];
      final extensiones = ['.JPG', '.jpg', '.png'];
      for (final base in variantes) {
        for (final ext in extensiones) {
          final ruta = 'assets/images/miembros/acobol/$base$ext';
          if (await _assetExiste(ruta)) return ruta;
        }
      }
      return null;
    }

    // AMB: buscar por alias
    if (tipoDetectado == 'AMB') {
      if (alias.isEmpty) return null;
      final variantes = <String>[
        alias,
        alias.toUpperCase(),
        alias.toLowerCase(),
      ];
      final extensiones = ['.JPG', '.jpg', '.png'];
      for (final base in variantes) {
        for (final ext in extensiones) {
          final ruta = 'assets/images/miembros/amb/$base$ext';
          if (await _assetExiste(ruta)) return ruta;
        }
      }
      return null;
    }

    return null;
  }

  Future<bool> _assetExiste(String ruta) async {
    try {
      await rootBundle.load(ruta);
      return true;
    } catch (_) {
      return false;
    }
  }
}
