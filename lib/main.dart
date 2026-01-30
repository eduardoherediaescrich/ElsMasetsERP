import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/start.dart';

/// Función principal que inicia la aplicación
void main() {
  runApp(const ElsMasetsApp());
}

/// Widget raíz de la aplicación Els Masets
/// Configura el tema y define la pantalla inicial
class ElsMasetsApp extends StatelessWidget {
  const ElsMasetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Masia Els Masets',
      
      //Este método sirve para que funcione el calendario en español
      //El calendario es el que se usa en la pantalla de producción
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      
      home: const InicioPage(),
    );
  }
}