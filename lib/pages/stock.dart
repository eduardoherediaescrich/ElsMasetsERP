import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'contact.dart';
import 'report.dart';
import 'configuration.dart';
import 'notification.dart';
import '../services/stock_service.dart';

/// Pantalla de gestión de stock de productos lácteos
/// CARACTERÍSTICAS PRINCIPALES:
/// 1. Carga de datos reales desde el backend via StockService
/// 2. Indicador de carga mientras se obtienen los datos
/// 3. Indicador visual de nivel de stock (crítico/bajo/medio/alto)
/// 4. Feedback visual con SnackBars
///
/// WIDGETS DE ENTRADA UTILIZADOS:
/// - TextField (cantidad, stock mínimo)
///
/// WIDGETS DE SALIDA UTILIZADOS:
/// - ListView.builder (lista dinámica de productos)
/// - Card/Material (tarjetas de cada producto)
/// - AlertDialog (formularios y confirmaciones)
/// - SnackBar (mensajes de feedback)
/// - CircularProgressIndicator (indicador de carga)
/// - Text dinámico (datos del producto)
/// - Icon dinámico (nivel de stock con color)
class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  /// Lista principal de productos en stock cargada desde el backend
  /// Cada elemento es un Map con los campos del StockDTO
  List<Map<String, dynamic>> productos = [];

  /// Indica si los datos están siendo cargados desde el backend
  bool _cargando = true;

  /// Mensaje de error si la carga falla
  String? _error;

  /// TextEditingController para el campo "Cantidad actual"
  final TextEditingController _cantidadController = TextEditingController();

  /// TextEditingController para el campo "Stock mínimo"
  final TextEditingController _stockMinimoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    /// Carga el stock al iniciar la pantalla
    _cargarStock();
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _stockMinimoController.dispose();
    super.dispose();
  }

  // CARGA DE DATOS DESDE EL BACKEND
  /// Llama al StockService para obtener todos los productos en stock
  /// Actualiza el estado con los datos recibidos o muestra un error
  Future<void> _cargarStock() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final datos = await StockService.obtenerTodo();
      setState(() {
        /// Convierte la lista dinámica a List<Map<String, dynamic>>
        productos = List<Map<String, dynamic>>.from(datos);
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar el stock. Comprueba la conexión.';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E9C9),

      // AppBar
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6E9C9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3B2A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // Bottom bar
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

            // Título
            const Text(
              'STOCK',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A3B2A),
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 30),

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
                                onPressed: _cargarStock,
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
                      /// Lista de productos en stock
                      : productos.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay productos en stock',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF4A3B2A),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24),
                              itemCount: productos.length,
                              itemBuilder: (context, index) {
                                return _buildProductoCard(index);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // TARJETA DE PRODUCTO
  /// Construye una tarjeta individual para cada producto en stock
  /// Los datos vienen del StockDTO del backend:
  /// - productoNombre: nombre del producto
  /// - cantidadActual: cantidad actual en stock
  /// - cantidadMinima: cantidad mínima establecida
  /// - unidadMedidaAbreviatura: unidad de medida (L, Kg, Uds)
  /// Al pulsar, muestra diálogo con opciones (Editar/Eliminar)
  Widget _buildProductoCard(int index) {
    final producto = productos[index];

    /// Convierte los valores del DTO a los tipos necesarios
    final double cantidadActual =
        (producto['cantidadActual'] as num).toDouble();
    final double cantidadMinima =
        (producto['cantidadMinima'] as num).toDouble();

    final Color nivelColor = _getNivelStockColor(cantidadActual, cantidadMinima);
    final IconData nivelIcon = _getNivelStockIcon(cantidadActual, cantidadMinima);
    final String nivelTexto = _getNivelStockTexto(cantidadActual, cantidadMinima);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          onTap: () => _mostrarOpcionesProducto(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4A3B2A), width: 2),
            ),
            child: Row(
              children: [
                // Icono de nivel de stock con fondo de color
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: nivelColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(nivelIcon, color: nivelColor, size: 28),
                ),
                const SizedBox(width: 16),

                // Nombre del producto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto['productoNombre'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3B2A),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cantidad y nivel de stock
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${cantidadActual.toStringAsFixed(0)} ${producto['unidadMedidaAbreviatura'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A3B2A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nivelTexto,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: nivelColor,
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
  /// Muestra opciones al pulsar un producto: Editar o Eliminar
  void _mostrarOpcionesProducto(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Opciones del producto',
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
              title: const Text('Editar stock'),
              onTap: () {
                /// Cierra el diálogo de opciones antes de abrir el formulario
                Navigator.pop(context);
                _mostrarDialogoEditar(index);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              /// Cierra el diálogo sin realizar ninguna acción
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

  /// Prepara y muestra el formulario para editar el stock de un producto
  /// Solo permite editar cantidad actual y stock mínimo
  void _mostrarDialogoEditar(int index) {
    final producto = productos[index];
    _cantidadController.text =
        (producto['cantidadActual'] as num).toStringAsFixed(0);
    _stockMinimoController.text =
        (producto['cantidadMinima'] as num).toStringAsFixed(0);
    _mostrarDialogoFormulario(index);
  }

  /// Muestra el formulario de edición en un AlertDialog
  void _mostrarDialogoFormulario(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Editar stock: ${productos[index]['productoNombre']}',
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
                controller: _cantidadController,
                label: 'Cantidad actual',
                esNumerico: true,
              ),
              _campoTexto(
                controller: _stockMinimoController,
                label: 'Stock mínimo',
                esNumerico: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              /// Cierra el formulario sin guardar
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
                _editarStock(index);
                /// Cierra el formulario tras guardar
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

  // WIDGETS DE FORMULARIO
  /// Widget reutilizable para campos de texto del formulario
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

  // LÓGICA DE DATOS
  /// Valida que todos los campos del formulario estén completos
  bool _validarFormulario() {
    if (_cantidadController.text.isEmpty ||
        _stockMinimoController.text.isEmpty) {
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

  /// Actualiza el stock de un producto llamando al StockService
  /// Envía los nuevos valores de cantidad y stock mínimo al backend
  Future<void> _editarStock(int index) async {
    final producto = productos[index];
    try {
      await StockService.actualizar(producto['id'], {
        'cantidadActual': double.parse(_cantidadController.text),
        'cantidadMinima': double.parse(_stockMinimoController.text),
      });

      /// Recarga el stock desde el backend para mostrar datos actualizados
      await _cargarStock();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar el stock'),
          backgroundColor: Colors.red,
        ),
      );
    }
    _limpiarFormulario();
  }

  /// Limpia todos los campos del formulario
  void _limpiarFormulario() {
    _cantidadController.clear();
    _stockMinimoController.clear();
  }

  // HELPERS: COLOR, ICONO Y TEXTO DE NIVEL
  /// Retorna el color según el nivel de stock
  /// MAPEO:
  /// - cantidad < mínimo            → Rojo    (stock crítico)
  /// - cantidad <= mínimo * 1.5     → Naranja (stock bajo)
  /// - cantidad < mínimo * 3        → Amarillo (stock medio)
  /// - cantidad >= mínimo * 3       → Verde   (stock alto)
  Color _getNivelStockColor(double cantidad, double stockMinimo) {
    if (cantidad < stockMinimo) return Colors.red;
    if (cantidad <= stockMinimo * 1.5) return Colors.orange;
    if (cantidad < stockMinimo * 3) return const Color.fromARGB(255, 196, 196, 35);
    return Colors.green;
  }

  /// Retorna el icono según el nivel de stock
  /// MAPEO:
  /// - Crítico → warning_amber_rounded (alerta roja)
  /// - Bajo    → warning_amber_outlined (alerta naranja)
  /// - Medio   → inventory_2_outlined (caja semivacía)
  /// - Alto    → inventory_2 (caja llena)
  IconData _getNivelStockIcon(double cantidad, double stockMinimo) {
    if (cantidad < stockMinimo) return Icons.warning_amber_rounded;
    if (cantidad <= stockMinimo * 1.5) return Icons.warning_amber_outlined;
    if (cantidad < stockMinimo * 3) return Icons.inventory_2_outlined;
    return Icons.inventory_2;
  }

  /// Retorna el texto descriptivo del nivel de stock
  String _getNivelStockTexto(double cantidad, double stockMinimo) {
    if (cantidad < stockMinimo) return 'Stock crítico';
    if (cantidad <= stockMinimo * 1.5) return 'Stock bajo';
    if (cantidad < stockMinimo * 3) return 'Stock medio';
    return 'Stock alto';
  }

  // BOTTOM NAVIGATION BAR
  /// Fondo marrón oscuro, 5 iconos, isSelected marca el activo en beige
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
                isSelected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationPage()),
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
  /// InkWell + Padding + Icon tamaño 28 fijo
  /// InkWell muestra la mano automáticamente al pasar el ratón
  /// Color beige completo si activo, semi-transparente si no (igual que Dashboard)
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