import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o Ícono
            const Icon(Icons.directions_car_filled, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            
            // Título
            Text(
              'Bienvenido a TagOk',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            const SizedBox(height: 10),
            const Text('Gestiona tus peajes de forma fácil', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 50),

            // Campo de Usuario
            TextField(
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),

            // Campo de Contraseña
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),

            // Botón de Inicio
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {}, // No hace nada por ahora
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Iniciar Sesión', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}