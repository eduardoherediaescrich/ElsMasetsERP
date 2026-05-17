import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'contact.dart';
import 'report.dart';
import 'configuration.dart';
import 'notification.dart';
import '../services/lot_service.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/state_lot.dart';
import '../services/measurement_unit_service.dart';

/// Pantalla de gestión de producción láctea
/// CARACTERÍSTICAS PRINCIPALES:
/// 1. Carga de lotes reales desde el backend via LotService
/// 2. Filtrado por fecha: Por defecto muestra los lotes de hoy
/// 3. DatePicker: Permite cambiar la fecha para ver otros días
/// 4. CRUD completo: Crear, Leer, Actualizar y Eliminar lotes — llaman al backend
/// 5. Validación de formularios
/// 6. Indicador de carga mientras se obtienen los datos
/// 7. Feedback visual con SnackBars
///
/// WIDGETS DE ENTRADA UTILIZADOS:
/// - TextField (cantidad)
/// - DropdownButton (productoId, unidadId, estadoId)
/// - DatePicker (selección de fecha)
///
/// WIDGETS DE SALIDA UTILIZADOS:
/// - ListView.builder (lista dinámica de lotes)
/// - Card/Material (tarjetas de cada lote)
/// - AlertDialog (formularios y confirmaciones)
/// - SnackBar (mensajes de feedback)
/// - CircularProgressIndicator (indicador de carga)
/// - Text dinámico (datos de los lotes)
/// - Icon dinámico (estado con color)
class ProductionPage extends StatefulWidget {
  final DateTime? fechaInicial;

  const ProductionPage({super.key, this.fechaInicial});

  @override
  State<ProductionPage> createState() => _ProductionPageState();
}

class _ProductionPageState extends State<ProductionPage> {
  /// Lista principal de lotes de producción cargada desde el backend
  List<Map<String, dynamic>> producciones = [];

  bool _cargando = true;
  String? _error;

  DateTime _fechaSeleccionada = DateTime.now();

  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _caducidadController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  /// Variables por defecto para los dropdowns (producto, unidad, estado)
  int _productoIdSeleccionado = 1;
  int _unidadIdSeleccionada = 1;
  int _estadoIdSeleccionado = 1;

  /// Mapa de productos (dinámico, cargado del backend)
  Map<int, String> _productos = {};

  /// Mapa de unidades de medida (dinámico, cargado del backend)
  Map<int, String> _unidades = {};

  /// Mapa de estados de lote (dinámico, cargado del backend)
  Map<int, String> _estados = {};

  /// Flags para la carga de los catálogos (unidades, estados y productos)
  bool _cargandoCatalogos = true;
  String? _errorCatalogos;

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = widget.fechaInicial ?? DateTime.now();
    _cargarDatosIniciales();
  }

  /// Inicia la carga de lotes y de los catálogos de unidades, estados y productos
  Future<void> _cargarDatosIniciales() async {
    // Ambos procesos se pueden lanzar en paralelo
    await Future.wait([
      _cargarLotes(),
      _cargarCatalogos(),
    ]);
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _caducidadController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  // CARGA DE DATOS DESDE EL BACKEND
  Future<void> _cargarLotes() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final datos = await LotService.obtenerTodos();
      setState(() {
        producciones = List<Map<String, dynamic>>.from(datos);
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los lotes. Comprueba la conexión.';
        _cargando = false;
      });
    }
  }

  //Carga los catálogos de unidades, estados y productos desde el backend
  Future<void> _cargarCatalogos() async {
    setState(() {
      _cargandoCatalogos = true;
      _errorCatalogos = null;
    });

    try {
      // Cargamos los tres catálogos en paralelo
      final resultados = await Future.wait([
        UnidadMedidaService.obtenerTodas(),
        EstadoLoteService.obtenerTodos(),
        ProductService.obtenerTodos(),
      ]);

      final unidadesData = resultados[0];
      final estadosData = resultados[1];
      final productosData = resultados[2];

      // Unidades
      final Map<int, String> unidadesMap = {};
      for (var u in unidadesData) {
        final id = u['id'] as int;
        final texto = (u['abreviatura'] ?? u['nombre'] ?? '').toString();
        unidadesMap[id] = texto;
      }

      // Estados
      final Map<int, String> estadosMap = {};
      for (var e in estadosData) {
        final id = e['id'] as int;
        final texto = (e['nombre'] ?? '').toString();
        estadosMap[id] = texto;
      }

      // Productos
      final Map<int, String> productosMap = {};
      for (var p in productosData) {
        final id = p['id'] as int;
        final nombre = (p['nombre'] ?? '').toString();
        productosMap[id] = nombre;
      }

      setState(() {
        _unidades = unidadesMap;
        _estados = estadosMap;
        _productos = productosMap;
        _cargandoCatalogos = false;

        // Ajuste de selecciones por defecto: si el ID seleccionado no existe en el nuevo catálogo, se asigna el primero disponible
        if (_unidades.isNotEmpty && !_unidades.containsKey(_unidadIdSeleccionada)) {
          _unidadIdSeleccionada = _unidades.keys.first;
        }
        if (_estados.isNotEmpty && !_estados.containsKey(_estadoIdSeleccionado)) {
          _estadoIdSeleccionado = _estados.keys.first;
        }
        if (_productos.isNotEmpty && !_productos.containsKey(_productoIdSeleccionado)) {
          _productoIdSeleccionado = _productos.keys.first;
        }
      });
    } catch (e) {
      setState(() {
        _errorCatalogos = 'Error al cargar unidades, estados o productos.';
        _cargandoCatalogos = false;
      });
    }
  }

  /// Filtra la lista de lotes por la fecha seleccionada
  List<Map<String, dynamic>> _obtenerProduccionesFiltradas() {
    return producciones.where((produccion) {
      try {
        final fechaElaboracion = DateTime.parse(
          produccion['fechaElaboracion'] ?? '',
        );
        return fechaElaboracion.year == _fechaSeleccionada.year &&
            fechaElaboracion.month == _fechaSeleccionada.month &&
            fechaElaboracion.day == _fechaSeleccionada.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final produccionesFiltradas = _obtenerProduccionesFiltradas();

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
              child: Image.asset('assets/masets_blanco.png', height: 140),
            ),
            const SizedBox(height: 20),
            const Text(
              'PRODUCCIÓN',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A3B2A),
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 30),

            // Mientras se cargan los catálogos no mostramos el botón de añadir
            if (!_cargandoCatalogos && _errorCatalogos == null) ...[
              // Botón añadir lote
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _mostrarDialogoAgregar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text(
                      'Añadir lote',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Selector de fecha (siempre visible)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildSelectorFecha(),
            ),
            const SizedBox(height: 20),

            // Contenido principal
            Expanded(
              child: _cargandoCatalogos
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4A3B2A),
                      ),
                    )
                  : _errorCatalogos != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorCatalogos!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF4A3B2A),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _cargarCatalogos,
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
                      : _cargando
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF4A3B2A),
                              ),
                            )
                          : _error != null
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
                                        onPressed: _cargarLotes,
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
                              : produccionesFiltradas.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No hay registros para el ${_formatearFechaES(_fechaSeleccionada)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF4A3B2A),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      itemCount: produccionesFiltradas.length,
                                      itemBuilder: (context, index) {
                                        final produccion = produccionesFiltradas[index];
                                        final indiceReal = producciones.indexOf(produccion);
                                        return _buildProduccionCard(indiceReal);
                                      },
                                    ),
            ),
          ],
        ),
      ),
    );
  }

  // SELECTOR DE FECHA
  Widget _buildSelectorFecha() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 1,
      child: InkWell(
        onTap: _mostrarSelectorFecha,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF4A3B2A), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF4A3B2A), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _fechaSeleccionada.day == DateTime.now().day &&
                            _fechaSeleccionada.month == DateTime.now().month &&
                            _fechaSeleccionada.year == DateTime.now().year
                        ? 'Hoy - ${_formatearFecha(_fechaSeleccionada)}'
                        : _formatearFecha(_fechaSeleccionada),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF4A3B2A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF4A3B2A)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarSelectorFecha() async {
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A3B2A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF4A3B2A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (fechaElegida != null && fechaElegida != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = fechaElegida;
      });
    }
  }

  // TARJETA DE LOTE
  Widget _buildProduccionCard(int index) {
    final produccion = producciones[index];
    final Color estadoColor = _getEstadoColor(produccion['estadoNombre'] ?? '');
    final IconData estadoIcon = _getEstadoIcon(produccion['estadoNombre'] ?? '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          onTap: () => _mostrarOpcionesLote(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4A3B2A), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        produccion['productoNombre'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3B2A),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(estadoIcon, size: 20, color: estadoColor),
                        const SizedBox(width: 6),
                        Text(
                          produccion['estadoNombre'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: estadoColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(produccion['cantidad'] as num?)?.toStringAsFixed(0) ?? ''} ${produccion['unidadMedidaAbreviatura'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A3B2A),
                      ),
                    ),
                    Text(
                      'Cad: ${_convertirFechaBackendaES(produccion['fechaCaducidad'] ?? '')}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4A3B2A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Por: ${produccion['usuarioCreadorNombre'] ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF4A3B2A).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // DIÁLOGOS
  void _mostrarOpcionesLote(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Opciones del lote',
          style: TextStyle(color: Color(0xFF4A3B2A), fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Editar lote'),
              onTap: () {
                Navigator.pop(context);
                _mostrarDialogoEditar(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar lote'),
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminacion(index);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF4A3B2A))),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminacion(int index) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '¿Eliminar lote?',
          style: TextStyle(color: Color(0xFF4A3B2A), fontWeight: FontWeight.bold),
        ),
        content: const Text('¿Estás seguro de que deseas eliminar este registro de producción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF4A3B2A))),
          ),
          TextButton(
            onPressed: () async {
              final lote = producciones[index];
              try {
                await LotService.eliminar(lote['id']);
                await _cargarLotes();
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Lote eliminado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Error al eliminar el lote'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAgregar() {
    _limpiarFormulario();
    _mostrarDialogoFormulario('Nuevo lote', null);
  }

  void _mostrarDialogoEditar(int index) {
    final produccion = producciones[index];
    _cantidadController.text =
        (produccion['cantidad'] as num?)?.toStringAsFixed(0) ?? '';
    _caducidadController.text =
        _convertirFechaBackendaES(produccion['fechaCaducidad'] ?? '');
    _observacionesController.text = produccion['observaciones'] ?? '';

    // Usamos los mapas dinámicos _unidades y _estados
    // para encontrar el ID correspondiente a la abreviatura o nombre almacenado en el lote
    final unidadAbrev = produccion['unidadMedidaAbreviatura'] ?? 'L';
    _unidadIdSeleccionada = _unidades.entries
        .firstWhere(
          (e) => e.value == unidadAbrev,
          orElse: () => _unidades.entries.isNotEmpty
              ? _unidades.entries.first
              : const MapEntry(1, 'L'),
        )
        .key;

    _estadoIdSeleccionado = _estados.entries
        .firstWhere(
          (e) => e.value == produccion['estadoNombre'],
          orElse: () => _estados.entries.isNotEmpty
              ? _estados.entries.first
              : const MapEntry(1, 'EN_PROCESO'),
        )
        .key;

    _mostrarDialogoFormulario('Editar lote', index);
  }

  void _mostrarDialogoFormulario(String titulo, int? index) {
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(
            titulo,
            style: const TextStyle(
              color: Color(0xFF4A3B2A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index == null)
                  _dropdownFormulario(
                    label: 'Producto',
                    valor: _productoIdSeleccionado,
                    opciones: _productos,
                    onChanged: (v) =>
                        setStateDialog(() => _productoIdSeleccionado = v!),
                  ),
                if (index == null) const SizedBox(height: 12),
                _campoTexto(
                  controller: _cantidadController,
                  label: 'Cantidad',
                  esNumerico: true,
                ),
                // Usamos los mapas dinámicos _unidades y _estados
                // para mostrar las opciones correctas en los dropdowns
                _dropdownFormulario(
                  label: 'Unidad de medida',
                  valor: _unidadIdSeleccionada,
                  opciones: _unidades,
                  onChanged: (v) =>
                      setStateDialog(() => _unidadIdSeleccionada = v!),
                ),
                const SizedBox(height: 12),
                _campoTexto(
                  controller: _caducidadController,
                  label: 'Fecha caducidad (DD/MM/AAAA)',
                ),
                _dropdownFormulario(
                  label: 'Estado',
                  valor: _estadoIdSeleccionado,
                  opciones: _estados,
                  onChanged: (v) =>
                      setStateDialog(() => _estadoIdSeleccionado = v!),
                ),
                const SizedBox(height: 12),
                _campoTexto(
                  controller: _observacionesController,
                  label: 'Observaciones',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: Color(0xFF4A3B2A))),
            ),
            TextButton(
              onPressed: () async {
                if (!_validarFormulario()) return;
                if (index == null) {
                  await _agregarProduccion();
                } else {
                  await _editarProduccion(index);
                }
                navigator.pop();
              },
              child: const Text(
                'Guardar',
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGETS DE FORMULARIO
  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    bool esNumerico = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: esNumerico ? TextInputType.number : TextInputType.text,
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

  Widget _dropdownFormulario({
    required String label,
    required int valor,
    required Map<int, String> opciones,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
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
        return DropdownMenuItem<int>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // LÓGICA DE DATOS
  bool _validarFormulario() {
    if (_cantidadController.text.isEmpty || _caducidadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _agregarProduccion() async {
    try {
      await LotService.crear({
        'producto': {'id': _productoIdSeleccionado},
        'cantidad': double.parse(_cantidadController.text),
        'unidadMedida': {'id': _unidadIdSeleccionada},
        'fechaElaboracion': _formatearFechaBackend(_fechaSeleccionada),
        'fechaCaducidad': _convertirFechaESaBackend(_caducidadController.text),
        'estado': {'id': _estadoIdSeleccionado},
        'usuarioCreador': {'id': AuthService.usuarioId},
        'observaciones': _observacionesController.text,
      });
      await _cargarLotes();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lote agregado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al agregar el lote'),
          backgroundColor: Colors.red,
        ),
      );
    }
    _limpiarFormulario();
  }

  Future<void> _editarProduccion(int index) async {
    final lote = producciones[index];
    try {
      await LotService.actualizar(lote['id'], {
        'id': lote['id'],
        'producto': {'id': lote['productoId']},
        'fechaElaboracion': lote['fechaElaboracion'],
        'cantidad': double.parse(_cantidadController.text),
        'unidadMedida': {'id': _unidadIdSeleccionada},
        'fechaCaducidad': _convertirFechaESaBackend(_caducidadController.text),
        'estado': {'id': _estadoIdSeleccionado},
        'observaciones': _observacionesController.text,
      });
      await _cargarLotes();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lote actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar el lote'),
          backgroundColor: Colors.red,
        ),
      );
    }
    _limpiarFormulario();
  }

  void _limpiarFormulario() {
    _cantidadController.clear();
    _caducidadController.clear();
    _observacionesController.clear();
    _productoIdSeleccionado = 1;
    _unidadIdSeleccionada = 1;
    _estadoIdSeleccionado = 1;
  }

  // ─────────────────────────────────────────────
  // HELPERS: COLORES E ICONOS (sin cambios)
  // ─────────────────────────────────────────────
  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'COMPLETADO':
        return Colors.green;
      case 'EN_PROCESO':
        return Colors.orange;
      case 'EN_MADURACION':
        return Colors.orange;
      case 'ENVASADO':
        return Colors.green;
      case 'RECHAZADO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'COMPLETADO':
        return Icons.check_circle;
      case 'EN_PROCESO':
        return Icons.hourglass_empty;
      case 'EN_MADURACION':
        return Icons.hourglass_empty;
      case 'ENVASADO':
        return Icons.check_circle;
      case 'RECHAZADO':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  // FORMATEO DE FECHAS
  String _formatearFecha(DateTime fecha) {
    final meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }

  String _formatearFechaES(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  String _formatearFechaBackend(DateTime fecha) {
    return '${fecha.year}-'
        '${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')}';
  }

  String _convertirFechaESaBackend(String fechaES) {
    try {
      final partes = fechaES.split('/');
      final dia = partes[0].padLeft(2, '0');
      final mes = partes[1].padLeft(2, '0');
      final anio = partes[2];
      return '$anio-$mes-$dia';
    } catch (e) {
      return fechaES;
    }
  }

  String _convertirFechaBackendaES(String fechaBackend) {
    try {
      final partes = fechaBackend.split('-');
      final anio = partes[0];
      final mes = partes[1];
      final dia = partes[2];
      return '$dia/$mes/$anio';
    } catch (e) {
      return fechaBackend;
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
              _buildNavItem(icon: Icons.people_outline, isSelected: false, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactPage()));
              }),
              _buildNavItem(icon: Icons.bar_chart_outlined, isSelected: false, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportPage()));
              }),
              _buildNavItem(icon: Icons.home, isSelected: false, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
              }),
              _buildNavItem(icon: Icons.notifications_outlined, isSelected: false, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationPage()));
              }),
              _buildNavItem(icon: Icons.settings_outlined, isSelected: false, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfigurationPage()));
              }),
            ],
          ),
        ),
      ),
    );
  }

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