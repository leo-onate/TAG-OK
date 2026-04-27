import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importa dotenv
import 'firebase_options.dart'; // El archivo que generaste recién
import 'screens/login_screen.dart'; // Importa tu nueva pantalla

void main() async {
  // 1. Asegura que los widgets estén listos
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Carga las variables de entorno
  await dotenv.load(fileName: ".env");

  // 3. Inicializa Firebase con tus opciones generadas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

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