import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dashboard.dart';
import 'contact.dart';
import 'report.dart';
import 'configuration.dart';
import 'notification.dart';
import '../services/incident_service.dart';

/// Informe de incidencias
/// CARACTERÍSTICAS PRINCIPALES:
/// 1. Carga de incidencias reales desde el backend via IncidentService
/// 2. Gráfico de líneas con número de incidencias por mes del año seleccionado
/// 3. Selector de año — solo muestra años con datos reales
/// 4. Por defecto selecciona el año más reciente con datos
/// 5. Tabla de datos mensuales con totales reales por mes
/// 6. Indicador de carga mientras se obtienen los datos
///
/// WIDGETS DE SALIDA UTILIZADOS:
/// - LineChart (gráfico de líneas fl_chart)
/// - ListView (tabla de datos mensuales)
/// - AlertDialog (selector de año)
/// - CircularProgressIndicator (indicador de carga)
class IncidentReportPage extends StatefulWidget {
  const IncidentReportPage({super.key});

  @override
  State<IncidentReportPage> createState() => _IncidentReportPageState();
}

class _IncidentReportPageState extends State<IncidentReportPage> {
  /// Lista de incidencias cargadas desde el backend
  List<Map<String, dynamic>> incidencias = [];

  bool _cargando = true;
  String? _error;

  int _anioSeleccionado = DateTime.now().year;

  final List<String> _mesesAbreviados = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  final List<String> _mesesCompletos = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    _cargarIncidencias();
  }

  Future<void> _cargarIncidencias() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final datos = await IncidentService.obtenerTodas();
      setState(() {
        incidencias = List<Map<String, dynamic>>.from(datos);
        final anios = _aniosDisponibles;
        if (anios.isNotEmpty) {
          _anioSeleccionado = anios.last;
        }
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar las incidencias. Comprueba la conexión.';
        _cargando = false;
      });
    }
  }

  /// Años con al menos una incidencia
  List<int> get _aniosDisponibles {
    final anios = incidencias
        .map((i) {
          try {
            return DateTime.parse(i['fechaReporte'] ?? '').year;
          } catch (_) {
            return null;
          }
        })
        .whereType<int>()
        .toSet()
        .toList()
      ..sort();
    return anios;
  }

  /// Número de incidencias por mes (1-12) para el año seleccionado
  List<int> get _incidenciasPorMes {
    final conteo = List<int>.filled(12, 0);
    for (final inc in incidencias) {
      try {
        final fecha = DateTime.parse(inc['fechaReporte'] ?? '');
        if (fecha.year == _anioSeleccionado) {
          conteo[fecha.month - 1]++;
        }
      } catch (_) {
        continue;
      }
    }
    return conteo;
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
        child: _cargando
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A3B2A)),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, style: const TextStyle(fontSize: 15, color: Color(0xFF4A3B2A)), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _cargarIncidencias,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A3B2A)),
                          child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Image.asset('assets/masets_blanco.png', height: 140)),
                        ),
                        const SizedBox(height: 20),
                        const Center(
                          child: Text(
                            'INFORME DE INCIDENCIAS',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A3B2A),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Gráfico
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
                                border: Border.all(color: const Color(0xFF4A3B2A), width: 2),
                              ),
                              child: _incidenciasPorMes.every((v) => v == 0)
                                  ? const Center(
                                      child: Text(
                                        'No hay incidencias para este año',
                                        style: TextStyle(color: Color(0xFF4A3B2A), fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : LineChart(_buildLineChartData()),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Selector año
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$_anioSeleccionado',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A3B2A)),
                              ),
                              ElevatedButton(
                                onPressed: _aniosDisponibles.isEmpty ? null : _mostrarSelectorAnio,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Elegir año', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Tabla mensual
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            elevation: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF4A3B2A), width: 2),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Color(0xFF4A3B2A), width: 1)),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Mes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF4A3B2A))),
                                        Text('Incidencias', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF4A3B2A))),
                                      ],
                                    ),
                                  ),
                                  ...List.generate(12, (index) {
                                    final total = _incidenciasPorMes[index];
                                    final esUltimo = index == 11;
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${_mesesCompletos[index]} $_anioSeleccionado',
                                                style: const TextStyle(fontSize: 14, color: Color(0xFF4A3B2A)),
                                              ),
                                              Text(
                                                total > 0 ? '$total' : '—',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: total > 0
                                                      ? const Color(0xFF4A3B2A)
                                                      : const Color(0xFF4A3B2A).withValues(alpha: 0.4),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!esUltimo) const Divider(height: 1, color: Color(0xFF4A3B2A), thickness: 0.2),
                                      ],
                                    );
                                  }),
                                  // Total anual
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: const BoxDecoration(
                                      border: Border(top: BorderSide(color: Color(0xFF4A3B2A), width: 1)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('TOTAL', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF4A3B2A))),
                                        Text(
                                          '${_incidenciasPorMes.reduce((a, b) => a + b)}',
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF4A3B2A)),
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
  LineChartData _buildLineChartData() {
    final datos = _incidenciasPorMes.map((e) => e.toDouble()).toList();
    final maxValor = datos.isEmpty ? 1.0 : datos.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);
    final intervalo = (maxValor / 5).clamp(1.0, double.infinity).ceilToDouble();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: intervalo,
        getDrawingHorizontalLine: (value) => FlLine(
          color: const Color(0xFF4A3B2A).withValues(alpha: 0.15),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xFF4A3B2A), width: 1),
          left: BorderSide(color: Color(0xFF4A3B2A), width: 1),
        ),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: (maxValor * 1.2).ceilToDouble(),
      titlesData: FlTitlesData(
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
                  style: const TextStyle(fontSize: 10, color: Color(0xFF4A3B2A)),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: intervalo,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              if (value == 0) {
                return const Text('0', style: TextStyle(fontSize: 10, color: Color(0xFF4A3B2A)));
              }
              return Text(
                '${value.toInt()}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF4A3B2A)),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(12, (index) => FlSpot(index.toDouble(), datos[index])),
          isCurved: true,
          color: const Color(0xFF4A3B2A),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: const Color(0xFF4A3B2A).withValues(alpha: 0.08)),
        ),
      ],
      clipData: const FlClipData.all(),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${_mesesAbreviados[spot.x.toInt()]}: ${spot.y.toInt()} incidencias',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  void _mostrarSelectorAnio() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elegir año', style: TextStyle(color: Color(0xFF4A3B2A), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _aniosDisponibles.map((anio) {
            return ListTile(
              title: Text('$anio', style: const TextStyle(color: Color(0xFF4A3B2A))),
              trailing: _anioSeleccionado == anio ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                setState(() => _anioSeleccionado = anio);
                Navigator.pop(context);
              },
            );
          }).toList(),
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
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactPage()));
              }),
              _buildNavItem(icon: Icons.bar_chart_outlined, isSelected: true, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportPage()));
              }),
              _buildNavItem(icon: Icons.home, isSelected: false, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
              }),
              _buildNavItem(icon: Icons.notifications_outlined, isSelected: false, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage()));
              }),
              _buildNavItem(icon: Icons.settings_outlined, isSelected: false, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigurationPage()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? const Color(0xFFF6E9C9) : const Color(0xFFF6E9C9).withValues(alpha: 0.5),
        ),
      ),
    );
  }
}