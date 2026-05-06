import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/route_model.dart';
import '../../utils/polyline_decoder.dart';
import '../mock/tolls_database.dart';

class SimulatedTollService {
  final String _mapboxBaseUrl = 'https://api.mapbox.com/directions/v5/mapbox/driving';

  Future<RouteData> calculateRouteAndTolls({
    required LatLng origin,
    required LatLng destination,
    String vehicleType = '2AxlesAuto',
  }) async {
    final String mapboxToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    
    // 1. Obtener la ruta real usando Mapbox Directions API
    final url = Uri.parse('$_mapboxBaseUrl/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?geometries=polyline&overview=full&access_token=$mapboxToken');
    
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener la ruta de Mapbox: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    
    if (data['routes'] == null || (data['routes'] as List).isEmpty) {
      throw Exception('No se encontró una ruta posible');
    }

    final routeInfo = data['routes'][0];
    final polylineStr = routeInfo['geometry'] as String;
    final distanceKm = (routeInfo['distance'] ?? 0) / 1000.0;
    final durationSeconds = routeInfo['duration'] ?? 0;
    
    // Decodificar la polyline
    final polylinePoints = PolylineDecoder.decode(polylineStr);
    
    // 2. Simular los pórticos (Cruzar la ruta con nuestra base de datos)
    final tolls = _calculateTollsForRoute(polylinePoints);
    
    // Calcular costo total
    double totalCost = 0;
    for (var toll in tolls) {
      totalCost += toll.cost;
    }

    // Formatear tiempo
    final durationText = _formatDuration(durationSeconds);

    return RouteData(
      polyline: polylinePoints,
      tolls: tolls,
      totalCost: totalCost,
      distanceKm: distanceKm,
      durationText: durationText,
    );
  }

  List<TollData> _calculateTollsForRoute(List<LatLng> routePoints) {
    final List<TollData> detectedTolls = [];
    
    // Obtenemos los pórticos de nuestra base de datos local
    final knownTolls = TollsDatabase.santiagoTolls;

    // Aumentamos el radio a 250 metros porque el trazado de OSRM 
    // a veces difiere ligeramente del centro exacto de la autopista
    final double thresholdMeters = 250.0; 

    for (var knownToll in knownTolls) {
      bool passedThrough = false;
      for (var point in routePoints) {
        final dist = _calculateHaversineDistance(
          point.latitude, 
          point.longitude, 
          knownToll.location.latitude, 
          knownToll.location.longitude
        );
        if (dist <= thresholdMeters) {
          passedThrough = true;
          break;
        }
      }
      
      if (passedThrough) {
        detectedTolls.add(knownToll);
      }
    }

    return detectedTolls;
  }

  /// Calcula la distancia en metros entre dos coordenadas usando la fórmula del Haversine.
  /// Esto evita el bug "Distance calculation failed to converge!" de la fórmula de Vincenty en latlong2.
  double _calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371000.0; // Radio de la Tierra en metros
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180.0;
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
}
