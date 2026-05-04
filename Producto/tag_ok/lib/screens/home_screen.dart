import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'route_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  // Colores extraídos de tu diseño dark mode
  final Color bgColor = const Color(0xFF0F172A);
  final Color primaryColor = const Color(0xFF4F46E5);
  final Color navBgColor = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF94A3B8);
  final Color textMain = const Color(0xFFF8FAFC);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // Contenido principal de la pantalla según la pestaña seleccionada
      body: SafeArea(
        child: _selectedIndex == 0 ? _buildMapTab() : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconForIndex(_selectedIndex),
                size: 80,
                color: textMuted.withOpacity(0.3),
              ),
              const SizedBox(height: 20),
              Text(
                _getTitleForIndex(_selectedIndex),
                style: TextStyle(
                  color: textMain,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      
      // El botón central flotante y grande (Iniciar Ruta / Mapa)
      floatingActionButton: Container(
        height: 72,
        width: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RouteSetupScreen()),
            );
          },
          backgroundColor: primaryColor,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.map_outlined,
            size: 34,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // Menú de navegación inferior con el "hueco" en el medio
      bottomNavigationBar: BottomAppBar(
        color: navBgColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavIcon(Icons.dashboard_outlined, 0, 'Inicio'),
              _buildNavIcon(Icons.receipt_long_outlined, 1, 'Auditoría'),
              
              const SizedBox(width: 50), // Espacio para el botón central flotante
              
              _buildNavIcon(Icons.directions_car_outlined, 2, 'Vehículos'),
              _buildNavIcon(Icons.person_outline, 3, 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para construir cada ícono del menú inferior
  Widget _buildNavIcon(IconData icon, int index, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : textMuted,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryColor : textMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTab() {
    final mapboxToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(-33.4489, -70.6693), // Santiago, Chile
        initialZoom: 12.0,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxToken",
          additionalOptions: const {
            'accessToken': '',
          },
        ),
      ],
    );
  }

  // Helpers para los textos temporales del centro
  String _getTitleForIndex(int index) {
    switch (index) {
      case 0: return 'Panel de Inicio';
      case 1: return 'Auditoría de Boletas (IA)';
      case 2: return 'Gestión de Vehículos';
      case 3: return 'Mi Perfil';
      default: return '';
    }
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0: return Icons.dashboard_outlined;
      case 1: return Icons.receipt_long_outlined;
      case 2: return Icons.directions_car_outlined;
      case 3: return Icons.person_outline;
      default: return Icons.error;
    }
  }
}
