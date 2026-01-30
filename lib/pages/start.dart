import 'package:flutter/material.dart';
import 'login.dart';

/// Pantalla de inicio de la aplicación
/// Primera pantalla que ve el usuario al abrir la app
/// Muestra el logo, nombre y descripción de la masia con un botón para acceder al login
class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E9C9),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 10),

            // Sección superior: Logo y texto de inicio
            Column(
              children: [
                //Logo
                Image.asset(
                  'assets/masets_blanco.png',
                  height: 250,
                ),
                const SizedBox(height: 40),
                //Nombre de la empresa
                const Text(
                  'Masia Els Masets',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3B2A),
                  ),
                ),
                const SizedBox(height: 15),

                //Descripción de la aplicación
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Gestión integral de producción, trazabilidad y stock lácteo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF4A3B2A),
                    ),
                  ),
                ),
              ],
            ),

            // Sección inferior: Botón para acceder al login
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () {
                  /// Navega a la pantalla de login
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A3B2A),
                  minimumSize: const Size(double.infinity, 75),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Acceder',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}