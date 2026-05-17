import 'package:flutter/material.dart';
import 'configuration.dart';
import 'contact.dart';
import 'dashboard.dart';
import 'report.dart';
import 'notification.dart';
import '../services/incident_service.dart';
import '../services/auth_service.dart';

/// Pantalla de Control de Incidencias
/// CARACTERÍSTICAS PRINCIPALES:
/// 1. Carga de incidencias reales desde el backend via IncidentService
/// 2. Botón para registrar nueva incidencia — llama al backend
/// 3. Filtros por estado, prioridad y tipo — aplicados localmente
/// 4. Ordenación por fecha de reporte
/// 5. Cambio de estado al pulsar una incidencia — llama al backend
/// 6. Indicador de carga mientras se obtienen los datos
///
/// WIDGETS DE ENTRADA UTILIZADOS:
/// - TextField (título, descripción)
/// - DropdownButton (prioridad, tipo, estado)
///
/// WIDGETS DE SALIDA UTILIZADOS:
/// - ListView.builder (lista de incidencias)
/// - Card/Material (tarjetas de incidencias)
/// - AlertDialog (formulario y confirmaciones)
/// - SnackBar (feedback)
/// - CircularProgressIndicator (indicador de carga)
class IncidentPage extends StatefulWidget {
  final DateTime? mesInicial;

  const IncidentPage({super.key, this.mesInicial});

  @override
  State<IncidentPage> createState() => _IncidentPageState();
}

class _IncidentPageState extends State<IncidentPage> {
  /// Lista principal de incidencias cargada desde el backend
  /// Cada elemento es un Map con los campos del IncidenciaDTO
  List<Map<String, dynamic>> incidencias = [];

  /// Indica si los datos están siendo cargados desde el backend
  bool _cargando = true;

  /// Mensaje de error si la carga falla
  String? _error;

  /// Filtros activos — aplicados localmente sobre la lista cargada
  /// Los valores corresponden a los nombres del backend
  String _filtroEstado = 'Todas';
  String _filtroPrioridad = 'Todas';
  String _filtroTipo = 'Todos';
  String _filtroOrden = 'Más reciente';

  /// Controllers del formulario de nueva incidencia
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  /// IDs seleccionados en los dropdowns del formulario
  /// Corresponden a los IDs de las tablas de catálogo del backend
  int _nuevaPrioridadId = 2; // 2 = MEDIA
  int _nuevoTipoId = 6; // 6 = OTROS

  late DateTime _mesSeleccionado;

  @override
  void initState() {
    super.initState();

    _mesSeleccionado = widget.mesInicial ?? DateTime.now();

    _cargarIncidencias();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  // CARGA DE DATOS DESDE EL BACKEND
  /// Llama al IncidentService para obtener todas las incidencias
  /// Actualiza el estado con los datos recibidos o muestra un error
  Future<void> _cargarIncidencias() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final datos = await IncidentService.obtenerTodas();
      setState(() {
        /// Convierte la lista dinámica a List<Map<String, dynamic>>
        incidencias = List<Map<String, dynamic>>.from(datos);
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar las incidencias. Comprueba la conexión.';
        _cargando = false;
      });
    }
  }

  /// Aplica todos los filtros y ordenación sobre la lista cargada del backend
  List<Map<String, dynamic>> get _incidenciasFiltradas {
    List<Map<String, dynamic>> resultado = List.from(incidencias);

    /// FILTRO POR MES (viene del CalendarPage)
    resultado = resultado.where((i) {
      try {
        final fecha = DateTime.parse(i['fechaReporte']);
        return fecha.year == _mesSeleccionado.year &&
              fecha.month == _mesSeleccionado.month;
      } catch (_) {
        return false;
      }
    }).toList();

    /// Filtra por estado (estadoNombre en el DTO)
    if (_filtroEstado != 'Todas') {
      resultado = resultado
          .where((i) => (i['estadoNombre'] ?? '') == _filtroEstado)
          .toList();
    }

    /// Filtra por prioridad (prioridadNombre en el DTO)
    if (_filtroPrioridad != 'Todas') {
      resultado = resultado
          .where((i) => (i['prioridadNombre'] ?? '') == _filtroPrioridad)
          .toList();
    }

    /// Filtra por tipo (tipoNombre en el DTO)
    if (_filtroTipo != 'Todos') {
      resultado = resultado
          .where((i) => (i['tipoNombre'] ?? '') == _filtroTipo)
          .toList();
    }

    /// Ordena por fecha de reporte
    resultado.sort((a, b) {
      final fechaA = DateTime.tryParse(a['fechaReporte'] ?? '') ?? DateTime(0);
      final fechaB = DateTime.tryParse(b['fechaReporte'] ?? '') ?? DateTime(0);
      return _filtroOrden == 'Más reciente'
          ? fechaB.compareTo(fechaA)
          : fechaA.compareTo(fechaB);
    });

    return resultado;
  }

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

            // Título
            const Center(
              child: Text(
                'CONTROL DE INCIDENCIAS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3B2A),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón registrar incidencia
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _mostrarFormularioNuevaIncidencia,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Registrar incidencia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Título sección historial
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Incidencias',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3B2A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

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
                    valor: _filtroEstado,
                    opciones: [
                      'Todas',
                      'PENDIENTE',
                      'EN_PROCESO',
                      'RESUELTA',
                      'CERRADA',
                    ],
                    onChanged: (v) => setState(() => _filtroEstado = v!),
                  ),
                  const SizedBox(width: 8),
                  _buildDropdownFiltro(
                    valor: _filtroPrioridad,
                    opciones: ['Todas', 'CRITICA', 'ALTA', 'MEDIA', 'BAJA'],
                    onChanged: (v) => setState(() => _filtroPrioridad = v!),
                  ),
                  const SizedBox(width: 8),
                  _buildDropdownFiltro(
                    valor: _filtroTipo,
                    opciones: [
                      'Todos',
                      'FALTA_MATERIA_PRIMA',
                      'AVERIA_MAQUINARIA',
                      'CALIDAD',
                      'PRODUCCION_DETENIDA',
                      'PROBLEMA_SUMINISTRO',
                      'OTROS',
                    ],
                    onChanged: (v) => setState(() => _filtroTipo = v!),
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
                            onPressed: _cargarIncidencias,
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
                  /// Lista de incidencias filtradas
                  : _incidenciasFiltradas.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay incidencias con estos filtros',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF4A3B2A),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _incidenciasFiltradas.length,
                      itemBuilder: (context, index) {
                        return _buildIncidenciaCard(
                          _incidenciasFiltradas[index],
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

  /// Tarjeta individual de incidencia
  /// Los datos vienen del IncidenciaDTO del backend:
  /// - titulo: título de la incidencia
  /// - descripcion: descripción detallada
  /// - estadoNombre: estado actual (PENDIENTE, EN_PROCESO, RESUELTA, CERRADA)
  /// - prioridadNombre: prioridad (CRITICA, ALTA, MEDIA, BAJA)
  /// - tipoNombre: tipo de incidencia
  /// - usuarioReportaNombre: nombre del usuario que reportó
  /// - fechaReporte: fecha en formato ISO string
  Widget _buildIncidenciaCard(Map<String, dynamic> incidencia) {
    final Color estadoColor = _getEstadoColor(incidencia['estadoNombre'] ?? '');
    final Color prioridadColor = _getPrioridadColor(
      incidencia['prioridadNombre'] ?? '',
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          onTap: () => _mostrarOpcionesIncidencia(incidencia),
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFF4A3B2A).withValues(alpha: 0.1),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4A3B2A), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila superior: título + badge prioridad
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        incidencia['titulo'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3B2A),
                        ),
                      ),
                    ),
                    // Badge de prioridad
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: prioridadColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: prioridadColor, width: 1),
                      ),
                      child: Text(
                        incidencia['prioridadNombre'] ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: prioridadColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Descripción
                Text(
                  incidencia['descripcion'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF4A3B2A).withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 10),

                // Fila inferior: usuario + fecha + estado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Usuario que reportó y fecha
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 13,
                            color: Color(0xFF4A3B2A),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              incidencia['usuarioReportaNombre'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4A3B2A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.access_time,
                            size: 13,
                            color: Color(0xFF4A3B2A),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatearFecha(incidencia['fechaReporte'] ?? ''),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4A3B2A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge de estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: estadoColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        (incidencia['estadoNombre'] ?? '').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // DIÁLOGOS
  /// Formulario para registrar una nueva incidencia
  /// Envía los datos al backend via IncidentService y recarga la lista
  void _mostrarFormularioNuevaIncidencia() {
    _tituloController.clear();
    _descripcionController.clear();
    _nuevaPrioridadId = 2;
    _nuevoTipoId = 6;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text(
            'Nueva incidencia',
            style: TextStyle(
              color: Color(0xFF4A3B2A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _campoTexto(controller: _tituloController, label: 'Título'),
                _campoTexto(
                  controller: _descripcionController,
                  label: 'Descripción',
                  maxLines: 3,
                ),
                const SizedBox(height: 8),

                /// Dropdown de prioridad con IDs del backend
                _dropdownFormulario(
                  label: 'Prioridad',
                  valor: _nuevaPrioridadId.toString(),
                  opciones: {
                    '1': 'BAJA',
                    '2': 'MEDIA',
                    '3': 'ALTA',
                    '4': 'CRITICA',
                  },
                  onChanged: (v) =>
                      setStateDialog(() => _nuevaPrioridadId = int.parse(v!)),
                ),
                const SizedBox(height: 12),

                /// Dropdown de tipo con IDs del backend
                _dropdownFormulario(
                  label: 'Tipo',
                  valor: _nuevoTipoId.toString(),
                  opciones: {
                    '1': 'FALTA_MATERIA_PRIMA',
                    '2': 'AVERIA_MAQUINARIA',
                    '3': 'CALIDAD',
                    '4': 'PRODUCCION_DETENIDA',
                    '5': 'PROBLEMA_SUMINISTRO',
                    '6': 'OTROS',
                  },
                  onChanged: (v) =>
                      setStateDialog(() => _nuevoTipoId = int.parse(v!)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF4A3B2A)),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (_tituloController.text.isEmpty ||
                    _descripcionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Completa todos los campos'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                try {
                  await IncidentService.crear({
                    'titulo': _tituloController.text,
                    'descripcion': _descripcionController.text,
                    'tipo': {'id': _nuevoTipoId},
                    'prioridad': {'id': _nuevaPrioridadId},
                    'estado': {'id': 1},
                    'usuarioReporta': {'id': AuthService.usuarioId},
                  });

                  await _cargarIncidencias();

                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Incidencia registrada correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Error al registrar la incidencia'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                'Registrar',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opciones al pulsar una incidencia: cambiar estado o eliminar
  void _mostrarOpcionesIncidencia(Map<String, dynamic> incidencia) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          incidencia['titulo'] ?? '',
          style: const TextStyle(
            color: Color(0xFF4A3B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pending_outlined, color: Colors.orange),
              title: const Text('Marcar como Pendiente'),
              onTap: () {
                Navigator.pop(context);
                _cambiarEstado(incidencia, 1, 'PENDIENTE');
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync, color: Colors.blue),
              title: const Text('Marcar como En proceso'),
              onTap: () {
                Navigator.pop(context);
                _cambiarEstado(incidencia, 2, 'EN_PROCESO');
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Marcar como Resuelta'),
              onTap: () {
                Navigator.pop(context);
                _cambiarEstado(incidencia, 3, 'RESUELTA');
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined, color: Colors.grey),
              title: const Text('Cerrar incidencia'),
              onTap: () {
                Navigator.pop(context);
                _cambiarEstado(incidencia, 4, 'CERRADA');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar incidencia'),
              onTap: () {
                Navigator.pop(context);
                _eliminarIncidencia(incidencia);
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
  /// Cambia el estado de una incidencia llamando al IncidentService
  /// estadoId: ID del estado en el backend
  /// 1=PENDIENTE, 2=EN_PROCESO, 3=RESUELTA, 4=CERRADA
  Future<void> _cambiarEstado(
    Map<String, dynamic> incidencia,
    int estadoId,
    String estadoNombre,
  ) async {
    try {
      await IncidentService.actualizar(incidencia['id'], {
        ...incidencia,
        'estado': {'id': estadoId},

        /// Si se resuelve, añade la fecha de resolución automáticamente
        if (estadoId == 3) 'fechaResolucion': DateTime.now().toIso8601String(),
      });

      /// Recarga la lista desde el backend
      await _cargarIncidencias();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado actualizado a $estadoNombre'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar el estado'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Elimina una incidencia llamando al IncidentService
  Future<void> _eliminarIncidencia(Map<String, dynamic> incidencia) async {
    try {
      await IncidentService.eliminar(incidencia['id']);

      /// Recarga la lista desde el backend
      await _cargarIncidencias();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incidencia eliminada'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar la incidencia'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // WIDGETS DE FORMULARIO
  /// Campo de texto reutilizable para el formulario
  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF4A3B2A)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4A3B2A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4A3B2A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4A3B2A), width: 2),
          ),
        ),
      ),
    );
  }

  /// Dropdown del formulario con mapa de id → nombre
  /// Permite enviar IDs al backend manteniendo nombres legibles en la UI
  Widget _dropdownFormulario({
    required String label,
    required String valor,
    required Map<String, String> opciones,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: valor,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF4A3B2A)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4A3B2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4A3B2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4A3B2A), width: 2),
        ),
      ),
      items: opciones.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // HELPERS
  /// Retorna el color según el estado de la incidencia
  /// MAPEO:
  /// - RESUELTA   → Verde
  /// - EN_PROCESO → Azul
  /// - PENDIENTE  → Naranja
  /// - CERRADA    → Gris
  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'RESUELTA':
        return Colors.green;
      case 'EN_PROCESO':
        return Colors.blue;
      case 'PENDIENTE':
        return Colors.orange;
      case 'CERRADA':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Retorna el color según la prioridad de la incidencia
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
  /// Salida: "31/10/2025 10:25"
  String _formatearFecha(String fechaIso) {
    try {
      final fecha = DateTime.parse(fechaIso);
      return '${fecha.day.toString().padLeft(2, '0')}/'
          '${fecha.month.toString().padLeft(2, '0')}/'
          '${fecha.year} '
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
                      builder: (context) => const ContactPage(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.bar_chart_outlined,
                isSelected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportPage()),
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
                      builder: (context) => const DashboardPage(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.notifications_outlined,
                isSelected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationPage(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.settings_outlined,
                isSelected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConfigurationPage(),
                    ),
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
