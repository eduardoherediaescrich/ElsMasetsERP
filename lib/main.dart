import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'pages/start.dart';
import 'widgets/inactivity_lock.dart';

void main() async {
  // Asegura que Flutter está inicializado antes de usar plugins nativos
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el window_manager para poder manipular la ventana
  await windowManager.ensureInitialized();

  // Obtiene información del monitor principal (pantalla principal)
  Display primaryDisplay = await screenRetriever.getPrimaryDisplay();

  // Calcula el ancho de la ventana:
  // Mitad del ancho del monitor + 16 píxeles (ajuste manual para encajar mejor)
  double halfWidth = primaryDisplay.size.width / 2 + 16;

  // Calcula el alto de la ventana:
  // Alto total del monitor menos 40 píxeles para evitar tapar la barra de tareas
  double safeHeight = primaryDisplay.size.height - 40;

  // Configuración de la ventana en escritorio
  WindowOptions windowOptions = WindowOptions(
    size: Size(halfWidth, safeHeight),
    center: false,
    title: 'Masia Els Masets ERP',
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  // Espera a que la ventana esté lista antes de mostrarla
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    // Posiciona la ventana manualmente en la esquina superior izquierda
    // Offset(-8, 0) corrige pequeños márgenes del sistema
    await windowManager.setPosition(const Offset(-8, 0));

    // Muestra la ventana
    await windowManager.show();

    // Enfoca la ventana para que esté activa al arrancar
    await windowManager.focus();
  });

  // Inicia la aplicación Flutter
  runApp(const ElsMasetsApp());
}

class ElsMasetsApp extends StatelessWidget {
  const ElsMasetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Masia Els Masets ERP',

      // Delegados para que Flutter pueda traducir widgets internos
      // y usar formatos de idioma (por ejemplo fechas en español)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Idiomas soportados por la app
      supportedLocales: const [
        Locale('es', 'ES'),
      ],

      // builder se ejecuta antes de pintar cualquier pantalla
      // y permite envolver toda la app dentro de otro widget
      builder: (context, child) {
        return InactivityLock(
          // Tiempo máximo sin actividad antes de bloquear la pantalla
          timeout: const Duration(minutes: 1),

          // pantalla actual que esté mostrando la app en ese momento
          child: child ?? const SizedBox(),
        );
      },

      // Página principal inicial al arrancar la app
      home: const InicioPage(),
    );
  }
}