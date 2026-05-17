import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio base para todas las peticiones HTTP al backend
/// Gestiona la URL base y el token JWT automáticamente
class ApiService {
  /// URL base del backend — cambiar si el servidor cambia de dirección
  static const String baseUrl = 'http://localhost:8080/api';

  /// Token JWT del usuario autenticado
  /// Se establece al hacer login y se usa en todas las peticiones
  static String? _token;

  /// Guarda el token tras el login
  static void setToken(String token) {
    _token = token;
  }

  /// Limpia el token al cerrar sesión
  static void clearToken() {
    _token = null;
  }

  /// Devuelve true si hay un token guardado
  static bool get isAuthenticated => _token != null;

  /// Headers comunes para todas las peticiones autenticadas
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  /// Headers para peticiones públicas (login)
  static Map<String, String> get _publicHeaders => {
        'Content-Type': 'application/json',
      };

  // ─────────────────────────────────────────────
  // MÉTODOS HTTP BASE
  // ─────────────────────────────────────────────

  /// GET autenticado
  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _procesarRespuesta(response);
  }

  /// POST autenticado
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _procesarRespuesta(response);
  }

  /// POST público (para login)
  static Future<dynamic> postPublic(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _publicHeaders,
      body: jsonEncode(body),
    );
    return _procesarRespuesta(response);
  }

  /// PUT autenticado
  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _procesarRespuesta(response);
  }

  /// DELETE autenticado
  static Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _procesarRespuesta(response);
  }

  // ─────────────────────────────────────────────
  // PROCESAMIENTO DE RESPUESTAS
  // ─────────────────────────────────────────────

  /// Procesa la respuesta HTTP y lanza excepción si hay error
  static dynamic _procesarRespuesta(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado — inicia sesión de nuevo');
    } else if (response.statusCode == 403) {
      throw Exception('Acceso denegado');
    } else if (response.statusCode == 404) {
      throw Exception('Recurso no encontrado');
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }
}