import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Cambia esta URL por la URL de tu backend cuando esté desplegado
  static const String baseUrl = 'https://api-fambolivia.onrender.com/api'; // Para emulador Android fisicamente
  //static const String baseUrl = 'http://172.29.220.131:4000/api'; 
  //static const String baseUrl = 'http://10.0.2.2:4000/api'; 
  
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static String? _token;
  static String? _refreshToken;
  static Map<String, dynamic>? _user;

  // Obtener el token actual
  static String? get token => _token;

  // Obtener el usuario actual
  static Map<String, dynamic>? get user => _user;

  // Verificar si el usuario está logueado
  static bool get isLoggedIn => _token != null && _user != null;

  // Verificar si es el usuario invitado/genérico
  static bool get isGuest => _user != null && _user!['email'] == 'usuario12345@gmail.com';

  // Inicializar el servicio (llamar al inicio de la app)
  static Future<void> initialize() async {
    _token = await _storage.read(key: 'token');
    _refreshToken = await _storage.read(key: 'refreshToken');
    final userStr = await _storage.read(key: 'user');
    _user = userStr != null ? json.decode(userStr) : null;
  }

  // Renovar Access Token usando el Refresh Token
  static Future<bool> refreshToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        // Guardar nuevo token en storage
        await _storage.write(key: 'token', value: _token!);
        return true;
      } else {
        // Refresh token vencido o inválido
        await logout();
        return false;
      }
    } catch (e) {
      print("Error Refreshing Token: $e");
      return false;
    }
  }

  // Login Normal
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
        _refreshToken = data['refreshToken'];
        _user = data['user'];

        // Guardar Access Token de forma segura
        await _storage.write(key: 'token', value: _token!);
        
        // Seguridad: Para admin/fam no guardamos el Refresh Token
        final String role = _user!['role'] ?? _user!['rol'] ?? 'usuario';
        if (role == 'usuario') {
          if (_refreshToken != null) await _storage.write(key: 'refreshToken', value: _refreshToken!);
        } else {
          await _storage.delete(key: 'refreshToken');
          _refreshToken = null; // Borrar también de memoria
        }

        await _storage.write(key: 'user', value: json.encode(_user));

        return {'success': true, 'data': data};
      } else if (response.statusCode == 429) {
          // Handle Rate Limiter Error
          return {'success': false, 'message': 'Demasiados intentos.\nIntenta nuevamente en 15 minutos.'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Error en el login'};
      }
    } catch (e) {
      // Avoid showing the raw URL Exception (SocketException/ClientException)
      if (e.toString().contains('SocketException') || e.toString().contains('ClientException') || e.toString().contains('Failed host lookup')) {
        return {'success': false, 'message': 'No se pudo conectar al servidor. Revisa tu conexión a internet.'};
      }
      return {'success': false, 'message': 'Ocurrió un error inesperado al iniciar sesión.'};
    }
  }

  // Login con Google
  static Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return {'success': false, 'message': 'Inicio de sesión cancelado'};

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) return {'success': false, 'message': 'No se pudo obtener el token de Google'};

      final response = await http.post(
        Uri.parse('$baseUrl/auth/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': idToken}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'];
        _refreshToken = data['refreshToken'];
        _user = data['user'];

        await _storage.write(key: 'token', value: _token!);
        
        final String role = _user!['role'] ?? _user!['rol'] ?? 'usuario';
        if (role == 'usuario') {
          if (_refreshToken != null) await _storage.write(key: 'refreshToken', value: _refreshToken!);
        } else {
          await _storage.delete(key: 'refreshToken');
          _refreshToken = null;
        }

        await _storage.write(key: 'user', value: json.encode(_user));

        return {'success': true, 'data': data};
      } else {
        await GoogleSignIn().signOut();
        return {'success': false, 'message': data['message'] ?? 'Error validando Google en el servidor'};
      }
    } catch (e) {
      await GoogleSignIn().signOut();
      return {'success': false, 'message': 'Excepción durante Google Sign-In: $e'};
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

      if (response.statusCode == 201) return {'success': true, 'data': data};
      return {'success': false, 'message': data['message'] ?? 'Error en el registro'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Logout
  static Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    _user = null;

    await _storage.delete(key: 'token');
    await _storage.delete(key: 'refreshToken');
    await _storage.delete(key: 'user');
    
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      print("Error al cerrar sesión de Google: $e");
    }
  }

  // Verificar si el token es válido
  static Future<bool> verifyToken() async {
    if (_token == null && _refreshToken == null) return false;
    
    if (_token == null && _refreshToken != null) {
      // Intentar refrescar directamente si solo tenemos refresh
       return await refreshToken();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 401) {
        final renewed = await refreshToken();
        return renewed;
      }
      return response.statusCode == 200 || response.statusCode == 403; // 403 significaria token valido pero sin permisos
    } catch (e) {
      // IMPORTANT: If we catch an error (e.g. SocketException, TimeoutException), 
      // it means the server is down or the device is offline.
      // Since we already checked that we have tokens saved locally, we MUST return true
      // to allow the user to enter the app in "Offline Mode".
      print("Offline mode triggered during verifyToken: $e");
      return true;
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

  // Helpers para obtener datos del usuario
  static Future<String?> getUserName() async {
    if (_user != null) return _user!['name'] ?? _user!['nombre'];
    final userStr = await _storage.read(key: 'user');
    if (userStr != null) {
      final u = json.decode(userStr);
      return u['name'] ?? u['nombre'];
    }
    return null;
  }

  static Future<String?> getUserRole() async {
    if (_user != null) return _user!['role'] ?? _user!['rol'];
    final userStr = await _storage.read(key: 'user');
    if (userStr != null) {
      final u = json.decode(userStr);
      return u['role'] ?? u['rol'];
    }
    return null;
  }
}
