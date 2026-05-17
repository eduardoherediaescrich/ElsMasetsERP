import 'api_service.dart';

/// Servicio de estados de lote
class EstadoLoteService {
  /// Obtiene todos los estados de lote
  static Future<List<dynamic>> obtenerTodos() async {
    return await ApiService.get('/estados-lote');
  }

  /// Obtiene un estado de lote por su id
  static Future<dynamic> obtenerPorId(int id) async {
    return await ApiService.get('/estados-lote/$id');
  }

  /// Crea un nuevo estado de lote
  static Future<dynamic> crear(Map<String, dynamic> datos) async {
    return await ApiService.post('/estados-lote', datos);
  }

  /// Actualiza un estado de lote existente
  static Future<dynamic> actualizar(int id, Map<String, dynamic> datos) async {
    return await ApiService.put('/estados-lote/$id', datos);
  }

  /// Elimina un estado de lote
  static Future<void> eliminar(int id) async {
    await ApiService.delete('/estados-lote/$id');
  }
}