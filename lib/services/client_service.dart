import 'api_service.dart';

/// Servicio de clientes
class ClientService {
  /// Obtiene todos los clientes
  static Future<List<dynamic>> obtenerTodos() async {
    return await ApiService.get('/clientes');
  }

  /// Obtiene solo los clientes activos
  static Future<List<dynamic>> obtenerActivos() async {
    return await ApiService.get('/clientes/activos');
  }

  /// Obtiene un cliente por su id
  static Future<dynamic> obtenerPorId(int id) async {
    return await ApiService.get('/clientes/$id');
  }

  /// Busca clientes por nombre
  static Future<List<dynamic>> buscarPorNombre(String nombre) async {
    return await ApiService.get('/clientes/buscar?nombre=$nombre');
  }

  /// Obtiene clientes por tipo
  static Future<List<dynamic>> obtenerPorTipo(int tipoClienteId) async {
    return await ApiService.get('/clientes/tipo/$tipoClienteId');
  }

  /// Crea un nuevo cliente
  static Future<dynamic> crear(Map<String, dynamic> datos) async {
    return await ApiService.post('/clientes', datos);
  }

  /// Actualiza un cliente existente
  static Future<dynamic> actualizar(int id, Map<String, dynamic> datos) async {
    return await ApiService.put('/clientes/$id', datos);
  }

  /// Elimina un cliente
  static Future<void> eliminar(int id) async {
    await ApiService.delete('/clientes/$id');
  }

  /// Obtiene las compras agrupadas por producto para un cliente específico
  /// Devuelve una lista de CompraClienteDTO ordenada de mayor a menor cantidad
  static Future<List<dynamic>> obtenerComprasPorCliente(int clienteId) async {
    return await ApiService.get('/clientes/$clienteId/compras');
  }
}
