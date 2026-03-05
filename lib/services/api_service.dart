import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; 
import 'package:mime/mime.dart'; 
import 'package:fam_intento1/services/auth_service.dart';

class ApiService {
  
  static const String baseUrl = 'http://192.168.1.15:4000/api'; 
  //static const String baseUrl = 'http://172.29.220.131:4000/api';
  //static const String baseUrl = 'http://10.0.2.2:4000/api';  

  // Obtener headers con autenticación
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthService.token}',
    };
  }

  // Wrappers HTTP con lógica de Refresh Token (Interceptors manuales)
  static Future<http.Response> _get(String url) async {
    var response = await http.get(Uri.parse(url), headers: _getHeaders()).timeout(const Duration(seconds: 7));
    if (response.statusCode == 401) {
      if (await AuthService.refreshToken()) {
        response = await http.get(Uri.parse(url), headers: _getHeaders()).timeout(const Duration(seconds: 7));
      }
    }
    return response;
  }

  static Future<http.Response> _post(String url, Map<String, dynamic> body) async {
    var response = await http.post(Uri.parse(url), headers: _getHeaders(), body: jsonEncode(body)).timeout(const Duration(seconds: 7));
    if (response.statusCode == 401) {
      if (await AuthService.refreshToken()) {
        response = await http.post(Uri.parse(url), headers: _getHeaders(), body: jsonEncode(body)).timeout(const Duration(seconds: 7));
      }
    }
    return response;
  }

  static Future<http.Response> _put(String url, Map<String, dynamic> body) async {
    var response = await http.put(Uri.parse(url), headers: _getHeaders(), body: jsonEncode(body)).timeout(const Duration(seconds: 7));
    if (response.statusCode == 401) {
      if (await AuthService.refreshToken()) {
        response = await http.put(Uri.parse(url), headers: _getHeaders(), body: jsonEncode(body)).timeout(const Duration(seconds: 7));
      }
    }
    return response;
  }

  static Future<http.Response> _delete(String url) async {
    var response = await http.delete(Uri.parse(url), headers: _getHeaders()).timeout(const Duration(seconds: 7));
    if (response.statusCode == 401) {
      if (await AuthService.refreshToken()) {
        response = await http.delete(Uri.parse(url), headers: _getHeaders()).timeout(const Duration(seconds: 7));
      }
    }
    return response;
  }

  // Helper para Multipart Request con Refresh Token
  static Future<Map<String, dynamic>> _uploadImage(String url, String method, Map<String, String> fields, String? imagePath) async {
    try {
      var request = await _createMultipartRequest(url, method, fields, imagePath);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        if (await AuthService.refreshToken()) {
          // Recrear request completo tras el refresh
          request = await _createMultipartRequest(url, method, fields, imagePath);
          streamedResponse = await request.send();
          response = await http.Response.fromStream(streamedResponse);
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<http.MultipartRequest> _createMultipartRequest(String url, String method, Map<String, String> fields, String? imagePath) async {
    var request = http.MultipartRequest(method, Uri.parse(url));
    request.headers.addAll(_getHeaders());
    request.headers.remove('Content-Type');

    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    if (imagePath != null && imagePath.isNotEmpty) {
      final mimeTypeData = lookupMimeType(imagePath, headerBytes: [0xFF, 0xD8])?.split('/'); 
      if (mimeTypeData != null && mimeTypeData.length == 2) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto', 
          imagePath,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1])
        ));
      } else {
         request.files.add(await http.MultipartFile.fromPath('foto', imagePath));
      }
    }
    return request;
  }


  // --- ASOCIACIONES ---

  static Future<Map<String, dynamic>> getAllAsociaciones({String estado = 'activo'}) async {
    try {
      final response = await _get('$baseUrl/asociaciones?estado=$estado');
      if (response.statusCode == 200) return {'success': true, 'data': json.decode(response.body)};
      return {'success': false, 'message': 'Error ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> createAsociacion(Map<String, String> data, String? imagePath) async {
    return await _uploadImage('$baseUrl/asociaciones', 'POST', data, imagePath);
  }

  static Future<Map<String, dynamic>> updateAsociacion(int id, Map<String, String> data, String? imagePath) async {
    return await _uploadImage('$baseUrl/asociaciones/$id', 'PUT', data, imagePath);
  }

  static Future<Map<String, dynamic>> deleteAsociacion(int id) async {
    try {
      final response = await _delete('$baseUrl/asociaciones/$id');
      if (response.statusCode == 200) return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // --- MIEMBROS ---
  static Future<Map<String, dynamic>> getMiembrosByAsociacion(int asociacionId) async {
    try {
      final response = await _get('$baseUrl/miembros/asociacion/$asociacionId');
      if (response.statusCode == 200) return {'success': true, 'data': json.decode(response.body)};
      return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> getAllMiembros({String estado = 'activo'}) async {
    try {
      final response = await _get('$baseUrl/miembros?estado=$estado');
      if (response.statusCode == 200) return {'success': true, 'data': json.decode(response.body)};
      return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> createMiembro(Map<String, String> data, String? imagePath) async {
    return await _uploadImage('$baseUrl/miembros', 'POST', data, imagePath);
  }

  static Future<Map<String, dynamic>> updateMiembro(int id, Map<String, String> data, String? imagePath) async {
    return await _uploadImage('$baseUrl/miembros/$id', 'PUT', data, imagePath);
  }

  static Future<Map<String, dynamic>> deleteMiembro(int id) async {
    try {
      final response = await _delete('$baseUrl/miembros/$id');
      if (response.statusCode == 200) return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // --- PERSONAL (DIRECTORIO) ---
  static Future<Map<String, dynamic>> getAllPersonal({String estado = 'activo'}) async {
    try {
      final response = await _get('$baseUrl/personal?estado=$estado');
      if (response.statusCode == 200) return {'success': true, 'data': json.decode(response.body)};
      return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> createPersonal(Map<String, String> data, String? imagePath) async {
    return await _uploadImage('$baseUrl/personal', 'POST', data, imagePath);
  }

  static Future<Map<String, dynamic>> updatePersonal(int id, Map<String, String> data, String? imagePath) async {
    return await _uploadImage('$baseUrl/personal/$id', 'PUT', data, imagePath);
  }

  static Future<Map<String, dynamic>> deletePersonal(int id) async {
    try {
      final response = await _delete('$baseUrl/personal/$id');
      if (response.statusCode == 200) return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // --- USUARIOS ---
  static Future<Map<String, dynamic>> getAllUsuarios() async {
    try {
      final response = await _get('$baseUrl/users');
      if (response.statusCode == 200) return {'success': true, 'data': json.decode(response.body)};
      return {'success': false, 'message': 'Error ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteUsuario(int id) async {
    try {
      final response = await _delete('$baseUrl/users/$id');
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'message': 'Error ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createUsuario(Map<String, dynamic> data) async {
    try {
      final response = await _post('$baseUrl/users', data);
      if (response.statusCode == 201) return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateUsuario(int id, Map<String, dynamic> data) async {
    try {
      final response = await _put('$baseUrl/users/$id', data);
      if (response.statusCode == 200) return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'message': 'Error ${response.statusCode}: ${response.body}'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
