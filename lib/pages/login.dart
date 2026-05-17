import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'register.dart';
import 'remember_password.dart';
import '../services/auth_service.dart';

/// Pantalla de inicio de sesión
/// Permite al usuario autenticarse con email y contraseña
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// Controllers para leer los campos de email y contraseña
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contrasenyaController = TextEditingController();

  /// Controla la visibilidad del texto de la contraseña
  bool obscurePassword = true;

  /// Indica si la petición de login está en curso
  bool _cargando = false;

  /// Mensaje de error si el login falla
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _contrasenyaController.dispose();
    super.dispose();
  }

  /// Realiza el login llamando al AuthService
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _contrasenyaController.text.isEmpty) {
      setState(() {
        _error = 'Por favor, introduce el email y la contraseña';
      });
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    final exito = await AuthService.login(
      _emailController.text.trim(),
      _contrasenyaController.text,
    );

    if (!mounted) return;

    if (exito) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else {
      setState(() {
        _cargando = false;
        _error = 'Email o contraseña incorrectos';
      });
    }
  }

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
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
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

                // Campo contraseña con toggle de visibilidad
                TextField(
                  controller: _contrasenyaController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
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

                const SizedBox(height: 20),

                // Mensaje de error
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 10),

                // Botón de iniciar sesión
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A3B2A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
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

                // Enlace a registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Todavía no tienes cuenta? ',
                      style: TextStyle(fontSize: 16, color: Color(0xFF4A3B2A)),
                    ),
                    TextButton(
                      onPressed: () {
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
                          color: Colors.green,
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
