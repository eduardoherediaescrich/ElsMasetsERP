import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dashboard.dart';
import 'contact.dart';
import 'report.dart';
import 'configuration.dart';
import 'notification.dart';
import '../services/sale_service.dart';

/// Pantalla de Informe de Ventas
/// CARACTERÍSTICAS PRINCIPALES:
/// 1. Carga de ventas reales desde el backend via SaleService
/// 2. Gráfico de líneas con ventas mensuales del año seleccionado
///    calculado a partir de los datos reales de la base de datos
/// 3. Selector de año — filtra localmente sobre los datos cargados
/// 4. Tabla de datos mensuales con totales reales por mes
/// 5. Indicador de carga mientras se obtienen los datos
///
/// WIDGETS DE SALIDA UTILIZADOS:
/// - LineChart (gráfico de líneas fl_chart)
/// - ListView (tabla de datos mensuales)
/// - AlertDialog (selector de año)
/// - CircularProgressIndicator (indicador de carga)
class SalePage extends StatefulWidget {
  const SalePage({super.key});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  /// Lista de ventas cargadas desde el backend
  /// Cada elemento es un Map con los campos del VentaDTO
  List<Map<String, dynamic>> ventas = [];

  /// Indica si los datos están siendo cargados desde el backend
  bool _cargando = true;

  /// Mensaje de error si la carga falla
  String? _error;

  /// Año seleccionado actualmente para filtrar el gráfico y la tabla
  int _anioSeleccionado = DateTime.now().year;

  /// Nombres de los meses abreviados para el eje X del gráfico
  final List<String> _mesesAbreviados = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

  /// Nombres de los meses completos para la tabla
  final List<String> _mesesCompletos = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  void initState() {
    super.initState();

    /// Carga todas las ventas al iniciar la pantalla
    _cargarVentas();
  }

  // ─────────────────────────────────────────────
  // CARGA DE DATOS DESDE EL BACKEND
  // ─────────────────────────────────────────────

  /// Llama al SaleService para obtener todas las ventas
  /// Actualiza el estado con los datos recibidos o muestra un error
  Future<void> _cargarVentas() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final datos = await SaleService.obtenerTodas();
      setState(() {
        /// Convierte la lista dinámica a List<Map<String, dynamic>>
        ventas = List<Map<String, dynamic>>.from(datos);

        /// Establece el año seleccionado al año más reciente con datos
        final anios = _aniosDisponibles;
        if (anios.isNotEmpty && !anios.contains(_anioSeleccionado)) {
          _anioSeleccionado = anios.last;
        }

        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar las ventas. Comprueba la conexión.';
        _cargando = false;
      });
    }
  }

  /// Devuelve la lista de años disponibles en los datos cargados
  /// Extrae el año de la fechaVenta de cada venta y elimina duplicados
  List<int> get _aniosDisponibles {
    final anios =
        ventas
            .map((v) {
              try {
                return DateTime.parse(v['fechaVenta'] ?? '').year;
              } catch (e) {
                return null;
              }
            })
            .whereType<int>()
            .toSet()
            .toList()
          ..sort();
    return anios;
  }

  /// Calcula los totales de ventas por mes para el año seleccionado
  /// Agrupa las ventas por mes y suma el campo 'total' de cada una
  /// Devuelve una lista de 12 valores (uno por mes, 0 si no hay ventas)
  List<double> get _datosActuales {
    final totalesPorMes = List<double>.filled(12, 0);

    for (final venta in ventas) {
      try {
        final fecha = DateTime.parse(venta['fechaVenta'] ?? '');
        if (fecha.year == _anioSeleccionado) {
          /// Suma el total de la venta al mes correspondiente (mes - 1 para índice 0-based)
          totalesPorMes[fecha.month - 1] +=
              (venta['total'] as num?)?.toDouble() ?? 0;
        }
      } catch (e) {
        continue;
      }
    }

    return totalesPorMes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E9C9),

      // AppBar con flecha de volver
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
        child: _cargando
            /// Indicador de carga mientras se obtienen los datos del backend
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A3B2A)),
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
                      onPressed: _cargarVentas,
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
            /// Contenido principal con gráfico y tabla
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Logo
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Image.asset(
                          'assets/masets_blanco.png',
                          height: 140,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Título
                    const Center(
                      child: Text(
                        'INFORME DE VENTAS',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3B2A),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Gráfico de líneas con datos reales del backend
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 2,
                        child: Container(
                          height: 220,
                          padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF4A3B2A),
                              width: 2,
                            ),
                          ),
                          child: _datosActuales.every((v) => v == 0)
                              /// Si no hay datos para el año seleccionado
                              ? const Center(
                                  child: Text(
                                    'No hay datos de ventas para este año',
                                    style: TextStyle(
                                      color: Color(0xFF4A3B2A),
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : LineChart(_buildLineChartData()),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Fila: año seleccionado + botón elegir año
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Año seleccionado
                          Text(
                            '$_anioSeleccionado',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A3B2A),
                            ),
                          ),
                          // Botón elegir año
                          ElevatedButton(
                            onPressed: _aniosDisponibles.isEmpty
                                ? null
                                : _mostrarSelectorAnio,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Elegir año',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tabla de datos mensuales con totales reales
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF4A3B2A),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Cabecera de la tabla
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xFF4A3B2A),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Fecha',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4A3B2A),
                                      ),
                                    ),
                                    Text(
                                      'Total ventas (€)',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4A3B2A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Filas de datos — una por cada mes
                              ...List.generate(12, (index) {
                                final esUltimo = index == 11;
                                final totalMes = _datosActuales[index];
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${_mesesCompletos[index]} $_anioSeleccionado',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF4A3B2A),
                                            ),
                                          ),

                                          /// Muestra el total formateado o "—" si no hay ventas ese mes
                                          Text(
                                            totalMes > 0
                                                ? '${_formatearNumero(totalMes.toInt())}€'
                                                : '—',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: totalMes > 0
                                                  ? const Color(0xFF4A3B2A)
                                                  : const Color(
                                                      0xFF4A3B2A,
                                                    ).withValues(alpha: 0.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!esUltimo)
                                      const Divider(
                                        height: 1,
                                        color: Color(0xFF4A3B2A),
                                        thickness: 0.2,
                                      ),
                                  ],
                                );
                              }),

                              /// Fila de total anual al final de la tabla
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Color(0xFF4A3B2A),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'TOTAL',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4A3B2A),
                                      ),
                                    ),
                                    Text(
                                      '${_formatearNumero(_datosActuales.fold(0.0, (a, b) => a + b).toInt())}€',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4A3B2A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  // GRÁFICO
  /// Construye los datos del gráfico de líneas con los totales reales
  LineChartData _buildLineChartData() {
    final datos = _datosActuales;
    final maxValor = datos.isEmpty
        ? 1.0
        : datos.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);
    final intervalo = (maxValor / 5).clamp(1.0, double.infinity).ceilToDouble();

    return LineChartData(
      // Cuadrícula horizontal
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: intervalo,
        getDrawingHorizontalLine: (value) => FlLine(
          color: const Color(0xFF4A3B2A).withValues(alpha: 0.15),
          strokeWidth: 1,
        ),
      ),

      // Bordes del gráfico
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xFF4A3B2A), width: 1),
          left: BorderSide(color: Color(0xFF4A3B2A), width: 1),
        ),
      ),

      // Rango de ejes
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: (maxValor * 1.2).ceilToDouble(),

      // Etiquetas de los ejes
      titlesData: FlTitlesData(
        // Eje X: meses abreviados — solo los pares para no saturar
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index % 2 != 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${_mesesAbreviados[index]} ${_anioSeleccionado.toString().substring(2)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF4A3B2A),
                  ),
                ),
              );
            },
          ),
        ),
        // Eje Y: valores formateados
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: intervalo,
            reservedSize: 52,
            getTitlesWidget: (value, meta) {
              if (value == 0) {
                return const Text(
                  '0',
                  style: TextStyle(fontSize: 10, color: Color(0xFF4A3B2A)),
                );
              }
              return Text(
                _formatearNumero(value.toInt()),
                style: const TextStyle(fontSize: 10, color: Color(0xFF4A3B2A)),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),

      // Línea del gráfico con los datos reales
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            12,
            (index) => FlSpot(index.toDouble(), datos[index]),
          ),
          isCurved: true,
          color: const Color(0xFF4A3B2A),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF4A3B2A).withValues(alpha: 0.08),
          ),
        ),
      ],
      clipData: const FlClipData.all(),

      // Tooltip al pulsar un punto: muestra mes y total
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${_mesesAbreviados[spot.x.toInt()]}: ${_formatearNumero(spot.y.toInt())}€',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  // SELECTOR DE AÑO
  /// Muestra un diálogo para seleccionar el año
  /// Solo muestra los años que tienen ventas en la base de datos
  void _mostrarSelectorAnio() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Elegir año',
          style: TextStyle(
            color: Color(0xFF4A3B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _aniosDisponibles.map((anio) {
            return ListTile(
              title: Text(
                '$anio',
                style: const TextStyle(color: Color(0xFF4A3B2A)),
              ),
              trailing: _anioSeleccionado == anio
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  _anioSeleccionado = anio;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
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

  // HELPER
  /// Formatea un número con punto de miles: 10000 → 10.000
  String _formatearNumero(int numero) {
    final string = numero.toString();
    final buffer = StringBuffer();
    final offset = string.length % 3;
    for (int i = 0; i < string.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buffer.write('.');
      buffer.write(string[i]);
    }
    return buffer.toString();
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
                isSelected: true, // Ventas es sección de Informes → activo
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
