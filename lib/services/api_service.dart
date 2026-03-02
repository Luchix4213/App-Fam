import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Para MediaType
import 'package:mime/mime.dart'; // Para lookupMimeType
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fam_intento1/services/auth_service.dart';

class ApiService {
  
  //static const String baseUrl = 'http://10.210.113.131:4000/api'; // Para emulador Android fisicamente
  static const String baseUrl = 'http://192.168.1.15:4000/api'; // Para emulador Android fisicamente
  //static const String baseUrl = 'http://10.0.2.2:4000/api'; // Para emulador desde el emulador

  // Obtener headers con autenticación
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthService.token}',
    };
  }

  // Obtener departamentos (público o admin)
  static Future<Map<String, dynamic>> getDepartamentos({bool isAdmin = false, String estado = 'activo'}) async {
    try {
      final String endpoint = isAdmin 
          ? '$baseUrl/departamentos?estado=$estado' 
          : '$baseUrl/departamentos/public'; // endpoint público siempre filtra solo activos
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Si el endpoint devuelve una lista directa (API admin), puede no tener clave "data" si no lo estandaricé asi.
        // Revisando controladores:
        // Public: res.json(departamentos) -> Array
        // Admin: res.json(items) -> Array
        // Mi front espera {'success': true, 'data': ...} por eso convierto aqui
        return {'success': true, 'data': data};
      } else {
        print("[ApiService] ERROR getDepartamentos: ${response.statusCode} - ${response.body}");
        return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
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
        print("[ApiService] ERROR getAsociaciones: ${response.statusCode} - ${response.body}");
        return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
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
        print("[ApiService] ERROR getMiembros: ${response.statusCode} - ${response.body}");
        return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Helper para Multipart Request
  static Future<Map<String, dynamic>> _uploadImage(String url, String method, Map<String, String> fields, String? imagePath) async {
    try {
      var request = http.MultipartRequest(method, Uri.parse(url));
      request.headers.addAll(_getHeaders());
      request.headers.remove('Content-Type');

      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      if (imagePath != null && imagePath.isNotEmpty) {
        // Detectar MIME Type
        final mimeTypeData = lookupMimeType(imagePath, headerBytes: [0xFF, 0xD8])?.split('/'); 
        // Header bytes hint for JPEG default if extension missing, but lookup handles extensions well.

        if (mimeTypeData != null && mimeTypeData.length == 2) {
          request.files.add(await http.MultipartFile.fromPath(
            'foto', 
            imagePath,
            contentType: MediaType(mimeTypeData[0], mimeTypeData[1])
          ));
        } else {
           // Fallback default
           request.files.add(await http.MultipartFile.fromPath('foto', imagePath));
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Crear miembro con foto
  static Future<Map<String, dynamic>> createMiembro(Map<String, String> data, String? imagePath) async {
    return await _uploadImage('$baseUrl/miembros', 'POST', data, imagePath);
  }

  // Actualizar miembro con foto
  static Future<Map<String, dynamic>> updateMiembro(int id, Map<String, String> data, String? imagePath) async {
    return await _uploadImage('$baseUrl/miembros/$id', 'PUT', data, imagePath);
  }

  static Future<Map<String, dynamic>> deleteMiembro(int id) async {
     try {
      final response = await http.delete(
        Uri.parse('$baseUrl/miembros/$id'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Obtener TODOS los miembros (para admin dashboard)
  static Future<Map<String, dynamic>> getAllMiembros({String estado = 'activo'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/miembros?estado=$estado'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        print("[ApiService] ERROR getAllMiembros: ${response.statusCode} - ${response.body}");
        return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // --- ASOCIACIONES ---
  static Future<Map<String, dynamic>> createAsociacion(Map<String, String> data, String? imagePath) async {
    return await _uploadImage('$baseUrl/asociaciones', 'POST', data, imagePath);
  }

  static Future<Map<String, dynamic>> updateAsociacion(int id, Map<String, String> data, String? imagePath) async {
    // Nota: en updateDepartamento casteamos, aqui parece que el map ya es String, String segun la firma,
    // pero valida si necesitamos dinamic revision.
    return await _uploadImage('$baseUrl/asociaciones/$id', 'PUT', data, imagePath);
  }

  static Future<Map<String, dynamic>> deleteAsociacion(int id) async {
     try {
      final response = await http.delete(
        Uri.parse('$baseUrl/asociaciones/$id'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // --- DEPARTAMENTOS ---
  static Future<Map<String, dynamic>> createDepartamento(Map<String, String> data, String? imagePath) async {
    return await _uploadImage('$baseUrl/departamentos', 'POST', data, imagePath);
  }

  static Future<Map<String, dynamic>> updateDepartamento(int id, Map<String, dynamic> data, String? imagePath) async {
    // Convertir data a Map<String, String> si es necesario, aunque _uploadImage espera Map<String, String>
    // En este caso, como los campos son texto, hacemos cast. 
    // Nota: en createDepartamento se usó Map<String, String>, aqui igual deberiamos asegurar el tipo.
    final Map<String, String> stringData = data.map((key, value) => MapEntry(key, value.toString()));
    return await _uploadImage('$baseUrl/departamentos/$id', 'PUT', stringData, imagePath);
  }

  static Future<Map<String, dynamic>> deleteDepartamento(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/departamentos/$id'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Obtener TODAS las asociaciones (para admin dashboard)
  static Future<Map<String, dynamic>> getAllAsociaciones({String estado = 'activo'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/asociaciones?estado=$estado'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // --- USUARIOS ---
  static Future<Map<String, dynamic>> getAllUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'message': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteUsuario(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$id'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createUsuario(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateUsuario(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}

