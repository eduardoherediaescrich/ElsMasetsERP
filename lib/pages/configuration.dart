import 'package:flutter/material.dart';
import 'help.dart';
import 'dashboard.dart';
import 'report.dart';
import 'contact.dart';
import 'notification.dart';
import 'login.dart';
import '../services/auth_service.dart';

/// Pantalla de Configuración
/// CARACTERÍSTICAS PRINCIPALES:
/// 1. Datos personales del usuario logueado — leídos desde AuthService
/// 2. Botón de cerrar sesión — limpia el token y navega al Login
/// 3. Ajustes: idioma, tema y notificaciones
/// 4. Soporte: acceso a Ayuda y Aviso legal
///
/// WIDGETS DE ENTRADA UTILIZADOS:
/// - Switch (notificaciones)
///
/// WIDGETS DE SALIDA UTILIZADOS:
/// - Text (nombre, rol, secciones)
/// - ElevatedButton (cerrar sesión)
/// - ListTile (opciones de ajustes y soporte)
/// - Switch (toggle de notificaciones)
class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  @override
  State<ConfigurationPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfigurationPage> {
  /// Estado del toggle de notificaciones
  bool _notificacionesActivadas = true;

  /// Idioma seleccionado actualmente
  String _idiomaSeleccionado = 'Español';

  /// Tema seleccionado actualmente
  String _temaSeleccionado = 'Claro';

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

      // Bottom bar
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
                  'CONFIGURACIÓN',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3B2A),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Datos personales
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Datos personales',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A3B2A).withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              /// Nombre del usuario logueado — leído desde AuthService
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  AuthService.usuarioNombre ?? 'Usuario',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3B2A),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              /// Email del usuario logueado — leído desde AuthService
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  AuthService.usuarioEmail ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF4A3B2A).withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              /// Rol del usuario logueado — leído desde AuthService
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  AuthService.usuarioRol ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF4A3B2A),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Botón cerrar sesión
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      _confirmarCerrarSesion(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Ajustes
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Ajustes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3B2A),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Contenedor de ajustes
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
                        // Idioma
                        _buildAjusteFlecha(
                          titulo: 'Idioma',
                          valor: _idiomaSeleccionado,
                          onTap: () => _mostrarSelectorIdioma(context),
                          mostrarDivisor: true,
                        ),
                        // Tema
                        _buildAjusteFlecha(
                          titulo: 'Tema',
                          valor: _temaSeleccionado,
                          onTap: () => _mostrarSelectorTema(context),
                          mostrarDivisor: true,
                        ),
                        // Notificaciones con toggle
                        _buildAjusteToggle(
                          titulo: 'Notificaciones',
                          valor: _notificacionesActivadas,
                          onChanged: (value) {
                            setState(() {
                              _notificacionesActivadas = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Soporte
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Soporte',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3B2A),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Contenedor de soporte
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
                        // Ayuda
                        _buildAjusteFlecha(
                          titulo: 'Ayuda',
                          valor: '',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpPage(),
                              ),
                            );
                          },
                          mostrarDivisor: true,
                        ),
                        // Aviso legal
                        _buildAjusteFlecha(
                          titulo: 'Aviso legal',
                          valor: '',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(
                                  'Aviso legal',
                                  style: TextStyle(
                                    color: Color(0xFF4A3B2A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: const Text(
                                  'Els Masets ERP es una aplicación de gestión interna. '
                                  'Toda la información contenida en esta aplicación es confidencial y de uso exclusivo para el personal autorizado de Els Masets. '
                                  'Queda prohibida su reproducción, distribución o comunicación pública sin autorización expresa. '
                                  'El uso indebido de esta aplicación puede conllevar responsabilidades legales.',
                                  style: TextStyle(
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
                          mostrarDivisor: false,
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

  // WIDGETS DE AJUSTES
  /// Fila de ajuste con valor de texto y flecha a la derecha
  Widget _buildAjusteFlecha({
    required String titulo,
    required String valor,
    required VoidCallback onTap,
    required bool mostrarDivisor,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: mostrarDivisor
              ? BorderRadius.zero
              : const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF4A3B2A),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '$valor >',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF4A3B2A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (mostrarDivisor)
          const Divider(
              height: 1, color: Color(0xFF4A3B2A), thickness: 0.3),
      ],
    );
  }

  /// Fila de ajuste con toggle (Switch) a la derecha
  Widget _buildAjusteToggle({
    required String titulo,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style:
                const TextStyle(fontSize: 15, color: Color(0xFF4A3B2A)),
          ),
          Switch(
            value: valor,
            onChanged: onChanged,
            activeThumbColor: Colors.green,
          ),
        ],
      ),
    );
  }

  // DIÁLOGOS
  /// Confirmación antes de cerrar sesión
  /// Al confirmar llama a AuthService.logout() para limpiar el token
  /// y navega a LoginPage eliminando toda la pila de navegación
  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '¿Cerrar sesión?',
          style: TextStyle(
            color: Color(0xFF4A3B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que deseas cerrar la sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF4A3B2A)),
            ),
          ),
          TextButton(
            onPressed: () {
              /// Limpia el token JWT y los datos del usuario
              AuthService.logout();

              /// Navega a LoginPage eliminando toda la pila de navegación
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Selector de idioma
  void _mostrarSelectorIdioma(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Idioma',
          style: TextStyle(
            color: Color(0xFF4A3B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Español', 'Valencià', 'English'].map((idioma) {
            return ListTile(
              title: Text(idioma),
              trailing: _idiomaSeleccionado == idioma
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  _idiomaSeleccionado = idioma;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Selector de tema
  void _mostrarSelectorTema(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Tema',
          style: TextStyle(
            color: Color(0xFF4A3B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Claro', 'Oscuro'].map((tema) {
            return ListTile(
              title: Text(tema),
              trailing: _temaSeleccionado == tema
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  _temaSeleccionado = tema;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
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
                        builder: (context) =>
                            const NotificationPage()),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.settings_outlined,
                isSelected: true,
                onTap: () {
                  // Ya estamos en Configuración
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