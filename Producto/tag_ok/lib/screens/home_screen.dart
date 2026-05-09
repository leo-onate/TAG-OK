import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'route_setup_screen.dart';
import 'profile_screen.dart';
import 'vehiculos_screen.dart';
import '../data/models/route_model.dart';

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

  // Controladores y estado del mapa
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  
  RouteData? _currentRoute;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  /// Pide permisos e inicia el seguimiento en tiempo real
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si el GPS está activado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('El servicio de ubicación está deshabilitado.');
      return;
    }

    // Verifica permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Permisos de ubicación denegados.');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Permisos de ubicación denegados permanentemente.');
      return;
    }

    // Si tenemos permiso, nos suscribimos a los cambios de ubicación
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Notificar solo si se mueve 5 metros
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        
        // Si es la primera vez que obtenemos la ubicación, centramos el mapa ahí
        if (_currentPosition != null && !_hasCenteredMapInitially) {
          _centerOnUser();
          _hasCenteredMapInitially = true;
        }
      }
    );
  }

  bool _hasCenteredMapInitially = false;

  void _centerOnUser() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 15.0);
    }
  }

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
        child: _buildBodyTab(),
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
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RouteSetupScreen()),
            );
            
            if (result is RouteData) {
              setState(() {
                _currentRoute = result;
              });
              
              if (result.polyline.isNotEmpty) {
                // Enfocar el mapa en la ruta
                final bounds = LatLngBounds.fromPoints(result.polyline);
                _mapController.fitCamera(CameraFit.bounds(
                  bounds: bounds,
                  padding: const EdgeInsets.all(50.0),
                ));
              }
            }
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

  Widget _buildBodyTab() {
    if (_selectedIndex == 0) return _buildMapTab();
    if (_selectedIndex == 2) return const VehiculosScreen();
    if (_selectedIndex == 3) return const ProfileScreen();
    
    return Center(
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
    );
  }

  Widget _buildMapTab() {
    final mapboxToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    
    return Stack(
      children: [
        // 1. El Mapa en sí
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(-33.4489, -70.6693), // Santiago, Chile (fallback)
            initialZoom: 12.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxToken",
              additionalOptions: const {
                'accessToken': '',
              },
            ),
            // Capa de la Ruta (Línea Azul)
            if (_currentRoute != null && _currentRoute!.polyline.isNotEmpty)
              PolylineLayer(
                polylines: [
                  // LÍNEA DE PRUEBA (ROJA, MUY GRUESA)
                  Polyline(
                    points: [
                       _currentRoute!.polyline.first,
                       _currentRoute!.polyline.last,
                    ],
                    strokeWidth: 15.0,
                    color: Colors.redAccent,
                  ),
                  // LÍNEA REAL (AZUL)
                  Polyline(
                    points: _currentRoute!.polyline,
                    strokeWidth: 6.0,
                    color: const Color(0xFF3B82F6),
                  ),
                ],
              ),
              
            // Capa de los Pórticos (Íconos)
            if (_currentRoute != null)
              MarkerLayer(
                markers: _currentRoute!.tolls.map((toll) => Marker(
                  point: toll.location,
                  width: 32,
                  height: 32,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.monetization_on, color: Color(0xFFF59E0B), size: 24),
                  ),
                )).toList(),
              ),

            // 2. Capa de Marcadores (Punto azul del usuario)
            if (_currentPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition!,
                    width: 60,
                    height: 60,
                    child: _buildLocationMarker(),
                  ),
                ],
              ),
          ],
        ),
        
        // Tarjeta resumen de la ruta
        if (_currentRoute != null)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: navBgColor.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Costo Total Estimado', style: TextStyle(color: textMuted, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('\$${_currentRoute!.totalCost.toStringAsFixed(0)} CLP', style: const TextStyle(color: Color(0xFF10B981), fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Distancia / Tiempo', style: TextStyle(color: textMuted, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${_currentRoute!.distanceKm.toStringAsFixed(1)} km • ${_currentRoute!.durationText}', style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        
        // 3. Botón flotante para centrar la ubicación
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: "centerLocationBtn", // Evita conflictos de hero con el boton central
            mini: true,
            backgroundColor: navBgColor,
            onPressed: _centerOnUser,
            child: Icon(
              Icons.my_location,
              color: _currentPosition != null ? primaryColor : textMuted,
            ),
          ),
        ),
      ],
    );
  }

  // Diseño del punto azul con sombra/halo
  Widget _buildLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withOpacity(0.3),
          ),
        ),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
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
