import 'dart:async';
import 'package:flutter/material.dart';

class InactivityLock extends StatefulWidget {
  // Widget que envolverá toda la app (todas las pantallas).
  final Widget child;

  // Tiempo máximo sin actividad antes de bloquear.
  final Duration timeout;

  const InactivityLock({
    super.key,
    required this.child,
    this.timeout = const Duration(minutes: 5),
  });

  @override
  State<InactivityLock> createState() => _InactivityLockState();
}

class _InactivityLockState extends State<InactivityLock> {
  // Timer que se reinicia cada vez que hay actividad.
  Timer? _timer;

  // Variable que indica si la app está bloqueada o no.
  bool _locked = false;

  @override
  void initState() {
    super.initState();

    // Al iniciar el widget se arranca el temporizador.
    _startTimer();
  }

  // Inicia o reinicia el temporizador de inactividad.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeout, _lockScreen);
  }

  // Bloquea la pantalla
  void _lockScreen() {
    // mounted comprueba que el widget sigue activo en pantalla
    if (!mounted) return;

    setState(() {
      _locked = true;
    });
  }

  // Desbloquea la pantalla
  void _unlock() {
    setState(() {
      _locked = false;
    });

    // Reinicia el timer al desbloquear
    _startTimer();
  }

  // Función que se llama cada vez que hay actividad del usuario
  void _onActivity() {
    // Si está bloqueada, al tocar se desbloquea
    if (_locked) {
      _unlock();
    } else {
      // Si no está bloqueada, simplemente reinicia el timer
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Hace que el detector funcione incluso si pulsas en zonas vacías
      behavior: HitTestBehavior.translucent,

      // Si haces tap en cualquier sitio, cuenta como actividad
      onTap: _onActivity,

      // Detecta movimiento / drag / clic mantenido
      onPanDown: (_) => _onActivity(),

      child: Stack(
        children: [
          // Aquí va toda la app dentro
          widget.child,

          // Si está bloqueada, se dibuja una capa encima
          if (_locked)
            Positioned.fill(
              child: AbsorbPointer(
                // AbsorbPointer bloquea interacción con lo que hay debajo
                absorbing: true,

                child: Container(
                  // Pantalla negra
                  color: Colors.black,

                  // SizedBox.expand ocupa toda la pantalla
                  child: const SizedBox.expand(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}