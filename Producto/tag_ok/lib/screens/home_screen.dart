import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'route_setup_screen.dart';
import 'profile_screen.dart';
import 'vehiculos_screen.dart';
import 'audit_screen.dart';
import '../data/models/route_model.dart';
import '../data/models/trip_history.dart';
import '../data/services/history_service.dart';

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
  bool _isNavigating = false; // Estado de navegación activa

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
        
        // Si estamos navegando, el mapa sigue al usuario automáticamente
        if (_isNavigating && _currentPosition != null) {
          _mapController.move(_currentPosition!, 17.0);
        }

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
              color: primaryColor.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RouteSetupScreen(initialOrigin: _currentPosition)),
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
    if (_selectedIndex == 1) return const AuditScreen();
    if (_selectedIndex == 2) return const VehiculosScreen();
    if (_selectedIndex == 3) return const ProfileScreen();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForIndex(_selectedIndex),
            size: 80,
            color: textMuted.withValues(alpha: 0.3),
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
              urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/{z}/{x}/{y}?access_token=$mapboxToken",
              tileSize: 512,
              zoomOffset: -1,
              userAgentPackageName: 'com.tagok.app',
            ),
            // Capa de la Ruta (Línea Azul)
            if (_currentRoute != null && _currentRoute!.polyline.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _currentRoute!.polyline,
                    strokeWidth: 6.0,
                    color: const Color(0xFF3B82F6),
                  ),
                ],
              ),
              
            // Capa de los Pórticos (Íconos) y Marcadores de Inicio/Fin
            if (_currentRoute != null)
              MarkerLayer(
                markers: [
                  // Marcador de Inicio (Verde)
                  if (_currentRoute!.polyline.isNotEmpty)
                    Marker(
                      point: _currentRoute!.polyline.first,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.radio_button_checked, color: Color(0xFF10B981), size: 30),
                    ),
                  
                  // Marcador de Fin (Rojo)
                  if (_currentRoute!.polyline.isNotEmpty)
                    Marker(
                      point: _currentRoute!.polyline.last,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Color(0xFFEF4444), size: 35),
                    ),

                  // Marcadores de Pórticos
                  ..._currentRoute!.tolls.map((toll) => Marker(
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
                  )),
                ],
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
                color: navBgColor.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
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
                  if (!_isNavigating) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isNavigating = true;
                        });
                        _mapController.move(_currentPosition ?? _currentRoute!.polyline.first, 17.0);
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF818CF8)]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.navigation, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('IR AHORA', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Botón Pausar/Seguir
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isNavigating = !_isNavigating;
                              });
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                              ),
                              child: Icon(
                                _isNavigating ? Icons.pause : Icons.play_arrow, 
                                color: primaryColor
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Botón Finalizar Viaje (Limpia todo y guarda historial)
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () async {
                              // Guardar en el historial antes de limpiar
                              if (_currentRoute != null) {
                                final historyService = HistoryService();
                                final trip = TripHistory(
                                  id: '', // Se genera en Firestore
                                  date: DateTime.now(),
                                  totalCost: _currentRoute!.totalCost,
                                  distanceKm: _currentRoute!.distanceKm,
                                  duration: _currentRoute!.durationText,
                                  tolls: _currentRoute!.tolls.map((t) => TollRecord(
                                    name: t.name,
                                    cost: t.cost, // Usamos el costo base o el que se haya aplicado
                                    timestamp: DateTime.now(),
                                  )).toList(),
                                );
                                await historyService.saveTrip(trip);
                                
                                // Lógica de Notificación de Límite
                                final allTrips = await historyService.getTripHistory().first;
                                final double newTotal = allTrips.fold(0, (sum, t) => sum + t.totalCost);
                                final double limit = await historyService.getMonthlyLimit().first;
                                
                                if (mounted) {
                                  _checkAndShowLimitAlert(context, newTotal, limit);
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Viaje guardado en el historial'),
                                      backgroundColor: Color(0xFF10B981),
                                    ),
                                  );
                                }
                              }

                              setState(() {
                                _isNavigating = false;
                                _currentRoute = null;
                              });
                              _centerOnUser();
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(color: Colors.redAccent.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'FINALIZAR VIAJE', 
                                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
  void _checkAndShowLimitAlert(BuildContext context, double total, double limit) {
    final double percentage = (total / limit) * 100;
    String? message;
    Color alertColor = Colors.blue;

    if (percentage >= 100) {
      message = "¡Has alcanzado el 100% de tu límite mensual!";
      alertColor = Colors.redAccent;
    } else if (percentage >= 90) {
      message = "Atención: Llevas el 90% de tu límite gastado.";
      alertColor = Colors.orangeAccent;
    } else if (percentage >= 75) {
      message = "Aviso: Llevas el 75% de tu presupuesto consumido.";
      alertColor = Colors.yellowAccent;
    } else if (percentage >= 50) {
      message = "Informativo: Has llegado al 50% de tu presupuesto mensual.";
    }

    if (message != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: alertColor),
              const SizedBox(width: 10),
              const Text("Alerta de Presupuesto", style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: Text(message!, style: const TextStyle(color: Color(0xFF94A3B8))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("ENTENDIDO", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withValues(alpha: 0.3),
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
                color: Colors.black.withValues(alpha: 0.2),
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
