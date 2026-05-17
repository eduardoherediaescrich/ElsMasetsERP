import 'package:flutter/material.dart';
import 'production.dart';
import 'stock.dart';
import 'report.dart';
import 'calendar.dart';
import 'contact.dart';
import 'configuration.dart';
import 'incident.dart';
import 'notification.dart';
import '../services/auth_service.dart';

/// Pantalla principal del Dashboard
/// Muestra los módulos principales de la aplicación: Producción, Stock, Incidencias
/// y accesos rápidos a Contactos, Informes y Calendario
/// El saludo usa el nombre real del usuario logueado via AuthService
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E9C9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo
                Image.asset('assets/masets_blanco.png', height: 140),

                const SizedBox(height: 40),

                /// Saludo con el nombre real del usuario logueado
                /// AuthService.usuarioNombre se establece al hacer login
                Center(
                  child: Text(
                    'HOLA ${(AuthService.usuarioNombre ?? 'USUARIO').toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3B2A),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Fila 1: Producción - Stock
                Row(
                  children: [
                    Expanded(
                      child: _buildMainCard(
                        context: context,
                        title: 'PRODUCCIÓN',
                        icon: Icons.trending_up,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProductionPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildMainCard(
                        context: context,
                        title: 'STOCK',
                        icon: Icons.inventory_2_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StockPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Fila 2: Incidencias - Informes
                Row(
                  children: [
                    Expanded(
                      child: _buildMainCard(
                        context: context,
                        title: 'INCIDENCIAS',
                        icon: Icons.warning_amber_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const IncidentPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildMainCard(
                        context: context,
                        title: 'INFORMES',
                        icon: Icons.bar_chart_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReportPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Fila 3: Calendario - Contactos
                Row(
                  children: [
                    Expanded(
                      child: _buildMainCard(
                        context: context,
                        title: 'CALENDARIO',
                        icon: Icons.calendar_today_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CalendarPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildMainCard(
                        context: context,
                        title: 'CONTACTOS',
                        icon: Icons.people_outline,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ContactPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),

      // Barra de navegación inferior
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  /// Construye cada tarjeta del dashboard
  /// Diseño horizontal: título a la izquierda, icono en recuadro a la derecha
  Widget _buildMainCard({
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
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4A3B2A), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Título a la izquierda
              Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3B2A),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Icono a la derecha dentro de un contenedor con borde
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF4A3B2A),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      Icon(icon, size: 44, color: const Color(0xFF4A3B2A)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la barra de navegación inferior
  /// Home está marcado como activo ya que estamos en el Dashboard
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
                isSelected: true, // Estamos en Home → activo
                onTap: () {
                  // Ya estamos en Home
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

  /// Construye cada icono de la barra de navegación
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