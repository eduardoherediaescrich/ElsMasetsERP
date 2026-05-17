import 'api_service.dart';

/// Servicio de lotes de producción
class LotService {
  // ─────────────────────────────
  // LOTES
  // ─────────────────────────────

  /// Obtiene todos los lotes
  static Future<List<dynamic>> obtenerTodos() async {
    return await ApiService.get('/lotes');
  }

  /// Obtiene un lote por su id
  static Future<dynamic> obtenerPorId(int id) async {
    return await ApiService.get('/lotes/$id');
  }

  /// Obtiene lotes por fecha de elaboración
  static Future<List<dynamic>> obtenerPorFecha(String fecha) async {
    return await ApiService.get('/lotes/fecha/$fecha');
  }

  /// Obtiene lotes de un producto específico
  static Future<List<dynamic>> obtenerPorProducto(int productoId) async {
    return await ApiService.get('/lotes/producto/$productoId');
  }

  /// Obtiene lotes por estado
  static Future<List<dynamic>> obtenerPorEstado(int estadoId) async {
    return await ApiService.get('/lotes/estado/$estadoId');
  }

  /// Crea un nuevo lote
  static Future<dynamic> crear(Map<String, dynamic> datos) async {
    return await ApiService.post('/lotes', datos);
  }

  /// Actualiza un lote existente
  static Future<dynamic> actualizar(int id, Map<String, dynamic> datos) async {
    return await ApiService.put('/lotes/$id', datos);
  }

  /// Elimina un lote
  static Future<void> eliminar(int id) async {
    await ApiService.delete('/lotes/$id');
  }

  // ─────────────────────────────
  // CATÁLOGOS (NUEVO)
  // ─────────────────────────────

  /// Obtiene todos los productos
  static Future<Map<int, String>> obtenerProductos() async {
    final List data = await ApiService.get('/api/productos');

    return {
      for (final item in data)
        item['id'] as int: item['nombre'] as String,
    };
  }

  /// Obtiene todas las unidades de medida
  static Future<Map<int, String>> obtenerUnidades() async {
    final List data = await ApiService.get('/api/unidades-medida');

    return {
      for (final item in data)
        item['id'] as int: item['abreviatura'] as String,
    };
  }

  /// Obtiene todos los estados de lote
  static Future<Map<int, String>> obtenerEstados() async {
    final List data = await ApiService.get('/api/estados-lote');

    return {
      for (final item in data)
        item['id'] as int: item['nombre'] as String,
    };
  }
}