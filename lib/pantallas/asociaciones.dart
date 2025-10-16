import 'package:flutter/material.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/core/text.dart';
import 'package:fam_intento1/services/api_service.dart';
import 'package:fam_intento1/pantallas/miembros.dart';

class AsociacionesScreen extends StatefulWidget {
  final int departamentoId;
  final String departamentoNombre;

  const AsociacionesScreen({
    super.key,
    required this.departamentoId,
    required this.departamentoNombre,
  });

  @override
  State<AsociacionesScreen> createState() => _AsociacionesScreenState();
}

class _AsociacionesScreenState extends State<AsociacionesScreen> {
  List<dynamic> _asociaciones = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAsociaciones();
  }

  Future<void> _loadAsociaciones() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.getAsociacionesByDepartamento(widget.departamentoId);
    
    setState(() {
      _isLoading = false;
      if (result['success']) {
        _asociaciones = result['data'];
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
          widget.departamentoNombre,
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
              onPressed: _loadAsociaciones,
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

    if (_asociaciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.business,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hay asociaciones disponibles',
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
                Icons.business,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                'Asociaciones Municipales',
                style: TextStyles.titulo.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Selecciona una asociación para ver los miembros',
                style: TextStyles.textosimple.copyWith(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Lista de asociaciones
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _asociaciones.length,
            itemBuilder: (context, index) {
              final asociacion = _asociaciones[index];
              return _buildAsociacionCard(asociacion);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAsociacionCard(Map<String, dynamic> asociacion) {
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 72, 228, 33).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.business,
            color: Color.fromARGB(255, 72, 228, 33),
            size: 24,
          ),
        ),
        title: Text(
          asociacion['alias'] ?? asociacion['nombre'] ?? 'Sin nombre',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (asociacion['nombre'] != null && asociacion['alias'] != null)
              Text(
                asociacion['nombre'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            if (asociacion['municipio'] != null)
              Text(
                'Municipio: ${asociacion['municipio']}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              'Ver miembros',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color.fromARGB(255, 72, 228, 33),
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MiembrosScreen(
                asociacionId: asociacion['id'],
                asociacionNombre: asociacion['alias'] ?? asociacion['nombre'],
              ),
            ),
          );
        },
      ),
    );
  }
}
