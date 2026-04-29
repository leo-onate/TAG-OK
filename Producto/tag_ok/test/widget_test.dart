// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tag_ok/main.dart';

void main() {
  testWidgets('Login screen renders basic fields', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Bienvenido a TagOk'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.byIcon(Icons.directions_car_filled), findsOneWidget);
  });
}
