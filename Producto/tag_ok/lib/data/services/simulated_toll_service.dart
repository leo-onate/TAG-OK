import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';
import '../models/route_model.dart';
import '../mock/tolls_database.dart';
import '../../utils/polyline_decoder.dart';

class SimulatedTollService {
  final String _baseUrl = 'https://api.mapbox.com/directions/v5/mapbox/driving';

  Future<RouteData> calculateRouteAndTolls({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final String mapboxToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    
    if (mapboxToken.isEmpty) {
      throw Exception('Mapbox token no configurado en .env');
    }

    final String coordinates = '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';
    final url = Uri.parse('$_baseUrl/$coordinates?overview=full&geometries=polyline&access_token=$mapboxToken');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        return calculateTolls(data['routes'][0]);
      } else {
        throw Exception('No se encontró una ruta válida');
      }
    } else {
      throw Exception('Error al conectar con Mapbox: ${response.statusCode}');
    }
  }

  Future<RouteData> calculateTolls(Map<String, dynamic> routeGeometry) async {
    // 1. Decodificar polilínea (lista de puntos)
    final polylineStr = routeGeometry['geometry'] as String;
    final polylinePoints = PolylineDecoder.decode(polylineStr);

    // 2. Extraer distancia y duración (desde Mapbox API)
    final distanceMeters = routeGeometry['distance'] as num;
    final durationSeconds = routeGeometry['duration'] as num;

    final distanceKm = distanceMeters / 1000.0;

    // 3. Simular pórticos interceptados
    final tolls = _calculateTollsForRoute(polylinePoints);

    // 4. Sentido genérico aproximado
    String direction = "Desconocido";
    if (polylinePoints.isNotEmpty) {
      final origin = polylinePoints.first;
      final destination = polylinePoints.last;
      
      if (origin.longitude < destination.longitude) {
        direction = "Sentido Santiago (Oriente)";
      } else if (origin.longitude > destination.longitude) {
        direction = "Sentido San Antonio (Poniente)";
      }
    }

    // Calcular costo total
    // BLOQUEO TOTAL: Forzamos BASE permanentemente para cuadrar con TollGuru
    const bool isSaturacion = false; 
    const bool isPunta = false; 
    double totalCost = 0;
    for (var toll in tolls) {
      double cost = toll.cost;
      String mode = "BASE";
      
      if (isSaturacion && toll.costSaturacion != null) {
        cost = toll.costSaturacion!;
        mode = "SATURACION";
      } else if (isPunta && toll.costPunta != null) {
        cost = toll.costPunta!;
        mode = "PUNTA";
      }
      
      print("TAG_OK_DEBUG: Cobrando ${toll.name} - \$${cost} (Modo: $mode)");
      totalCost += cost;
    }

    // Formatear tiempo
    final durationText = _formatDuration(durationSeconds);

    return RouteData(
      polyline: polylinePoints,
      tolls: tolls,
      totalCost: totalCost, 
      distanceKm: distanceKm,
      durationText: durationText,
      direction: direction,
    );
  }

  List<TollData> _calculateTollsForRoute(List<LatLng> routePoints) {
    final List<TollData> detectedTolls = [];
    final Set<String> seenTollNames = {}; // Para evitar duplicados en la misma ruta
    final knownTolls = TollsDatabase.santiagoTolls;
    // Reducido a 150m para evitar captar pórticos de calles laterales.
    // Con la deduplicación por nombre, esto debería ser muy estable.
    final double thresholdMeters = 150.0; 

    if (routePoints.isEmpty) return detectedTolls;

    for (var knownToll in knownTolls) {
      bool passedThrough = false;
      LatLng? bestSnappedPoint;
      double minDistance = double.infinity;
      double? segmentBearing;
      
      // Comprobar la distancia desde el pórtico a cada segmento de la ruta
      for (int i = 0; i < routePoints.length - 1; i++) {
        final snapResult = _snapToSegment(
          knownToll.location, 
          routePoints[i], 
          routePoints[i+1]
        );
        
        if (snapResult.distance <= thresholdMeters) {
          passedThrough = true;
          if (snapResult.distance < minDistance) {
            minDistance = snapResult.distance;
            bestSnappedPoint = snapResult.point;
            segmentBearing = _calculateBearing(routePoints[i], routePoints[i+1]);
          }
        }
      }
      
      if (passedThrough && bestSnappedPoint != null) {
        // Filtrar por sentido de marcha
        if (knownToll.direction != null && segmentBearing != null) {
          bool isMatch = _checkDirectionMatch(
            segmentBearing, 
            knownToll.direction!,
            highway: knownToll.highway,
            location: knownToll.location,
          );
          if (!isMatch) {
            continue; 
          }
        }

        // Usar el punto exacto proyectado sobre la autopista
        final detectedToll = TollData(
          name: knownToll.name,
          cost: knownToll.cost,
          costPunta: knownToll.costPunta,
          costSaturacion: knownToll.costSaturacion,
          direction: knownToll.direction,
          location: bestSnappedPoint,
        );
        
        // Evitar duplicados (mismo pórtico detectado más de una vez en el trayecto)
        if (!seenTollNames.contains(detectedToll.name)) {
          // Si ya hay un pórtico muy cerca (<100m) con nombre similar, saltar
          bool tooClose = detectedTolls.any((t) => 
            _calculateDistance(t.location, detectedToll.location) < 100);
          
          if (!tooClose) {
            detectedTolls.add(detectedToll);
            seenTollNames.add(detectedToll.name);
            print("TAG_OK_DEBUG: Detectado ${detectedToll.name} a ${minDistance.toStringAsFixed(1)}m");
          }
        }
      }
    }

    return detectedTolls;
  }

  /// Calcula el punto más cercano de la ruta a la ubicación aproximada del pórtico
  /// y devuelve la distancia y la coordenada matemática exacta sobre la ruta.
  _SnapResult _snapToSegment(LatLng p, LatLng a, LatLng b) {
    // Convertir grados a metros aproximadamente (válido para la latitud de Santiago)
    const double kLat = 111320.0;
    final double kLon = 111320.0 * math.cos(p.latitude * math.pi / 180.0);
    
    final double px = p.longitude * kLon;
    final double py = p.latitude * kLat;
    final double ax = a.longitude * kLon;
    final double ay = a.latitude * kLat;
    final double bx = b.longitude * kLon;
    final double by = b.latitude * kLat;
    
    final double dx = bx - ax;
    final double dy = by - ay;
    
    if (dx == 0 && dy == 0) {
      final dist = math.sqrt(math.pow(px - ax, 2) + math.pow(py - ay, 2));
      return _SnapResult(dist, a);
    }
    
    double t = ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy);
    t = math.max(0.0, math.min(1.0, t));
    
    final double closestX = ax + t * dx;
    final double closestY = ay + t * dy;
    
    final dist = math.sqrt(math.pow(px - closestX, 2) + math.pow(py - closestY, 2));
    final snappedLatLng = LatLng(closestY / kLat, closestX / kLon);
    
    return _SnapResult(dist, snappedLatLng);
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180.0;
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final lat1 = _toRadians(start.latitude);
    final lon1 = _toRadians(start.longitude);
    final lat2 = _toRadians(end.latitude);
    final lon2 = _toRadians(end.longitude);

    final dLon = lon2 - lon1;

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
            math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double bearing = math.atan2(y, x);
    bearing = (bearing * 180.0 / math.pi + 360.0) % 360.0;
    return bearing;
  }

  bool _checkDirectionMatch(double bearing, String tollDir, {String? highway, LatLng? location}) {
    // Para autopistas tipo anillo (como Vespucio Norte), la dirección física
    // cambia de Este-Oeste a Norte-Sur en la zona Poniente (longitud < -70.73).
    if (highway == "Vespucio Norte" && location != null && location.longitude < -70.73) {
      if (tollDir == "P-O") return bearing >= 315 || bearing < 45; // Sentido Norte
      if (tollDir == "O-P") return bearing >= 135 && bearing < 225; // Sentido Sur
    }

    // Cuadrantes estrictos de 90 grados (+/- 45 del eje)
    if (tollDir == "S-N") return bearing >= 315 || bearing < 45; // Norte
    if (tollDir == "P-O") return bearing >= 45 && bearing < 135; // Oriente
    if (tollDir == "N-S") return bearing >= 135 && bearing < 225; // Sur
    if (tollDir == "O-P") return bearing >= 225 && bearing < 315; // Poniente
    return true;
  }

  String _formatDuration(dynamic secondsRaw) {
    final int seconds = (secondsRaw as num).toInt();
    final int minutes = (seconds / 60).round();
    if (minutes > 60) {
      final int hours = minutes ~/ 60;
      final int mins = minutes % 60;
      return '${hours}h ${mins}m';
    }
    return '${minutes} min';
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const double kLat = 111320.0;
    final double kLon = 111320.0 * math.cos(p1.latitude * math.pi / 180.0);
    final double dx = (p1.longitude - p2.longitude) * kLon;
    final double dy = (p1.latitude - p2.latitude) * kLat;
    return math.sqrt(dx * dx + dy * dy);
  }

  bool _isHorarioPunta() {
    final now = DateTime.now();
    if (now.weekday >= 1 && now.weekday <= 5) {
      if (now.hour >= 7 && now.hour < 9) return true;
      if ((now.hour == 17 && now.minute >= 30) || (now.hour >= 18 && now.hour < 20)) return true;
    }
    return false;
  }

  bool _isHorarioSaturacion() {
    final now = DateTime.now();
    if (now.weekday >= 1 && now.weekday <= 5) {
      // Definimos unas ventanas de saturación más críticas (ejemplo simulado)
      if (now.hour == 8) return true;
      if (now.hour == 18) return true;
    }
    return false;
  }
}

class _SnapResult {
  final double distance;
  final LatLng point;

  _SnapResult(this.distance, this.point);
}
