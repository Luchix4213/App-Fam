import 'package:flutter/material.dart';
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
        _miembros = result['data'];
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
            color: Colors.black,
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
                Container(
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        miembro['alias'] ?? miembro['nombre'] ?? 'Sin nombre',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (miembro['nombre'] != null && miembro['alias'] != null)
                        Text(
                          miembro['nombre'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      if (miembro['municipio'] != null)
                        Text(
                          'Municipio: ${miembro['municipio']}',
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
