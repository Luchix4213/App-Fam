import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

/// ApiService simplificado — solo lectura (GET) para app informativa pública.
/// Todo el CRUD admin se maneja desde el dashboard web React.
class ApiService {
  static const String baseUrl = 'https://api-fambolivia.onrender.com/api';

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
    };
  }

  static Future<Map<String, dynamic>> _get(String url, {String? updatedAfter}) async {
    try {
      final uriStr = updatedAfter != null 
          ? '$baseUrl$url${url.contains('?') ? '&' : '?'}updated_after=$updatedAfter'
          : '$baseUrl$url';
          
      final response = await http.get(
        Uri.parse(uriStr),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded is List
            ? {'success': true, 'data': decoded}
            : decoded;
      } else {
        return {'success': false, 'message': 'Error API: ${response.statusCode}', 'data': []};
      }
    } on TimeoutException {
      return {'success': false, 'message': 'Timeout del servidor.', 'data': []};
    } catch (e) {
      return {'success': false, 'message': 'Error de red.', 'data': []};
    }
  }

  // =============== ASOCIACIONES (solo lectura) ===============

  static Future<Map<String, dynamic>> getAllAsociaciones({String estado = 'activo', String? updatedAfter}) async {
    final res = await _get('/asociaciones', updatedAfter: updatedAfter);
    if (res['success'] == true || res is List || res['data'] is List) {
      final list = res['data'] is List ? res['data'] : (res is List ? res : []);
      final filtered = (list as List).where((a) => 
        a['estado']?.toString().toLowerCase() == estado.toLowerCase()
      ).toList();
      return {'success': true, 'data': filtered};
    }
    return res;
  }

  // =============== MIEMBROS (solo lectura) ===============

  static Future<Map<String, dynamic>> getMiembrosByAsociacion(int asociacionId) async {
    final res = await _get('/miembros/asociacion/$asociacionId');
    if (res['success'] == true || res['data'] is List) {
      return {'success': true, 'data': res['data'] ?? []};
    }
    return res;
  }

  static Future<Map<String, dynamic>> getAllMiembros({String estado = 'activo', String? updatedAfter}) async {
    final res = await _get('/miembros', updatedAfter: updatedAfter);
    if (res['success'] == true || res['data'] is List) {
      final list = res['data'] is List ? res['data'] : [];
      final filtered = (list as List).where((m) =>
        m['estado']?.toString().toLowerCase() == estado.toLowerCase()
      ).toList();
      return {'success': true, 'data': filtered};
    }
    return res;
  }

  // =============== PERSONAL (solo lectura) ===============

  static Future<Map<String, dynamic>> getAllPersonal({String estado = 'activo', String? updatedAfter}) async {
    final res = await _get('/personal', updatedAfter: updatedAfter);
    if (res['success'] == true || res['data'] is List) {
      final list = res['data'] is List ? res['data'] : [];
      final filtered = (list as List).where((p) =>
        p['estado']?.toString().toLowerCase() == estado.toLowerCase()
      ).toList();
      return {'success': true, 'data': filtered};
    }
    return res;
  }

  // =============== NOTICIAS (solo lectura) ===============

  static Future<Map<String, dynamic>> getAllNoticias({bool activas = false, String? updatedAfter}) async {
    final res = await _get('/noticias', updatedAfter: updatedAfter);
    if (res['success'] == true || res['data'] is List) {
      final list = res['data'] is List ? res['data'] : [];
      if (activas) {
        final filtered = (list as List).where((n) =>
          n['activa'] == true || n['activa'] == 'true'
        ).toList();
        return {'success': true, 'data': filtered};
      }
      return {'success': true, 'data': list};
    }
    return res;
  }
}
