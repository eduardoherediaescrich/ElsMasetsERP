import 'package:elsmasets_flutter/pages/change_password.dart';
import 'package:flutter/material.dart';

class PasswordVerificationPage extends StatelessWidget {
  const PasswordVerificationPage({super.key});
  /// Pantalla de verificación de código (Paso 2)
  /// El usuario introduce el código recibido por email
  /// Segunda etapa del proceso de recuperación de contraseña
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
              /// Logo
              Image.asset(
                'assets/masets_blanco.png',
                height: 140,
              ),

              const SizedBox(height: 50),

              /// Título
              const Text(
                'VERIFICACIÓN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3B2A),
                ),
              ),

              const SizedBox(height: 30),

              /// Texto descriptivo
              const Text(
                'Introduce el código de verificación que hemos enviado '
                'a tu correo electrónico.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4A3B2A),
                ),
              ),

              const SizedBox(height: 40),

              /// Campo código
              TextField(
                  /// Configura el teclado numérico para facilitar entrada del código
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Código de verificación',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4A3B2A),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4A3B2A),
                    ),
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

              /// Botón continuar
              ElevatedButton(
                onPressed: () {
                  /// Navega a la pantalla de cambio de contraseña
                  /// tras verificar el código (validación pendiente de implementar)
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordPage(),
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