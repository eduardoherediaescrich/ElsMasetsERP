import 'package:flutter/material.dart';
import 'production.dart';

/// Pantalla principal del Dashboard
/// Muestra los módulos principales de la aplicación: Producción, Stock, Incidencias
/// y accesos rápidos a Contactos, Informes y Calendario
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

                const SizedBox(height: 100),

                // Tarjeta principal: PRODUCCIÓN
                _buildMainCard(
                  context: context,
                  title: 'PRODUCCIÓN',
                  icon: Icons.trending_up,
                  onTap: () {
                    /// Navega a la pantalla de gestión de producción
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductionPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Fila con STOCK e INCIDENCIAS
                Row(
                  children: [
                    // Tarjeta de Stock
                    Expanded(
                      child: _buildSecondaryCard(
                        context: context,
                        title: 'STOCK',
                        icon: Icons.inventory_2_outlined,
                        onTap: () {
                          // Próximamente navegará a la pantalla de Stock
                        },
                      ),
                    ),

                    const SizedBox(width: 50),

                    // Tarjeta de Incidencias
                    Expanded(
                      child: _buildSecondaryCard(
                        context: context,
                        title: 'INCIDENCIAS',
                        icon: Icons.warning_amber_outlined,
                        onTap: () {
                          // Próximamente navegará a la pantalla de Incidencias
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 90),

                // Fila con tarjetas más pequeñas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSmallCard(
                      context: context,
                      title: 'CONTACTOS',
                      icon: Icons.people_outline,
                      onTap: () {
                        // Próximamente navegará a Contactos
                      },
                    ),
                    _buildSmallCard(
                      context: context,
                      title: 'INFORMES',
                      icon: Icons.bar_chart_outlined,
                      onTap: () {
                        // Próximamente navegará a Informes
                      },
                    ),
                    _buildSmallCard(
                      context: context,
                      title: 'CALENDARIO',
                      icon: Icons.calendar_today_outlined,
                      onTap: () {
                        // Próximamente navegará a Calendario
                      },
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

  /// Construye la barra de navegación inferior
  /// Contiene 5 iconos: Contactos, Informes, Home, Notificaciones y Configuración
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF4A3B2A)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Icono de Contactos
              _buildNavItem(
                icon: Icons.people_outline,
                isSelected: false,
                onTap: () {
                  // Próximamente navegará a Contactos
                },
              ),
              // Icono de Informes
              _buildNavItem(
                icon: Icons.bar_chart_outlined,
                isSelected: false,
                onTap: () {
                  // Próximamente navegará a Informes
                },
              ),
              // Icono de Home
              _buildNavItem(
                icon: Icons.home,
                isSelected: true,
                onTap: () {
                  // Ya estamos en Home
                },
              ),
              // Icono de Notificaciones
              _buildNavItem(
                icon: Icons.notifications_outlined,
                isSelected: false,
                onTap: () {
                  // Próximamente navegará a Notificaciones
                },
              ),
              // Icono de Configuración
              _buildNavItem(
                icon: Icons.settings_outlined,
                isSelected: false,
                onTap: () {
                  // Próximamente navegará a Configuración
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye cada icono de la barra de navegación
  /// El color cambia según si está seleccionado o no
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
          // Si está seleccionado, color beige completo; si no, semi-transparente
          color: isSelected
              ? const Color(0xFFF6E9C9)
              : const Color(0xFFF6E9C9).withValues(alpha: 0.5),
        ),
      ),
    );
  }

  /// Construye la tarjeta principal (PRODUCCIÓN)
  /// Es más grande y tiene un diseño horizontal con el título a la izquierda
  /// y el icono a la derecha dentro de un contenedor
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
              // Icono a la derecha dentro de un contenedor
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
                  child: Icon(icon, size: 44, color: const Color(0xFF4A3B2A)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye las tarjetas secundarias (STOCK e INCIDENCIAS)
  /// Son cuadradas y tienen un diseño vertical con el icono arriba y el título abajo
  Widget _buildSecondaryCard({
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono grande en el centro
              Icon(icon, size: 50, color: const Color(0xFF4A3B2A)),
              const SizedBox(height: 12),
              // Título debajo del icono
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3B2A),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye las tarjetas pequeñas (Contactos, Informes, Calendario)
  /// Son más pequeñas que las secundarias pero mantienen el mismo estilo vertical
  Widget _buildSmallCard({
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
          width: 100,
          height: 85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4A3B2A), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono más pequeño
              Icon(icon, size: 32, color: const Color(0xFF4A3B2A)),
              const SizedBox(height: 6),
              // Título con fuente más pequeña
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A3B2A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
