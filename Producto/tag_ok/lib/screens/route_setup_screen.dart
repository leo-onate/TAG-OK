import 'package:flutter/material.dart';

class RouteSetupScreen extends StatefulWidget {
  const RouteSetupScreen({super.key});

  @override
  State<RouteSetupScreen> createState() => _RouteSetupScreenState();
}

class _RouteSetupScreenState extends State<RouteSetupScreen> {
  // Colores del tema dark
  final Color bgColor = const Color(0xFF0F172A);
  final Color primaryColor = const Color(0xFF4F46E5);
  final Color textMain = const Color(0xFFF8FAFC);
  final Color textMuted = const Color(0xFF94A3B8);
  final Color inputBg = const Color(0x990F172A);
  final Color surfaceBorder = const Color(0x1AFFFFFF);

  String? _selectedVehicle = 'Vehiculo prueba';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textMuted),
          onPressed: () => Navigator.pop(context), // Botón para volver atrás
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Text(
                'Configurar Viaje',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Define tu origen, destino y vehículo.',
                style: TextStyle(color: textMuted, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // 1. Campo Ruta Origen
              _buildTextField(
                hintText: 'Ruta Origen (Ej. Las Condes)',
                icon: Icons.my_location,
                iconColor: primaryColor,
              ),
              
              // Ícono de conectividad (los puntitos entre medio)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
                child: Icon(Icons.more_vert, color: textMuted.withOpacity(0.5)),
              ),

              // 2. Campo Ruta Destino
              _buildTextField(
                hintText: 'Ruta Destino (Ej. Viña del Mar)',
                icon: Icons.location_on,
                iconColor: const Color(0xFF10B981), // Color secundario verde del mockup
              ),
              
              const SizedBox(height: 32),

              // 3. Desplegable de Vehículo
              Text(
                '  Vehículo a utilizar',
                style: TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: surfaceBorder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.directions_car_outlined, color: textMuted),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedVehicle,
                          dropdownColor: bgColor,
                          icon: Icon(Icons.keyboard_arrow_down, color: textMuted),
                          style: TextStyle(color: textMain, fontSize: 16),
                          items: <String>['Vehiculo prueba'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedVehicle = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Botón Iniciar Viaje
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Lógica para iniciar el viaje (próximos pasos)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('¡Viaje iniciado con éxito!'),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Iniciar viaje',
                        style: TextStyle(
                          color: textMain,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.directions, color: textMain),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para los TextFields
  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: surfaceBorder),
      ),
      child: TextField(
        style: TextStyle(color: textMain),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: textMuted.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: iconColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
