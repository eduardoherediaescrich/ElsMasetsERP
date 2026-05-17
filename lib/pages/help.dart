import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'contact.dart';
import 'report.dart';
import 'configuration.dart';
import 'notification.dart';

/// Pantalla de Ayuda
/// CARACTERÍSTICAS PRINCIPALES:
/// 1. Icono de bombilla en recuadro central
/// 2. Sección "Guía rápida" con accesos a Primeros pasos, Contacto y Segmentos
/// 3. Cada opción abre un diálogo con información de ayuda
///
/// WIDGETS DE SALIDA UTILIZADOS:
/// - Container (recuadro del icono)
/// - ListView (lista de opciones de ayuda)
/// - AlertDialog (contenido de cada sección)
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

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

      // Bottom bar al final
      bottomNavigationBar: _buildBottomNavigationBar(context),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  'AYUDA',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3B2A),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Icono de bombilla en recuadro
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4A3B2A),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    size: 60,
                    color: Color(0xFF4A3B2A),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Título "Guía rápida"
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Guía rápida',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3B2A),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Opciones de la guía
              _buildOpcionAyuda(
                context: context,
                titulo: 'Primeros pasos',
                contenido:
                    'Bienvenido a Els Masets ERP. Desde el Dashboard puedes acceder a todas las secciones: Producción, Stock, Incidencias, Contactos, Informes y Calendario. Usa la barra inferior para navegar rápidamente entre secciones.',
              ),
              _buildOpcionAyuda(
                context: context,
                titulo: 'Contacto',
                contenido:
                    'Si necesitas soporte técnico o tienes alguna duda, puedes contactar con el equipo de Els Masets a través de la sección de Contactos o enviando un correo a soporte@elsmasets.com.',
              ),
              _buildOpcionAyuda(
                context: context,
                titulo: 'Segmentos',
                contenido:
                    'Los segmentos te permiten organizar y filtrar la información por categorías. Puedes segmentar la producción por tipo de producto, el stock por categoría y los contactos por rol dentro de la empresa.',
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // OPCIÓN DE AYUDA
  /// Construye una fila de opción de ayuda
  /// Al pulsar abre un AlertDialog con el contenido de esa sección
  Widget _buildOpcionAyuda({
    required BuildContext context,
    required String titulo,
    required String contenido,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
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
              content: Text(
                contenido,
                style: const TextStyle(
                  color: Color(0xFF4A3B2A),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(
                      color: Color(0xFF4A3B2A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4A3B2A),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF4A3B2A),
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
                    MaterialPageRoute(
                      builder: (context) => const ReportPage(),
                    ),
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
                    MaterialPageRoute(builder: (context) => const NotificationPage()),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.settings_outlined,
                isSelected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ConfigurationPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NAV ITEM
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