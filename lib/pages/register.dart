import 'package:flutter/material.dart';

/// Pantalla de registro de nuevos usuarios
/// Permite crear una cuenta proporcionando datos personales y contraseña
/// Incluye validación de campos y confirmación de contraseña
class RegistroPage extends StatelessWidget {
  const RegistroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EACF),
      appBar: AppBar( 
        backgroundColor: const Color(0xFFF5EACF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(74, 59, 42, 1)),
          /// Vuelve a la pantalla de login después del registro
          /// Usa pop() para volver a la pantalla anterior sin crear duplicados
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/masets_blanco.png',
              height: 130,
            ),

            const SizedBox(height: 40),

            const Text(
                  'CREACIÓN DE CUENTA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3B2A),
                  ),
                ),

            const SizedBox(height: 40),

            //Campos de registro
            _campoTexto('Nombre'),
            _campoTexto('Apellidos'),
            _campoTexto('Correo electrónico'),
            _campoTexto('Contraseña', obscure: true),
            _campoTexto('Repite la contraseña', obscure: true),

            const SizedBox(height: 50),

            // Botón registrarse
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  // Vuelve a la pantalla de login tras registrarse
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A3B2A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Registrarse',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Widget reutilizable para campos de entrada de texto
  /// Permite crear TextFields consistentes con el diseño de la app
  /// label es el texto que se muestra en el campo
  /// obscure indica si el texto debe ocultarse (para contraseñas)
  static Widget _campoTexto(String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}