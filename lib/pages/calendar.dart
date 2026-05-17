import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'production.dart';
import 'stock.dart';
import 'dashboard.dart';
import 'configuration.dart';
import 'contact.dart';
import 'notification.dart';
import 'report.dart';
import 'incident.dart';
import '../services/event_service.dart';

/// Pantalla de Calendario
/// CARACTERÍSTICAS PRINCIPALES:
/// 1. Carga de eventos reales desde el backend via EventService
/// 2. Calendario mensual con marcadores visuales en días que tienen eventos
/// 3. Al seleccionar un día muestra los eventos de ese día debajo del calendario
/// 4. Accesos rápidos con comportamiento diferenciado:
///    - Producción → navega filtrando por el día seleccionado
///    - Incidencias → navega filtrando por el mes seleccionado
///    - Stock → navega al stock actual (no hay historial disponible)
/// 5. Indicador de carga mientras se obtienen los datos
///
/// WIDGETS DE SALIDA UTILIZADOS:
/// - TableCalendar (calendario mensual interactivo con marcadores)
/// - Card/Material (tarjetas de eventos del día)
/// - CircularProgressIndicator (indicador de carga)
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  /// Día actualmente seleccionado en el calendario
  /// Por defecto es hoy
  DateTime _selectedDay = DateTime.now();

  /// Día enfocado (mes visible) en el calendario
  DateTime _focusedDay = DateTime.now();

  /// Lista de eventos cargados desde el backend
  /// Cada elemento es un Map con los campos del EventoCalendarioDTO
  List<Map<String, dynamic>> eventos = [];

  /// Indica si los datos están siendo cargados desde el backend
  bool _cargando = true;

  /// Mensaje de error si la carga falla
  String? _error;

  @override
  void initState() {
    super.initState();
    /// Carga los eventos al iniciar la pantalla
    _cargarEventos();
  }

  // CARGA DE DATOS DESDE EL BACKEND
  /// Llama al EventService para obtener todos los eventos
  /// Actualiza el estado con los datos recibidos o muestra un error
  Future<void> _cargarEventos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final datos = await EventService.obtenerTodos();
      setState(() {
        eventos = List<Map<String, dynamic>>.from(datos);
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los eventos. Comprueba la conexión.';
        _cargando = false;
      });
    }
  }

  /// Devuelve los eventos del día seleccionado
  List<Map<String, dynamic>> _eventosDelDia(DateTime dia) {
    return eventos.where((evento) {
      try {
        final fechaEvento = DateTime.parse(evento['fechaEvento'] ?? '');
        return fechaEvento.year == dia.year &&
            fechaEvento.month == dia.month &&
            fechaEvento.day == dia.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// Devuelve true si un día tiene al menos un evento
  bool _tieneEventos(DateTime dia) => _eventosDelDia(dia).isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final eventosHoy = _eventosDelDia(_selectedDay);

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
                        Text(
                          _error!,
                          style: const TextStyle(
                              fontSize: 15, color: Color(0xFF4A3B2A)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _cargarEventos,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A3B2A)),
                          child: const Text('Reintentar',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Image.asset('assets/masets_blanco.png',
                                height: 140),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Título
                        const Center(
                          child: Text(
                            'CALENDARIO',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A3B2A),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Calendario + accesos rápidos
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Calendario mensual
                              Expanded(
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  elevation: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFF4A3B2A),
                                          width: 2),
                                    ),
                                    child: TableCalendar(
                                      firstDay: DateTime(2020),
                                      lastDay: DateTime(2030),
                                      focusedDay: _focusedDay,
                                      selectedDayPredicate: (day) =>
                                          isSameDay(_selectedDay, day),
                                      onDaySelected:
                                          (selectedDay, focusedDay) {
                                        setState(() {
                                          _selectedDay = selectedDay;
                                          _focusedDay = focusedDay;
                                        });
                                      },
                                      onPageChanged: (focusedDay) {
                                        _focusedDay = focusedDay;
                                      },
                                      calendarFormat: CalendarFormat.month,
                                      availableCalendarFormats: const {
                                        CalendarFormat.month: 'Mes',
                                      },
                                      locale: 'es_ES',
                                      startingDayOfWeek:
                                          StartingDayOfWeek.monday,
                                      calendarBuilders: CalendarBuilders(
                                        markerBuilder: (context, day, _) {
                                          if (_tieneEventos(day)) {
                                            return Positioned(
                                              bottom: 1,
                                              child: Container(
                                                width: 6,
                                                height: 6,
                                                decoration:
                                                    const BoxDecoration(
                                                  color: Color(0xFF4A3B2A),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            );
                                          }
                                          return null;
                                        },
                                      ),
                                      calendarStyle: CalendarStyle(
                                        selectedDecoration:
                                            const BoxDecoration(
                                          color: Color(0xFF4A3B2A),
                                          shape: BoxShape.circle,
                                        ),
                                        selectedTextStyle:
                                            const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        todayDecoration: BoxDecoration(
                                          color: const Color(0xFF4A3B2A)
                                              .withValues(alpha: 0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        todayTextStyle: const TextStyle(
                                          color: Color(0xFF4A3B2A),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        defaultTextStyle: const TextStyle(
                                            color: Color(0xFF4A3B2A)),
                                        weekendTextStyle: const TextStyle(
                                            color: Color(0xFF4A3B2A)),
                                        outsideTextStyle: TextStyle(
                                          color: const Color(0xFF4A3B2A)
                                              .withValues(alpha: 0.4),
                                        ),
                                        cellMargin:
                                            const EdgeInsets.all(2),
                                      ),
                                      headerStyle: const HeaderStyle(
                                        formatButtonVisible: false,
                                        titleCentered: true,
                                        titleTextStyle: TextStyle(
                                          color: Color(0xFF4A3B2A),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        leftChevronIcon: Icon(
                                          Icons.chevron_left,
                                          color: Color(0xFF4A3B2A),
                                          size: 20,
                                        ),
                                        rightChevronIcon: Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFF4A3B2A),
                                          size: 20,
                                        ),
                                        headerPadding: EdgeInsets.symmetric(
                                            vertical: 6),
                                      ),
                                      daysOfWeekStyle:
                                          const DaysOfWeekStyle(
                                        weekdayStyle: TextStyle(
                                          color: Color(0xFF4A3B2A),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                        weekendStyle: TextStyle(
                                          color: Color(0xFF4A3B2A),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                      rowHeight: 37,
                                      daysOfWeekHeight: 20,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Columna de accesos rápidos
                              Column(
                                children: [
                                  /// Stock: navega al stock actual
                                  /// No hay historial disponible, se muestra el estado actual
                                  _buildAccesoRapido(
                                    title: 'Stock',
                                    icon: Icons.inventory_2_outlined,
                                    subtitulo: 'Actual',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const StockPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  /// Incidencias: filtra por el mes del día seleccionado
                                  _buildAccesoRapido(
                                    title: 'Incidencias',
                                    icon: Icons.warning_amber_outlined,
                                    subtitulo: _formatearMesCorto(
                                        _selectedDay),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => IncidentPage(
                                            mesInicial: _selectedDay,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  /// Producción: abre en el día exacto seleccionado
                                  _buildAccesoRapido(
                                    title: 'Producción',
                                    icon: Icons.trending_up,
                                    subtitulo: _formatearMesCorto(_selectedDay),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductionPage(
                                            fechaInicial: _selectedDay,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Leyenda de los accesos rápidos
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            elevation: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF4A3B2A)
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: const Color(0xFF4A3B2A)
                                        .withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Producción filtra por día · Incidencias filtra por mes · Stock muestra el estado actual',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: const Color(0xFF4A3B2A)
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Fecha seleccionada
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Día seleccionado: ${_formatearFecha(_selectedDay)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A3B2A),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Eventos del día seleccionado
                        if (eventosHoy.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'No hay eventos para este día',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF4A3B2A)),
                            ),
                          )
                        else
                          ...eventosHoy
                              .map((evento) => _buildEventoCard(evento)),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
      ),
    );
  }

  // TARJETA DE EVENTO
  /// Construye una tarjeta para cada evento del día seleccionado
  Widget _buildEventoCard(Map<String, dynamic> evento) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4A3B2A), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF4A3B2A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTipoEventoIcon(evento['tipoNombre'] ?? ''),
                  color: const Color(0xFF4A3B2A),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evento['titulo'] ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A3B2A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      evento['tipoNombre'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF4A3B2A)
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if ((evento['horaInicio'] ?? '').isNotEmpty)
                    Text(
                      (evento['horaInicio'] as String).length >= 5
                          ? (evento['horaInicio'] as String)
                              .substring(0, 5)
                          : evento['horaInicio'] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A3B2A),
                      ),
                    ),
                  if ((evento['horaFin'] ?? '').isNotEmpty)
                    Text(
                      (evento['horaFin'] as String).length >= 5
                          ? (evento['horaFin'] as String).substring(0, 5)
                          : evento['horaFin'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF4A3B2A)
                            .withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BOTÓN DE ACCESO RÁPIDO
  /// Construye un botón de acceso rápido con icono, título y subtítulo
  /// El subtítulo indica el filtro que se aplicará al navegar:
  /// - Stock: "Actual" (sin filtro histórico)
  /// - Incidencias: mes abreviado del día seleccionado (ej: "Abr 26")
  /// - Producción: día/mes del día seleccionado (ej: "13/4")
  Widget _buildAccesoRapido({
    required String title,
    required IconData icon,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0xFF4A3B2A).withValues(alpha: 0.1),
        child: Container(
          width: 100,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4A3B2A), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: const Color(0xFF4A3B2A)),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A3B2A),
                ),
              ),
              const SizedBox(height: 2),
              /// Subtítulo que indica el filtro aplicado
              Text(
                subtitulo,
                style: TextStyle(
                  fontSize: 10,
                  color: const Color(0xFF4A3B2A).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HELPERS
  /// Retorna el icono según el tipo de evento del backend
  IconData _getTipoEventoIcon(String tipo) {
    switch (tipo) {
      case 'PRODUCCION':
        return Icons.trending_up;
      case 'REUNION':
        return Icons.people_outline;
      case 'MANTENIMIENTO':
        return Icons.build_outlined;
      case 'ENTREGA':
        return Icons.local_shipping_outlined;
      case 'FORMACION':
        return Icons.school_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  /// Formatea una fecha DateTime al formato español completo
  /// Salida: "13 de abril de 2026"
  String _formatearFecha(DateTime fecha) {
    final meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }

  /// Formatea una fecha al mes abreviado para el subtítulo del acceso rápido
  /// Salida: "Abr 26"
  String _formatearMesCorto(DateTime fecha) {
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${meses[fecha.month - 1]} ${fecha.year.toString().substring(2)}';
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