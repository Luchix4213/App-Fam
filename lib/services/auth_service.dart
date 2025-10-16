import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Cambia esta URL por la URL de tu backend cuando esté desplegado
  //static const String baseUrl = 'http://10.183.203.131:4000/api'; // Para emulador Android fisicamente
  static const String baseUrl = 'http://10.0.2.2:4000/api'; // Para emulador desde el emulador
  // Para dispositivo físico usar: http://TU_IP_LOCAL:3000/api
  // Para web usar: http://localhost:3000/api

  // Token de autenticación
  static String? _token;
  static Map<String, dynamic>? _user;

  // Obtener el token actual
  static String? get token => _token;

  // Obtener el usuario actual
  static Map<String, dynamic>? get user => _user;

  // Verificar si el usuario está logueado
  static bool get isLoggedIn => _token != null && _user != null;

  // Inicializar el servicio (llamar al inicio de la app)
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _user = prefs.getString('user') != null 
        ? json.decode(prefs.getString('user')!) 
        : null;
  }

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'];
        _user = data['user'];

        // Guardar en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', json.encode(_user));

        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Error en el login'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Registro
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Error en el registro'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Logout
  static Future<void> logout() async {
    _token = null;
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  // Verificar si el token es válido
  static Future<bool> verifyToken() async {
    if (_token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Obtener headers con autenticación
  static Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }

  // Intentar login silencioso con usuario genérico
  static Future<bool> loginAsGuestIfNeeded() async {
    if (isLoggedIn) return true;
    final result = await login('usuario12345@gmail.com', 'usuario12345');
    return result['success'] == true;
  }
}
