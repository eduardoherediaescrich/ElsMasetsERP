import 'api_service.dart';

/// Servicio de eventos del calendario
class EventService {
  /// Obtiene todos los eventos
  static Future<List<dynamic>> obtenerTodos() async {
    return await ApiService.get('/eventos');
  }

  /// Obtiene un evento por su id
  static Future<dynamic> obtenerPorId(int id) async {
    return await ApiService.get('/eventos/$id');
  }

  /// Obtiene eventos de una fecha específica
  static Future<List<dynamic>> obtenerPorFecha(String fecha) async {
    return await ApiService.get('/eventos/fecha/$fecha');
  }

  /// Obtiene eventos por rango de fechas
  static Future<List<dynamic>> obtenerPorRango(
      String inicio, String fin) async {
    return await ApiService.get('/eventos/rango?inicio=$inicio&fin=$fin');
  }

  /// Crea un nuevo evento
  static Future<dynamic> crear(Map<String, dynamic> datos) async {
    return await ApiService.post('/eventos', datos);
  }

  /// Actualiza un evento existente
  static Future<dynamic> actualizar(int id, Map<String, dynamic> datos) async {
    return await ApiService.put('/eventos/$id', datos);
  }

  /// Elimina un evento
  static Future<void> eliminar(int id) async {
    await ApiService.delete('/eventos/$id');
  }
}