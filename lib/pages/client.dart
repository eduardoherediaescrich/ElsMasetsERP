import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'report.dart';
import 'client_detail.dart';
import 'notification.dart';
import 'configuration.dart';
import '../services/client_service.dart';

/// Pantalla principal de Clientes
/// CARACTERÍSTICAS PRINCIPALES:
/// 1. Carga de clientes reales desde el backend via ClientService
/// 2. Para cada cliente carga sus compras via el endpoint /clientes/{id}/compras
/// 3. Buscador en tiempo real por nombre — filtra localmente
/// 4. Cada tarjeta muestra el cliente y sus 3 productos más comprados
/// 5. Al pulsar un cliente navega a ClientDetailPage con el histórico completo
/// 6. Indicador de carga mientras se obtienen los datos
///
/// WIDGETS DE SALIDA UTILIZADOS:
/// - ListView.builder (lista dinámica de clientes)
/// - Card/Material (tarjetas de cada cliente)
/// - TextField (buscador)
/// - CircularProgressIndicator (indicador de carga)
class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  /// Lista principal de clientes cargada desde el backend
  /// Cada elemento es un Map con los campos del ClienteDTO
  /// más el campo 'compras' añadido con los datos del endpoint /compras
  List<Map<String, dynamic>> clientes = [];

  /// Indica si los datos están siendo cargados desde el backend
  bool _cargando = true;

  /// Mensaje de error si la carga falla
  String? _error;

  /// Texto de búsqueda para filtrar clientes por nombre
  String _textoBusqueda = '';
  final TextEditingController _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    /// Carga los clientes y sus compras al iniciar la pantalla
    _cargarClientes();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  // CARGA DE DATOS DESDE EL BACKEND
  /// Carga todos los clientes activos y para cada uno carga sus compras
  /// Las compras vienen del endpoint /clientes/{id}/compras que devuelve
  /// los productos agrupados y ordenados de mayor a menor cantidad total
  Future<void> _cargarClientes() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final datosClientes = await ClientService.obtenerActivos();
      final listaClientes =
          List<Map<String, dynamic>>.from(datosClientes);

      /// Para cada cliente carga sus compras desde el backend
      for (final cliente in listaClientes) {
        try {
          final compras = await ClientService.obtenerComprasPorCliente(
              cliente['id']);
          cliente['compras'] =
              List<Map<String, dynamic>>.from(compras);
        } catch (e) {
          /// Si falla la carga de compras de un cliente usa lista vacía
          cliente['compras'] = [];
        }
      }

      setState(() {
        clientes = listaClientes;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los clientes. Comprueba la conexión.';
        _cargando = false;
      });
    }
  }

  /// Filtra la lista de clientes por nombre — filtro local
  List<Map<String, dynamic>> get _clientesFiltrados {
    if (_textoBusqueda.isEmpty) return clientes;
    return clientes.where((cliente) {
      return (cliente['nombre'] ?? '')
          .toLowerCase()
          .contains(_textoBusqueda.toLowerCase());
    }).toList();
  }

  /// Devuelve los 3 productos más comprados de un cliente
  /// Los datos ya vienen ordenados del backend, solo tomamos los 3 primeros
  List<Map<String, dynamic>> _top3Productos(
      List<Map<String, dynamic>> compras) {
    return compras.take(3).toList();
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

            // Título
            const Center(
              child: Text(
                'CLIENTES',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3B2A),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                elevation: 1,
                child: TextField(
                  controller: _busquedaController,
                  onChanged: (value) {
                    setState(() {
                      _textoBusqueda = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar cliente',
                    hintStyle: TextStyle(
                      color: const Color(0xFF4A3B2A)
                          .withValues(alpha: 0.5),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF4A3B2A),
                    ),
                    suffixIcon: _textoBusqueda.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Color(0xFF4A3B2A),
                            ),
                            onPressed: () {
                              setState(() {
                                _busquedaController.clear();
                                _textoBusqueda = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Color(0xFF4A3B2A)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Color(0xFF4A3B2A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF4A3B2A),
                        width: 2,
                      ),
                    ),
                  ),
                ),
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
                                onPressed: _cargarClientes,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF4A3B2A),
                                ),
                                child: const Text(
                                  'Reintentar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        )
                      /// Lista de clientes filtrados
                      : _clientesFiltrados.isEmpty
                          ? Center(
                              child: Text(
                                _textoBusqueda.isEmpty
                                    ? 'No hay clientes'
                                    : 'No se encontraron resultados para "$_textoBusqueda"',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF4A3B2A),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24),
                              itemCount: _clientesFiltrados.length,
                              itemBuilder: (context, index) {
                                final cliente =
                                    _clientesFiltrados[index];
                                return _buildClienteCard(cliente);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // TARJETA DE CLIENTE
  /// Tarjeta con nombre del cliente a la izquierda
  /// y sus 3 productos más comprados a la derecha
  /// Los datos de compras vienen del CompraClienteDTO del backend:
  /// - productoNombre: nombre del producto
  /// - cantidadTotal: cantidad total comprada (BigDecimal → num en Flutter)
  Widget _buildClienteCard(Map<String, dynamic> cliente) {
    final compras =
        List<Map<String, dynamic>>.from(cliente['compras'] ?? []);
    final top3 = _top3Productos(compras);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ClientDetailPage(cliente: cliente),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFF4A3B2A).withValues(alpha: 0.1),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF4A3B2A), width: 2),
            ),
            child: Row(
              children: [
                // Icono de persona
                const Icon(
                  Icons.account_circle_outlined,
                  size: 36,
                  color: Color(0xFF4A3B2A),
                ),
                const SizedBox(width: 12),

                // Nombre del cliente
                Expanded(
                  child: Text(
                    cliente['nombre'] ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A3B2A),
                    ),
                  ),
                ),

                // Top 3 productos más comprados
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: top3.isEmpty
                      ? [
                          Text(
                            'Sin compras',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF4A3B2A)
                                  .withValues(alpha: 0.5),
                            ),
                          )
                        ]
                      : top3.map((compra) {
                          final cantidad =
                              (compra['cantidadTotal'] as num?)
                                  ?.toStringAsFixed(0) ??
                                  '0';
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '${compra['productoNombre'] ?? ''}: $cantidad',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4A3B2A),
                              ),
                            ),
                          );
                        }).toList(),
                ),
              ],
            ),
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
                isSelected: true, // Estamos en Clientes → activo
                onTap: () {},
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