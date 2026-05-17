import 'package:flutter/material.dart';
import 'configuration.dart';
import 'contact.dart';
import 'dashboard.dart';
import 'sale.dart';
import 'production_report.dart';
import 'client.dart';
import 'incident_report.dart';
import 'notification.dart';

/// Pantalla de Informes
/// CARACTERÍSTICAS PRINCIPALES:
/// 1. Grid 2x2 con accesos a los 4 tipos de informe
/// 2. Todos los botones navegan a su página correspondiente
///
/// WIDGETS DE SALIDA UTILIZADOS:
/// - GridView (grid 2x2 de tarjetas)
/// - Card/Material (tarjetas de cada informe)
/// - InkWell (interacción con las tarjetas)
class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

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
        child: SingleChildScrollView(
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
                'INFORMES',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3B2A),
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 30),

              // Grid 2x2 de tarjetas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                  shrinkWrap: true,
                  childAspectRatio: 1.8,
                  children: [
                    // PRODUCCIÓN
                    _buildInformeCard(
                      context: context,
                      title: 'PRODUCCIÓN',
                      icon: Icons.trending_up,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ProductionReportPage(),
                          ),
                        );
                      },
                    ),
                    // VENTAS
                    _buildInformeCard(
                      context: context,
                      title: 'VENTAS',
                      icon: Icons.attach_money,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SalePage(),
                          ),
                        );
                      },
                    ),
                    // CLIENTES
                    _buildInformeCard(
                      context: context,
                      title: 'CLIENTES',
                      icon: Icons.people_outline,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ClientPage(),
                          ),
                        );
                      },
                    ),
                    // INCIDENCIAS
                    _buildInformeCard(
                      context: context,
                      title: 'INCIDENCIAS',
                      icon: Icons.warning_amber_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const IncidentReportPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TARJETA DE INFORME
  /// Construye una tarjeta del grid de informes
  /// Diseño vertical: título arriba, icono en recuadro abajo
  Widget _buildInformeCard({
    required BuildContext context,
    required String title,
    required IconData icon,
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4A3B2A), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título encima del icono
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3B2A),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 16),
              // Icono dentro de un recuadro con borde
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color(0xFF4A3B2A), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(icon, size: 40, color: const Color(0xFF4A3B2A)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BOTTOM NAVIGATION BAR
  /// isSelected: true en bar_chart porque Informes es la sección activa
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
                isSelected: true,
                onTap: () {
                  // Ya estamos en Informes
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
  /// InkWell + Padding + Icon tamaño 28
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