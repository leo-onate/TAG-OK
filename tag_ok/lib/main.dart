import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Importa tu nueva pantalla

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TagOk',
      home: const LoginScreen(), // Aquí le decimos que empiece en el Login
    );
  }
}