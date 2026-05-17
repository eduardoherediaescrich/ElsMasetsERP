import 'api_service.dart';

/// Servicio de contactos
class ContactService {
  /// Obtiene todos los contactos
  static Future<List<dynamic>> obtenerTodos() async {
    return await ApiService.get('/contactos');
  }

  /// Obtiene solo los contactos activos
  static Future<List<dynamic>> obtenerActivos() async {
    return await ApiService.get('/contactos/activos');
  }

  /// Obtiene un contacto por su id
  static Future<dynamic> obtenerPorId(int id) async {
    return await ApiService.get('/contactos/$id');
  }

  /// Busca contactos por nombre
  static Future<List<dynamic>> buscarPorNombre(String nombre) async {
    return await ApiService.get('/contactos/buscar?nombre=$nombre');
  }

  /// Crea un nuevo contacto
  static Future<dynamic> crear(Map<String, dynamic> datos) async {
    return await ApiService.post('/contactos', datos);
  }

  /// Actualiza un contacto existente
  static Future<dynamic> actualizar(int id, Map<String, dynamic> datos) async {
    return await ApiService.put('/contactos/$id', datos);
  }

  /// Elimina un contacto
  static Future<void> eliminar(int id) async {
    await ApiService.delete('/contactos/$id');
  }
}