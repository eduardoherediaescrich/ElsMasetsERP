import 'api_service.dart';

/// Servicio de stock
class StockService {
  /// Obtiene todo el stock
  static Future<List<dynamic>> obtenerTodo() async {
    return await ApiService.get('/stock');
  }

  /// Obtiene el stock de un producto específico
  static Future<dynamic> obtenerPorProducto(int productoId) async {
    return await ApiService.get('/stock/producto/$productoId');
  }

  /// Obtiene los productos con stock bajo mínimo
  static Future<List<dynamic>> obtenerBajoMinimo() async {
    return await ApiService.get('/stock/bajo-minimo');
  }

  /// Actualiza el stock de un producto
  static Future<dynamic> actualizar(int id, Map<String, dynamic> datos) async {
    return await ApiService.put('/stock/$id', datos);
  }
}