import 'package:flutter/material.dart';
import 'configuration.dart';
import 'contact.dart';
import 'dashboard.dart';
import 'report.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';

/// Pantalla de Notificaciones
/// CARACTERÍSTICAS PRINCIPALES:
/// 1. Carga de notificaciones reales desde el backend via NotificationService
/// 2. Filtros por orden, departamento y prioridad — aplicados localmente
/// 3. Marcar como leída / eliminar al pulsar — llaman al backend
/// 4. Botón "Leer todas" — marca todas como leídas en el backend
/// 5. Contador de no leídas en el título
/// 6. Indicador de carga mientras se obtienen los datos
///
/// WIDGETS DE SALIDA UTILIZADOS:
/// - ListView.builder (lista de notificaciones)
/// - DropdownButton (filtros)
/// - AlertDialog (opciones al pulsar)
/// - CircularProgressIndicator (indicador de carga)
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  /// Lista principal de notificaciones cargada desde el backend
  /// Cada elemento es un Map con los campos del NotificacionDTO
  List<Map<String, dynamic>> notificaciones = [];

  /// Indica si los datos están siendo cargados desde el backend
  bool _cargando = true;

  /// Mensaje de error si la carga falla
  String? _error;

  /// Filtros activos — aplicados localmente sobre la lista cargada
  String _filtroOrden = 'Más reciente';
  String _filtroDepartamento = 'Todos';
  String _filtroPrioridad = 'Todas';

  @override
  void initState() {
    super.initState();
    /// Carga las notificaciones del usuario logueado al iniciar la pantalla
    _cargarNotificaciones();
  }

  // CARGA DE DATOS DESDE EL BACKEND
  /// Llama al NotificationService para obtener las notificaciones del usuario logueado
  /// Usa el usuarioId guardado en AuthService tras el login
  Future<void> _cargarNotificaciones() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final usuarioId = AuthService.usuarioId;
      if (usuarioId == null) throw Exception('Usuario no autenticado');

      final datos = await NotificationService.obtenerPorUsuario(usuarioId);
      setState(() {
        /// Convierte la lista dinámica a List<Map<String, dynamic>>
        notificaciones = List<Map<String, dynamic>>.from(datos);
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar las notificaciones. Comprueba la conexión.';
        _cargando = false;
      });
    }
  }

  /// Aplica filtros y ordenación sobre la lista cargada del backend
  List<Map<String, dynamic>> get _notificacionesFiltradas {
    List<Map<String, dynamic>> resultado = List.from(notificaciones);

    /// Filtra por departamento (tipoNombre en el DTO)
    if (_filtroDepartamento != 'Todos') {
      resultado = resultado
          .where((n) => (n['tipoNombre'] ?? '') == _filtroDepartamento)
          .toList();
    }

    /// Filtra por prioridad (prioridadNombre en el DTO)
    if (_filtroPrioridad != 'Todas') {
      resultado = resultado
          .where((n) => (n['prioridadNombre'] ?? '') == _filtroPrioridad)
          .toList();
    }

    /// Ordena por fecha de creación
    resultado.sort((a, b) {
      final fechaA = DateTime.tryParse(a['fechaCreacion'] ?? '') ?? DateTime(0);
      final fechaB = DateTime.tryParse(b['fechaCreacion'] ?? '') ?? DateTime(0);
      return _filtroOrden == 'Más reciente'
          ? fechaB.compareTo(fechaA)
          : fechaA.compareTo(fechaB);
    });

    return resultado;
  }

  /// Número de notificaciones no leídas
  int get _noLeidas =>
      notificaciones.where((n) => n['leida'] == false).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E9C9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6E9C9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3B2A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          /// Botón "Leer todas" — solo visible si hay notificaciones no leídas
          if (_noLeidas > 0)
            TextButton(
              onPressed: _marcarTodasComoLeidas,
              child: const Text(
                'Leer todas',
                style: TextStyle(color: Color(0xFF4A3B2A), fontSize: 13),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: SafeArea(
        child: Column(
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Image.asset('assets/masets_blanco.png', height: 140),
              ),
            ),
            const SizedBox(height: 20),

            // Título con contador de no leídas
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'NOTIFICACIONES',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3B2A),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  if (_noLeidas > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_noLeidas',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Filtros en fila horizontal deslizable
            SizedBox(
              height: 36,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                children: [
                  _buildDropdownFiltro(
                    valor: _filtroOrden,
                    opciones: ['Más reciente', 'Más antigua'],
                    onChanged: (v) => setState(() => _filtroOrden = v!),
                  ),
                  const SizedBox(width: 8),
                  _buildDropdownFiltro(
                    valor: _filtroDepartamento,
                    opciones: [
                      'Todos',
                      'VENTAS',
                      'PRODUCCION',
                      'LOGISTICA',
                      'ADMINISTRACION',
                      'ALMACEN',
                      'OTROS',
                    ],
                    onChanged: (v) =>
                        setState(() => _filtroDepartamento = v!),
                  ),
                  const SizedBox(width: 8),
                  _buildDropdownFiltro(
                    valor: _filtroPrioridad,
                    opciones: ['Todas', 'CRITICA', 'ALTA', 'MEDIA', 'BAJA'],
                    onChanged: (v) => setState(() => _filtroPrioridad = v!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Contenido principal: cargando, error o lista
            Expanded(
              child: _cargando
                  /// Indicador de carga mientras se obtienen los datos del backend
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4A3B2A),
                      ),
                    )
                  : _error != null
                      /// Mensaje de error con botón para reintentar
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _error!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF4A3B2A),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _cargarNotificaciones,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A3B2A),
                                ),
                                child: const Text(
                                  'Reintentar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        )
                      /// Lista de notificaciones filtradas
                      : _notificacionesFiltradas.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay notificaciones con estos filtros',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF4A3B2A),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24),
                              itemCount: _notificacionesFiltradas.length,
                              itemBuilder: (context, index) {
                                return _buildNotificacionCard(
                                  _notificacionesFiltradas[index],
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGETS
  /// Dropdown compacto para los filtros
  Widget _buildDropdownFiltro({
    required String valor,
    required List<String> opciones,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A3B2A), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: valor,
          isDense: true,
          style: const TextStyle(
            color: Color(0xFF4A3B2A),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Color(0xFF4A3B2A),
            size: 18,
          ),
          items: opciones.map((op) {
            return DropdownMenuItem<String>(value: op, child: Text(op));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// Tarjeta de notificación con punto de color según prioridad
  /// Los datos vienen del NotificacionDTO del backend:
  /// - tipoNombre: departamento (VENTAS, PRODUCCION, etc.)
  /// - mensaje: texto de la notificación
  /// - prioridadNombre: prioridad (CRITICA, ALTA, MEDIA, BAJA)
  /// - fechaCreacion: fecha en formato ISO string
  /// - leida: boolean indicando si ha sido leída
  Widget _buildNotificacionCard(Map<String, dynamic> notificacion) {
    final bool leida = notificacion['leida'] as bool? ?? false;
    final Color prioridadColor =
        _getPrioridadColor(notificacion['prioridadNombre'] ?? '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: leida ? Colors.white : const Color(0xFFFFF8EE),
        borderRadius: BorderRadius.circular(10),
        elevation: leida ? 1 : 2,
        child: InkWell(
          onTap: () => _mostrarOpcionesNotificacion(notificacion),
          borderRadius: BorderRadius.circular(10),
          splashColor: const Color(0xFF4A3B2A).withValues(alpha: 0.1),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF4A3B2A),
                width: leida ? 1 : 2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Punto de color según prioridad
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: prioridadColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Contenido: departamento, mensaje y fecha
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Departamento en negrita + mensaje
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF4A3B2A)
                                .withValues(alpha: leida ? 0.7 : 1.0),
                          ),
                          children: [
                            TextSpan(
                              text: '[${notificacion['tipoNombre'] ?? ''}] ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: notificacion['mensaje'] ?? ''),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Fecha formateada
                      Text(
                        _formatearFecha(notificacion['fechaCreacion'] ?? ''),
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF4A3B2A)
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                // Indicador visual de no leída
                if (!leida)
                  const Padding(
                    padding: EdgeInsets.only(top: 4, left: 6),
                    child: Icon(Icons.circle, size: 8, color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // DIÁLOGOS
  /// Muestra opciones al pulsar una notificación:
  /// - Marcar como leída (solo si no está leída)
  /// - Eliminar notificación
  void _mostrarOpcionesNotificacion(Map<String, dynamic> notificacion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '[${notificacion['tipoNombre'] ?? ''}]',
          style: const TextStyle(
            color: Color(0xFF4A3B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Opción marcar como leída — solo si no está leída
            if (!(notificacion['leida'] as bool? ?? false))
              ListTile(
                leading:
                    const Icon(Icons.mark_email_read, color: Colors.blue),
                title: const Text('Marcar como leída'),
                onTap: () {
                  Navigator.pop(context);
                  _marcarComoLeida(notificacion);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar notificación'),
              onTap: () {
                Navigator.pop(context);
                _eliminarNotificacion(notificacion);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF4A3B2A)),
            ),
          ),
        ],
      ),
    );
  }

  // LÓGICA DE DATOS
  /// Marca una notificación como leída llamando al NotificationService
  /// Actualiza el campo leida y fechaLectura en el backend
  Future<void> _marcarComoLeida(Map<String, dynamic> notificacion) async {
    try {
      await NotificationService.marcarComoLeida(notificacion['id'], {
        ...notificacion,
        'leida': true,
        'fechaLectura': DateTime.now().toIso8601String(),
      });

      /// Recarga las notificaciones desde el backend
      await _cargarNotificaciones();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al marcar la notificación como leída'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Marca todas las notificaciones no leídas como leídas
  /// Llama al backend para cada una de forma secuencial
  Future<void> _marcarTodasComoLeidas() async {
    try {
      final noLeidas =
          notificaciones.where((n) => n['leida'] == false).toList();
      for (final notificacion in noLeidas) {
        await NotificationService.marcarComoLeida(notificacion['id'], {
          ...notificacion,
          'leida': true,
          'fechaLectura': DateTime.now().toIso8601String(),
        });
      }

      /// Recarga las notificaciones desde el backend
      await _cargarNotificaciones();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al marcar las notificaciones como leídas'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Elimina una notificación llamando al NotificationService
  Future<void> _eliminarNotificacion(Map<String, dynamic> notificacion) async {
    try {
      await NotificationService.eliminar(notificacion['id']);

      /// Recarga las notificaciones desde el backend
      await _cargarNotificaciones();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificación eliminada'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar la notificación'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // HELPERS
  /// Retorna el color según la prioridad de la notificación
  /// MAPEO:
  /// - CRITICA → Rojo
  /// - ALTA    → Naranja
  /// - MEDIA   → Amarillo
  /// - BAJA    → Verde
  Color _getPrioridadColor(String prioridad) {
    switch (prioridad) {
      case 'CRITICA':
        return Colors.red;
      case 'ALTA':
        return Colors.orange;
      case 'MEDIA':
        return Colors.amber;
      case 'BAJA':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Formatea una fecha ISO string al formato español
  /// Entrada: "2025-10-31T10:25:00"
  /// Salida: "(31/10/2025) 10:25"
  String _formatearFecha(String fechaIso) {
    try {
      final fecha = DateTime.parse(fechaIso);
      return '(${fecha.day.toString().padLeft(2, '0')}/'
          '${fecha.month.toString().padLeft(2, '0')}/'
          '${fecha.year}) '
          '${fecha.hour.toString().padLeft(2, '0')}:'
          '${fecha.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fechaIso;
    }
  }

  // BOTTOM NAVIGATION BAR
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF4A3B2A)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.people_outline,
                isSelected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ContactPage()),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.bar_chart_outlined,
                isSelected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ReportPage()),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.home,
                isSelected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DashboardPage()),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.notifications_outlined,
                isSelected: true, // Estamos en Notificaciones → activo
                onTap: () {
                  // Ya estamos en Notificaciones
                },
              ),
              _buildNavItem(
                icon: Icons.settings_outlined,
                isSelected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ConfigurationPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget reutilizable para cada ítem de la bottom bar
  /// InkWell + Padding + Icon tamaño 28
  /// InkWell muestra la mano automáticamente al pasar el ratón
  /// Color beige completo si activo, semi-transparente si no
  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Icon(
          icon,
          size: 28,
          color: isSelected
              ? const Color(0xFFF6E9C9)
              : const Color(0xFFF6E9C9).withValues(alpha: 0.5),
        ),
      ),
    );
  }
}