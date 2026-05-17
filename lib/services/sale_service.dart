import 'api_service.dart';

/// Servicio de ventas
class SaleService {
  /// Obtiene todas las ventas
  static Future<List<dynamic>> obtenerTodas() async {
    return await ApiService.get('/ventas');
  }

  /// Obtiene una venta por su id
  static Future<dynamic> obtenerPorId(int id) async {
    return await ApiService.get('/ventas/$id');
  }

  /// Obtiene ventas de un cliente específico
  static Future<List<dynamic>> obtenerPorCliente(int clienteId) async {
    return await ApiService.get('/ventas/cliente/$clienteId');
  }

  /// Obtiene ventas por rango de fechas
  static Future<List<dynamic>> obtenerPorRango(
      String inicio, String fin) async {
    return await ApiService.get('/ventas/rango?inicio=$inicio&fin=$fin');
  }

  /// Obtiene ventas por estado
  static Future<List<dynamic>> obtenerPorEstado(int estadoId) async {
    return await ApiService.get('/ventas/estado/$estadoId');
  }

  /// Crea una nueva venta
  static Future<dynamic> crear(Map<String, dynamic> datos) async {
    return await ApiService.post('/ventas', datos);
  }

  /// Actualiza una venta existente
  static Future<dynamic> actualizar(int id, Map<String, dynamic> datos) async {
    return await ApiService.put('/ventas/$id', datos);
  }

  /// Elimina una venta
  static Future<void> eliminar(int id) async {
    await ApiService.delete('/ventas/$id');
  }
}