import 'api_service.dart';

/// Servicio de unidades de medida
class UnidadMedidaService {
  /// Obtiene todas las unidades de medida
  static Future<List<dynamic>> obtenerTodas() async {
    return await ApiService.get('/unidades-medida');
  }

  /// Obtiene una unidad de medida por su id
  static Future<dynamic> obtenerPorId(int id) async {
    return await ApiService.get('/unidades-medida/$id');
  }

  /// Crea una nueva unidad de medida
  static Future<dynamic> crear(Map<String, dynamic> datos) async {
    return await ApiService.post('/unidades-medida', datos);
  }

  /// Actualiza una unidad de medida existente
  static Future<dynamic> actualizar(int id, Map<String, dynamic> datos) async {
    return await ApiService.put('/unidades-medida/$id', datos);
  }

  /// Elimina una unidad de medida
  static Future<void> eliminar(int id) async {
    await ApiService.delete('/unidades-medida/$id');
  }
}