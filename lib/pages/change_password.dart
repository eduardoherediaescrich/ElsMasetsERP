import 'package:flutter/material.dart';
import 'login.dart';

/// Pantalla de cambio de contraseña (Paso 3 - Final)
/// Permite al usuario establecer una nueva contraseña
/// Última etapa del proceso de recuperación de contraseña
class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E9C9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EACF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromRGBO(74, 59, 42, 1),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Image.asset('assets/masets_blanco.png', height: 140),

              const SizedBox(height: 50),

              // Título
              const Text(
                'NUEVA CONTRASEÑA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3B2A),
                ),
              ),

              const SizedBox(height: 30),

              /// Descripción del proceso
              const Text(
                'Introduce tu nueva contraseña y confírmala para finalizar el proceso.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF4A3B2A)),
              ),

              const SizedBox(height: 40),

              /// Campos de contraseña
              _campoTexto('Nueva contraseña'),
              _campoTexto('Repetir contraseña'),

              const SizedBox(height: 50),

              /// Botón guardar
              ElevatedButton(
                onPressed: () {
                  /// Vuelve al login eliminando todo el historial de navegación
                  /// Usa pushAndRemoveUntil con (route) => false para limpiar la pila completa
                  /// Esto evita que el usuario pueda volver a las pantallas de recuperación
                  /// de contraseña usando el botón de atrás
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A3B2A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar contraseña',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget reutilizable para campos de contraseña
  /// Crea TextFields con el estilo corporativo y ocultación de texto
  /// label es el texto que aparece en el campo
  static Widget _campoTexto(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4A3B2A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4A3B2A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF4A3B2A),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}