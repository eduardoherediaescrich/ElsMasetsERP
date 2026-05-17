import 'api_service.dart';

/// Servicio de notificaciones
class NotificationService {
  /// Obtiene todas las notificaciones de un usuario
  static Future<List<dynamic>> obtenerPorUsuario(int usuarioId) async {
    return await ApiService.get('/notificaciones/usuario/$usuarioId');
  }

  /// Obtiene las notificaciones no leídas de un usuario
  static Future<List<dynamic>> obtenerNoLeidas(int usuarioId) async {
    return await ApiService.get('/notificaciones/usuario/$usuarioId/no-leidas');
  }

  /// Obtiene una notificación por su id
  static Future<dynamic> obtenerPorId(int id) async {
    return await ApiService.get('/notificaciones/$id');
  }

  /// Marca una notificación como leída
  static Future<dynamic> marcarComoLeida(int id, Map<String, dynamic> datos) async {
    return await ApiService.put('/notificaciones/$id', datos);
  }

  /// Elimina una notificación
  static Future<void> eliminar(int id) async {
    await ApiService.delete('/notificaciones/$id');
  }
}