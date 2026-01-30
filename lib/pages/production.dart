import 'package:flutter/material.dart';

/// Pantalla de gestión de producción láctea
/// CARACTERÍSTICAS PRINCIPALES:
/// 1. Filtrado por fecha: Por defecto muestra los lotes de hoy
/// 2. DatePicker: Permite cambiar la fecha para ver otros días
/// 3. CRUD completo: Crear, Leer, Actualizar y Eliminar lotes
/// 4. Validación de formularios
/// 5. Feedback visual con SnackBars
///
/// WIDGETS DE ENTRADA UTILIZADOS:
/// - TextField (tipo, cantidad, lote)
/// - DropdownButton (unidad, estado)
/// - DatePicker (selección de fecha)
///
/// WIDGETS DE SALIDA UTILIZADOS:
/// - ListView.builder (lista dinámica de lotes)
/// - Card/Material (tarjetas de cada lote)
/// - AlertDialog (formularios y confirmaciones)
/// - SnackBar (mensajes de feedback)
/// - Text dinámico (datos de los lotes)
/// - Icon dinámico (estado con color)
class ProductionPage extends StatefulWidget {
  const ProductionPage({super.key});

  @override
  State<ProductionPage> createState() => _ProductionPageState();
}

class _ProductionPageState extends State<ProductionPage> {
  /// Lista principal de registros de producción
  List<Map<String, dynamic>> producciones = [
    {
      'fecha': DateTime.now(),
      'tipo': 'Leche entera pasteurizada',
      'cantidad': 1250,
      'unidad': 'L',
      'lote': 'L-2025-11-03',
      'estado': 'Completado',
    },
    {
      'fecha': DateTime.now(),
      'tipo': 'Queso semicurado',
      'cantidad': 965,
      'unidad': 'kg',
      'lote': 'L-2025-10-28',
      'estado': 'En maduración',
    },
    {
      'fecha': DateTime.now(),
      'tipo': 'Queso fresco',
      'cantidad': 180,
      'unidad': 'kg',
      'lote': 'L-2025-11-01',
      'estado': 'Envasado',
    },
    {
      'fecha': DateTime.now(),
      'tipo': 'Flan requesón',
      'cantidad': 270,
      'unidad': 'kg',
      'lote': 'L-2025-10-30',
      'estado': 'En proceso',
    },
  ];

  /// Fecha seleccionada por el usuario para filtrar los lotes
  /// FUNCIONAMIENTO:
  /// - Por defecto es DateTime.now() (fecha actual)
  /// - Cambia cuando el usuario selecciona otra fecha en el DatePicker
  /// - Filtra automáticamente la lista de producciones
  /// EFECTO:
  /// Cuando cambia esta variable:
  /// 1. setState() reconstruye el widget
  /// 2. _obtenerProduccionesFiltradas() se ejecuta de nuevo
  /// 3. ListView.builder muestra solo los lotes del día seleccionado
  DateTime _fechaSeleccionada = DateTime.now();

  /// TextEditingController para el campo "Tipo de producto"
  /// PROPÓSITO:
  /// - Lee el texto que el usuario escribe en el TextField
  /// - Permite prellenar el campo al editar (_tipoController.text = valor)
  /// - Se limpia después de guardar (_tipoController.clear())
  final TextEditingController _tipoController = TextEditingController();

  /// TextEditingController para el campo "Cantidad"
  /// PROPÓSITO:
  /// - Lee el número que el usuario escribe
  /// - Se convierte a int al guardar: int.parse(_cantidadController.text)
  final TextEditingController _cantidadController = TextEditingController();

  /// TextEditingController para el campo "Número de lote"
  /// PROPÓSITO:
  /// - Captura el código identificador del lote
  final TextEditingController _loteController = TextEditingController();

  /// Unidad seleccionada en el dropdown
  /// VALORES POSIBLES: 'L', 'kg', 'unidades'
  /// POR DEFECTO: 'L' (litros)
  /// FUNCIONAMIENTO:
  /// - Cuando el usuario selecciona una opción, setState() actualiza este valor
  /// - El DropdownButtonFormField muestra el valor actual
  String _unidadSeleccionada = 'L';

  /// Estado seleccionado en el dropdown
  /// VALORES POSIBLES:
  /// - 'En proceso': Lote en producción
  /// - 'Completado': Lote finalizado
  /// - 'En maduración': Productos que requieren tiempo (quesos)
  /// - 'Envasado': Listo para distribución
  /// POR DEFECTO: 'En proceso' (para nuevos lotes)
  String _estadoSeleccionado = 'En proceso';

  /// Libera los recursos de los controladores al destruir el widget
  @override
  void dispose() {
    _tipoController.dispose();
    _cantidadController.dispose();
    _loteController.dispose();
    super.dispose();
  }

  /// Método que filtra la lista de producciones para mostrar solo los lotes del día seleccionado
  /// LÓGICA:
  /// 1. Recorre TODOS los lotes de la lista 'producciones'
  /// 2. Compara la fecha de cada lote con _fechaSeleccionada
  /// 3. Solo incluye lotes donde año, mes y día coincidan EXACTAMENTE
  /// DEVUELVE: Lista filtrada con solo los lotes del día seleccionado
  List<Map<String, dynamic>> _obtenerProduccionesFiltradas() {
    return producciones.where((produccion) {
      // Obtiene la fecha del lote actual
      final fechaProduccion = produccion['fecha'] as DateTime;

      // Compara año, mes y día para verificar si es el mismo día
      return fechaProduccion.year == _fechaSeleccionada.year &&
          fechaProduccion.month == _fechaSeleccionada.month &&
          fechaProduccion.day == _fechaSeleccionada.day;
    }).toList();
  }

  /// Estructura de la página (de arriba a abajo)
  /// Este método se ejecuta automáticamente cuando:
  /// - Se abre la página por primera vez
  /// - Se llama setState() (cambio de fecha, agregar/editar/eliminar lote)
  /// - El usuario cambia la fecha en el DatePicker
  @override
  Widget build(BuildContext context) {
    // Filtra los lotes según la fecha seleccionada
    final produccionesFiltradas = _obtenerProduccionesFiltradas();

    return Scaffold(
      backgroundColor: const Color(0xFFF6E9C9),

      // Barra superior con título y botón de volver
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6E9C9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3B2A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: SafeArea(
        child: Column(
          children: [
            //Logo
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
              ),
            ),
            const SizedBox(height: 30),

            // Fila: Fecha actual y botón añadir lote
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                // Botón verde para agregar nuevo lote
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

            // Selector de fecha (DATEPICKER)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildSelectorFecha(),
            ),

            const SizedBox(height: 20),

            // Lista de lotes filtrados o mensaje vacío
            Expanded(
              child: produccionesFiltradas.isEmpty
                  // Si no hay lotes en la fecha seleccionada
                  ? Center(
                      child: Text(
                        'No hay registros para el ${_formatearFecha(_fechaSeleccionada)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4A3B2A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  // Si hay lotes, muestra la lista dinámica
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: produccionesFiltradas.length,
                      itemBuilder: (context, index) {
                        // Obtiene el índice real en la lista completa
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

  // Selector de fecha:
  /// - Al hacer clic, llama a _mostrarSelectorFecha()
  /// - Abre el DatePicker nativo de Flutter
  /// - Muestra "Hoy - fecha" si es el día actual
  /// - Muestra solo la fecha si es otro día
  Widget _buildSelectorFecha() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 1,
      child: InkWell(
        // Al pulsar, abre el DatePicker
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
                  // Icono de calendario
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF4A3B2A),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  // Texto que muestra la fecha
                  // Lógica: Si es HOY muestra "Hoy - fecha", sino solo "fecha"
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
              // Flecha indicando que es clickeable
              const Icon(Icons.arrow_drop_down, color: Color(0xFF4A3B2A)),
            ],
          ),
        ),
      ),
    );
  }

  /// Muestra el DatePicker (calendario) para seleccionar una fecha
  /// - initialDate: Fecha que aparece seleccionada al abrir
  /// - firstDate: Fecha mínima seleccionable (2020)
  /// - lastDate: Fecha máxima seleccionable (2030)
  /// - builder: Personaliza los colores del calendario
  Future<void> _mostrarSelectorFecha() async {
    // Abre el calendario y espera a que el usuario seleccione
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      // Personaliza los colores del calendario
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A3B2A), // Color principal (header)
              onPrimary: Colors.white, // Texto en header
              onSurface: Color(0xFF4A3B2A), // Días del mes
            ),
          ),
          child: child!,
        );
      },
    );

    // Si el usuario eligió una fecha (no canceló) y es diferente
    if (fechaElegida != null && fechaElegida != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = fechaElegida;
      });
      // Al llamar setState(), el widget se reconstruye
      // _obtenerProduccionesFiltradas() se ejecuta de nuevo
      // La lista muestra solo lotes de la nueva fecha
    }
  }

  // Tarjeta de lotes: Construye una tarjeta individual para mostrar un lote de producción
  /// - Al pulsar la tarjeta, muestra diálogo con opciones (Editar/Eliminar)
  Widget _buildProduccionCard(int index) {
    final produccion = producciones[index];

    // Obtiene color e icono según el estado del lote
    final Color estadoColor = _getEstadoColor(produccion['estado']);
    final IconData estadoIcon = _getEstadoIcon(produccion['estado']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          // Al pulsar, muestra opciones (Editar/Eliminar)
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
                // Fila superior: Tipo de producto y Estado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        produccion['tipo'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3B2A),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Icon cambia según el estado
                        Icon(estadoIcon, size: 20, color: estadoColor),
                        const SizedBox(width: 6),
                        // Text muestra el estado y cambia de color
                        Text(
                          produccion['estado'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: estadoColor, // Verde o naranja
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Fila inferior: Cantidad y Número de lote
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${produccion['cantidad']} ${produccion['unidad']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A3B2A),
                      ),
                    ),
                    Text(
                      produccion['lote'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4A3B2A),
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

  /// Muestra un diálogo con opciones para el lote seleccionado:
  /// - Editar lote
  /// - Eliminar lote
  /// - Cancelar
  void _mostrarOpcionesLote(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Opciones del lote',
          style: TextStyle(
            color: Color(0xFF4A3B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Editar lote'),
              onTap: () {
                /// Cierra el diálogo de opciones antes de abrir el formulario de edición
                /// Usa pop() para quitar solo el diálogo actual de la pila
                Navigator.pop(context);
                _mostrarDialogoEditar(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar lote'),
              onTap: () {
                /// Cierra el diálogo de opciones antes de mostrar confirmación
                /// Usa pop() para quitar solo el diálogo actual de la pila
                Navigator.pop(context);
                _confirmarEliminacion(index);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              /// Cierra el diálogo sin realizar ninguna acción
              /// Usa pop() para quitar el diálogo de la pila
              Navigator.pop(context);
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF4A3B2A)),
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo de confirmación antes de eliminar un lote
  void _confirmarEliminacion(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '¿Eliminar lote?',
          style: TextStyle(
            color: Color(0xFF4A3B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este registro de producción?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              /// Cierra el diálogo de confirmación sin eliminar el lote
              /// Usa pop() para volver a la lista sin cambios
              Navigator.pop(context);
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF4A3B2A)),
            ),
          ),
          TextButton(
            onPressed: () {
              // Elimina el lote de la lista
              setState(() {
                producciones.removeAt(index);
              });

              /// Cierra el diálogo de confirmación tras eliminar el lote
              /// Usa pop() para volver a la lista actualizada sin el lote eliminado
              Navigator.pop(context);
              // SnackBar con mensaje de éxito
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lote eliminado correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
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

  /// Prepara y muestra el formulario para agregar un nuevo lote
  void _mostrarDialogoAgregar() {
    _limpiarFormulario();
    _mostrarDialogoFormulario('Nuevo lote', null);
  }

  /// Prepara y muestra el formulario para editar un lote existente:
  /// 1. Lee los datos del lote seleccionado
  /// 2. Prellena los controllers con esos datos
  /// 3. Muestra el formulario
  void _mostrarDialogoEditar(int index) {
    final produccion = producciones[index];
    _tipoController.text = produccion['tipo'];
    _cantidadController.text = produccion['cantidad'].toString();
    _loteController.text = produccion['lote'];
    _unidadSeleccionada = produccion['unidad'];
    _estadoSeleccionado = produccion['estado'];
    _mostrarDialogoFormulario('Editar lote', index);
  }

  /// Muestra el formulario en un AlertDialog
  void _mostrarDialogoFormulario(String titulo, int? index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              _campoTexto(
                controller: _tipoController,
                label: 'Tipo de producto',
              ),
              _campoTexto(
                controller: _cantidadController,
                label: 'Cantidad',
                esNumerico: true,
              ),
              const SizedBox(height: 16),
              _dropdownUnidad(),
              const SizedBox(height: 16),
              _campoTexto(controller: _loteController, label: 'Número de lote'),
              _dropdownEstado(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              /// Cierra el formulario sin guardar cambios
              /// Usa pop() para descartar la operación y volver a la lista
              Navigator.pop(context);
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF4A3B2A)),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_validarFormulario()) {
                if (index == null) {
                  _agregarProduccion();
                } else {
                  _editarProduccion(index);
                }

                /// Cierra el formulario tras guardar los cambios
                /// Usa pop() para volver a la lista actualizada con el nuevo/editado lote
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Guardar',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget reutilizable para campos de texto del formulario:
  /// - controller: TextEditingController para leer/escribir el texto
  /// - label: Etiqueta que aparece en el campo
  /// - esNumerico: Si true, muestra teclado numérico
  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    bool esNumerico = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: esNumerico ? TextInputType.number : TextInputType.text,
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

  /// Dropdown para seleccionar la unidad de medida:
  /// 'L', 'kg', 'unidades'
  Widget _dropdownUnidad() {
    return DropdownButtonFormField<String>(
      value: _unidadSeleccionada,
      decoration: InputDecoration(
        labelText: 'Unidad',
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
      items: ['L', 'kg', 'unidades'].map((String unidad) {
        return DropdownMenuItem<String>(value: unidad, child: Text(unidad));
      }).toList(),
      onChanged: (String? nuevoValor) {
        setState(() {
          _unidadSeleccionada = nuevoValor!;
        });
      },
    );
  }

  /// Dropdown para seleccionar el estado del lote:
  /// 'En proceso', 'Completado', 'En maduración', 'Envasado'
  Widget _dropdownEstado() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: DropdownButtonFormField<String>(
        value: _estadoSeleccionado,
        decoration: InputDecoration(
          labelText: 'Estado',
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
        items: ['En proceso', 'Completado', 'En maduración', 'Envasado'].map((
          String estado,
        ) {
          return DropdownMenuItem<String>(value: estado, child: Text(estado));
        }).toList(),
        onChanged: (String? nuevoValor) {
          setState(() {
            _estadoSeleccionado = nuevoValor!;
          });
        },
      ),
    );
  }

  /// Valida que todos los campos del formulario estén completos
  bool _validarFormulario() {
    if (_tipoController.text.isEmpty ||
        _cantidadController.text.isEmpty ||
        _loteController.text.isEmpty) {
      // SnackBar con mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          // SnackBar de error si algún campo está vacío
          content: Text('Por favor, completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  /// Agrega un nuevo lote a la lista de producciones
  /// PROCESO:
  /// 1. Lee los valores de los controllers
  /// 2. Crea un Map con toda la información
  /// 3. Inserta al inicio de la lista (index 0)
  /// 4. Actualiza la UI con setState()
  /// 5. Muestra SnackBar de éxito
  /// 6. Limpia el formulario
  void _agregarProduccion() {
    setState(() {
      producciones.insert(0, {
        'fecha': _fechaSeleccionada, // ← Usa la fecha seleccionada actualmente
        'tipo': _tipoController.text,
        'cantidad': int.parse(_cantidadController.text),
        'unidad': _unidadSeleccionada,
        'lote': _loteController.text,
        'estado': _estadoSeleccionado,
      });
    });
    // SnackBar con mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lote agregado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
    _limpiarFormulario();
  }

  /// Edita un lote existente en la lista
  /// PROCESO:
  /// 1. Lee los valores de los controllers
  /// 2. Actualiza el Map en la posición 'index'
  /// 3. Mantiene la fecha original del lote (no cambia)
  /// 4. Actualiza la UI con setState()
  /// 5. Muestra SnackBar de éxito
  /// 6. Limpia el formulario
  void _editarProduccion(int index) {
    setState(() {
      producciones[index] = {
        'fecha': producciones[index]['fecha'], // ← Mantiene la fecha original
        'tipo': _tipoController.text,
        'cantidad': int.parse(_cantidadController.text),
        'unidad': _unidadSeleccionada,
        'lote': _loteController.text,
        'estado': _estadoSeleccionado,
      };
    });
    // SnackBar con mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lote actualizado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
    _limpiarFormulario();
  }

  /// Limpia todos los campos del formulario
  void _limpiarFormulario() {
    _tipoController.clear();
    _cantidadController.clear();
    _loteController.clear();
    _unidadSeleccionada = 'L';
    _estadoSeleccionado = 'En proceso';
  }

  /// Métodos de ayuda: Colores e iconos
  /// Retorna el color según el estado del lote
  /// MAPEO:
  /// - 'Completado' → Verde
  /// - 'En proceso' → Naranja
  /// - 'En maduración' → Naranja
  /// - 'Envasado' → Verde
  /// - Otro → Gris
  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Completado':
        return Colors.green;
      case 'En proceso':
        return Colors.orange;
      case 'En maduración':
        return Colors.orange;
      case 'Envasado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Retorna el icono según el estado del lote
  /// MAPEO:
  /// - 'Completado' → ✓ (check_circle)
  /// - 'En proceso' → ⏳ (hourglass_empty)
  /// - 'En maduración' → ⏳ (hourglass_empty)
  /// - 'Envasado' → ✓ (check_circle)
  /// - Otro → ? (help_outline)
  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'Completado':
        return Icons.check_circle;
      case 'En proceso':
        return Icons.hourglass_empty;
      case 'En maduración':
        return Icons.hourglass_empty;
      case 'Envasado':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  /// Formatea una fecha al formato español sin día de la semana:
  /// 1. Extrae día, mes y año
  /// 2. Convierte el número del mes a nombre español
  /// 3. Construye el string con formato español
  String _formatearFecha(DateTime fecha) {
    final meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    final dia = fecha.day;
    final mes = meses[fecha.month - 1];
    final year = fecha.year;

    return '$dia de $mes de $year';
  }
}
