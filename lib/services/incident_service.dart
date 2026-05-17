import 'api_service.dart';

/// Servicio de incidencias
class IncidentService {
  /// Obtiene todas las incidencias
  static Future<List<dynamic>> obtenerTodas() async {
    return await ApiService.get('/incidencias');
  }

  /// Obtiene una incidencia por su id
  static Future<dynamic> obtenerPorId(int id) async {
    return await ApiService.get('/incidencias/$id');
  }

  /// Obtiene incidencias por estado
  static Future<List<dynamic>> obtenerPorEstado(int estadoId) async {
    return await ApiService.get('/incidencias/estado/$estadoId');
  }

  /// Obtiene incidencias por prioridad
  static Future<List<dynamic>> obtenerPorPrioridad(int prioridadId) async {
    return await ApiService.get('/incidencias/prioridad/$prioridadId');
  }

  /// Obtiene incidencias asignadas a un usuario
  static Future<List<dynamic>> obtenerAsignadasA(int usuarioId) async {
    return await ApiService.get('/incidencias/asignadas/$usuarioId');
  }

  /// Crea una nueva incidencia
  static Future<dynamic> crear(Map<String, dynamic> datos) async {
    return await ApiService.post('/incidencias', datos);
  }

  /// Actualiza una incidencia existente
  static Future<dynamic> actualizar(int id, Map<String, dynamic> datos) async {
    return await ApiService.put('/incidencias/$id', datos);
  }

  /// Elimina una incidencia
  static Future<void> eliminar(int id) async {
    await ApiService.delete('/incidencias/$id');
  }
}