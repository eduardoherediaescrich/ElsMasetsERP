import 'package:flutter/material.dart';
import 'register.dart';
import 'dashboard.dart';
import 'remember_password.dart';
/// Pantalla de inicio de sesión
/// Permite al usuario autenticarse con email y contraseña
/// Incluye checkbox para recordar contraseña y enlaces a recuperación y registro
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// Indica si el usuario desea que se recuerde su contraseña
  bool rememberPassword = false;

  /// Controla la visibilidad del texto de la contraseña
  bool obscurePassword = true;

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

                const SizedBox(height: 50),

                // Título
                const Text(
                  '¡BIENVENIDO DE NUEVO!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3B2A),
                  ),
                ),

                const SizedBox(height: 40),

                // Campo email
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Campo contraseña con toogle de visibilidad
                TextField(
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            //Ojo cerrado
                            ? Icons.visibility_off
                            // Ojo abierto
                            : Icons.visibility,
                      ),
                      /// Alterna la visibilidad de la contraseña al pulsar el icono
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Checkbox recordar contraseña
                Row(
                  children: [
                    Checkbox(
                      value: rememberPassword,
                      onChanged: (value) {
                        setState(() {
                          rememberPassword = value!;
                        });
                      },
                    ),
                    const Text(
                      'Recordar contraseña',
                      style: TextStyle(color: Color.fromRGBO(74, 59, 42, 1),
                      fontSize: 16),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Botón de iniciar sesión
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      /// Navega al dashboard y reemplaza la pantalla actual
                      /// Usa pushReplacement para evitar que el usuario vuelva
                      /// al login con el botón de atrás por seguridad
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(74, 59, 42, 1), // Marrón corporativo
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Enlace a recuperar contraseña
                TextButton(
                  onPressed: () {
                    /// Navega a la pantalla de recuperación de contraseña
                    Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RememberPasswordPage(),
                          ),
                        );
                  },
                  child: const Text(
                    '¿Has olvidado la contraseña?',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                //Enlace a registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Todavía no tienes cuenta? ',
                      style: TextStyle(fontSize: 16, color: Color(0xFF4A3B2A)),
                    ),
                    TextButton(
                      onPressed: () {
                        /// Navega a la pantalla de registro
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistroPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green, // verde corporativo
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
