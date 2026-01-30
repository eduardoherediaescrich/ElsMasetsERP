// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elsmasets_flutter/main.dart'; // importa tu main.dart correctamente

void main() {
  testWidgets('La app muestra la pantalla de bienvenida y navega al login', (WidgetTester tester) async {
    // Construye el widget
    await tester.pumpWidget(const ElsMasetsApp());

    // Comprueba que aparece el título
    expect(find.text('Masia Els Masets'), findsOneWidget);

    // Comprueba que hay un widget Image (logo)
    expect(find.byType(Image), findsOneWidget);

    // Comprueba que aparece el botón 'Acceder'
    final accederButton = find.text('Acceder');
    expect(accederButton, findsOneWidget);

    // Simula un tap en el botón "Acceder"
    await tester.tap(accederButton);

    // Reconstruye la UI tras la navegación
    await tester.pumpAndSettle();

    // Comprueba que se navega a LoginPage
    expect(find.text('Aquí irá el login'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget); // Comprueba AppBar
  });
}