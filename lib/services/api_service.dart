import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fam_intento1/services/auth_service.dart';

class ApiService {
  
  //static const String baseUrl = 'http://10.35.91.131:4000/api'; // Para emulador Android fisicamente
  //static const String baseUrl = 'http://192.168.40.245:4000/api'; // Para emulador Android fisicamente
  static const String baseUrl = 'http://10.0.2.2:4000/api'; // Para emulador desde el emulador

  // Obtener headers con autenticación
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthService.token}',
    };
  }

  // Obtener departamentos
  static Future<Map<String, dynamic>> getDepartamentos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/departamentos/public'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Error al obtener departamentos'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener asociaciones por departamento
  static Future<Map<String, dynamic>> getAsociacionesByDepartamento(int departamentoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/asociaciones/departamento/$departamentoId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Error al obtener asociaciones'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener miembros por asociación
  static Future<Map<String, dynamic>> getMiembrosByAsociacion(int asociacionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/miembros/asociacion/$asociacionId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Error al obtener miembros'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
