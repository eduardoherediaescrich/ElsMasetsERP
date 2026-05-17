import 'api_service.dart';

/// Servicio de autenticación
/// Gestiona el login y el cierre de sesión
class AuthService {
  /// Datos del usuario autenticado en memoria
  static int? usuarioId;
  static String? usuarioNombre;
  static String? usuarioEmail;
  static String? usuarioRol;

  /// Realiza el login con email y contraseña
  /// Devuelve true si el login fue exitoso
  static Future<bool> login(String email, String contrasenya) async {
    try {
      final response = await ApiService.postPublic('/auth/login', {
        'email': email,
        'contrasenya': contrasenya,
      });

      // Guarda el token y los datos del usuario
      ApiService.setToken(response['token']);
      usuarioId = response['usuarioId'];
      usuarioNombre = response['nombre'];
      usuarioEmail = response['email'];
      usuarioRol = response['rolNombre'];

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cierra la sesión limpiando el token y los datos del usuario
  static void logout() {
    ApiService.clearToken();
    usuarioId = null;
    usuarioNombre = null;
    usuarioEmail = null;
    usuarioRol = null;
  }
}