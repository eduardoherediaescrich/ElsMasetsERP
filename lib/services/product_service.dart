import 'api_service.dart';

/// Servicio de productos
class ProductService {
  /// Obtiene todos los productos
  static Future<List<dynamic>> obtenerTodos() async {
    return await ApiService.get('/productos');
  }

  /// Obtiene solo los productos activos
  static Future<List<dynamic>> obtenerActivos() async {
    return await ApiService.get('/productos/activos');
  }

  /// Obtiene un producto por su id
  static Future<dynamic> obtenerPorId(int id) async {
    return await ApiService.get('/productos/$id');
  }

  /// Obtiene productos por categoría
  static Future<List<dynamic>> obtenerPorCategoria(int categoriaId) async {
    return await ApiService.get('/productos/categoria/$categoriaId');
  }

  /// Crea un nuevo producto
  static Future<dynamic> crear(Map<String, dynamic> datos) async {
    return await ApiService.post('/productos', datos);
  }

  /// Actualiza un producto existente
  static Future<dynamic> actualizar(int id, Map<String, dynamic> datos) async {
    return await ApiService.put('/productos/$id', datos);
  }

  /// Elimina un producto
  static Future<void> eliminar(int id) async {
    await ApiService.delete('/productos/$id');
  }
}