import 'package:flutter/material.dart';
import 'password_verification.dart';

/// Pantalla de recuperación de contraseña (Paso 1)
/// El usuario introduce su correo para recibir un código de verificación
/// Primera etapa del proceso de recuperación de contraseña
class RememberPasswordPage extends StatelessWidget {
  const RememberPasswordPage({super.key});

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
                'RECUPERAR CONTRASEÑA',
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
                'Introduce tu correo electrónico y te enviaremos '
                'un código de verificación para cambiar tu contraseña.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4A3B2A),
                ),
              ),

              const SizedBox(height: 40),

              /// Campo email
              TextField(
                /// Configura el teclado para facilitar la entrada de emails
                /// Muestra @ y . en el teclado móvil
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
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

              const SizedBox(height: 100),

              /// Botón enviar
              ElevatedButton(
                onPressed: () {
                  /// Navega a la pantalla de verificación del código
                  /// El usuario recibirá un código en su email para continuar
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PasswordVerificationPage(),
                    ),
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
                  'Siguiente',
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
}
