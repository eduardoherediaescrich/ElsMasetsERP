import 'package:flutter/material.dart';
import 'configuration.dart';
import 'dashboard.dart';
import 'report.dart';
import 'notification.dart';

/// Pantalla de detalle de un cliente
/// CARACTERÍSTICAS PRINCIPALES:
/// 1. Recibe el cliente con sus compras ya cargadas desde ClientPage
/// 2. Muestra todos los productos comprados ordenados de más a menos
///    (el orden ya viene del backend via CompraClienteDTO)
/// 3. Filtro por categoría — filtra localmente sobre los datos recibidos
/// 4. Barra de progreso visual para cada producto
///
/// WIDGETS DE SALIDA UTILIZADOS:
/// - ListView.builder (lista de productos)
/// - GestureDetector (filtros de categoría)
/// - LinearProgressIndicator (barra de progreso por producto)
class ClientDetailPage extends StatefulWidget {
  /// Cliente recibido desde ClientPage con sus compras cargadas del backend
  final Map<String, dynamic> cliente;

  const ClientDetailPage({super.key, required this.cliente});

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage> {
  /// Categoría seleccionada para filtrar
  /// 'todos' muestra todos los productos
  String _categoriaSeleccionada = 'todos';

  /// Categorías disponibles con su etiqueta visible
  /// Los valores de key corresponden a los categoriaNombre del CompraClienteDTO
  final List<Map<String, String>> _categorias = [
    {'key': 'todos', 'label': 'Todos'},
    {'key': 'LECHE', 'label': 'Leche'},
    {'key': 'QUESO', 'label': 'Queso'},
    {'key': 'YOGUR', 'label': 'Yogur'},
    {'key': 'FLAN', 'label': 'Flan'},
    {'key': 'TARTA', 'label': 'Tarta'},
  ];

  /// Devuelve la lista de compras filtrada por categoría
  /// y ya ordenada de mayor a menor cantidad (el backend ya las ordena)
  List<Map<String, dynamic>> get _comprasFiltradas {
    final compras =
        List<Map<String, dynamic>>.from(widget.cliente['compras'] ?? []);

    if (_categoriaSeleccionada == 'todos') return compras;

    /// Filtra por categoriaNombre del CompraClienteDTO
    return compras
        .where((c) =>
            (c['categoriaNombre'] ?? '') == _categoriaSeleccionada)
        .toList();
  }

  /// Devuelve la cantidad máxima para calcular el porcentaje de la barra
  /// Usa cantidadTotal del CompraClienteDTO
  double get _cantidadMaxima {
    final compras =
        List<Map<String, dynamic>>.from(widget.cliente['compras'] ?? []);
    if (compras.isEmpty) return 1;
    return compras
        .map((c) => (c['cantidadTotal'] as num?)?.toDouble() ?? 0)
        .reduce((a, b) => a > b ? a : b);
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
                child: Image.asset(
                    'assets/masets_blanco.png', height: 140),
              ),
            ),
            const SizedBox(height: 20),

            // Nombre del cliente como título
            Center(
              child: Text(
                widget.cliente['nombre'] ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3B2A),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Email del cliente
            Center(
              child: Text(
                widget.cliente['email'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      const Color(0xFF4A3B2A).withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Filtros por categoría en fila horizontal deslizable
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _categorias.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final categoria = _categorias[index];
                  final seleccionada =
                      _categoriaSeleccionada == categoria['key'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _categoriaSeleccionada = categoria['key']!;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: seleccionada
                            ? const Color(0xFF4A3B2A)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF4A3B2A),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        categoria['label']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: seleccionada
                              ? Colors.white
                              : const Color(0xFF4A3B2A),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Lista de productos filtrados
            Expanded(
              child: _comprasFiltradas.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay compras en esta categoría',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF4A3B2A),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24),
                      itemCount: _comprasFiltradas.length,
                      itemBuilder: (context, index) {
                        return _buildProductoCard(
                          _comprasFiltradas[index],
                          index,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // TARJETA DE PRODUCTO
  /// Tarjeta de cada producto con nombre, cantidad y barra de progreso
  /// Los datos vienen del CompraClienteDTO del backend:
  /// - productoNombre: nombre del producto
  /// - categoriaNombre: categoría del producto
  /// - cantidadTotal: cantidad total comprada (num en Flutter)
  /// El índice 0 lleva una corona indicando que es el más comprado
  Widget _buildProductoCard(Map<String, dynamic> compra, int index) {
    final cantidad =
        (compra['cantidadTotal'] as num?)?.toDouble() ?? 0;
    final progreso =
        _cantidadMaxima > 0 ? cantidad / _cantidadMaxima : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: const Color(0xFF4A3B2A), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nombre del producto con corona si es el nº1 en "Todos"
                  Row(
                    children: [
                      if (index == 0 &&
                          _categoriaSeleccionada == 'todos') ...[
                        const Icon(
                          Icons.emoji_events,
                          size: 18,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        compra['productoNombre'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3B2A),
                        ),
                      ),
                    ],
                  ),
                  // Cantidad total comprada
                  Text(
                    '${cantidad.toStringAsFixed(0)} uds',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A3B2A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Barra de progreso proporcional al máximo
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progreso,
                  minHeight: 8,
                  backgroundColor: const Color(0xFF4A3B2A)
                      .withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF4A3B2A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BOTTOM NAVIGATION BAR
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF4A3B2A)),
      child: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.people_outline,
                isSelected: true, // Seguimos en sección Clientes
                onTap: () {
                  /// Vuelve a ClientPage
                  Navigator.pop(context);
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
                        builder: (context) =>
                            const NotificationPage()),
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
                        builder: (context) =>
                            const ConfigurationPage()),
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