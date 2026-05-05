import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';

class TollGuruService {
  final String _baseUrl = 'https://apis.tollguru.com/toll/v2';
  
  String get _apiKey {
    return dotenv.env['TOLLGURU_API_KEY'] ?? '';
  }

  /// Calcula la ruta y los peajes entre un origen y un destino.
  /// Retorna un mapa con la respuesta de TollGuru, que incluye la polilínea,
  /// el costo total y el detalle de cada pórtico.
  Future<Map<String, dynamic>> calculateToll({
    required LatLng origin,
    required LatLng destination,
    String vehicleType = '2AxlesAuto', // Por defecto auto normal
  }) async {
    // Si es Web, usamos nuestro Proxy Local para evitar el bloqueo CORS de Chrome
    final url = kIsWeb 
        ? Uri.parse('http://localhost:8080')
        : Uri.parse('$_baseUrl/origin-destination-waypoints');

    // Estructura requerida por TollGuru v2
    final body = jsonEncode({
      "from": {
        "lat": origin.latitude,
        "lng": origin.longitude
      },
      "to": {
        "lat": destination.latitude,
        "lng": destination.longitude
      },
      "vehicle": {
        "type": vehicleType
      }
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'x-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Error TollGuru [${response.statusCode}]: ${response.body}');
        throw Exception('Código ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Excepción TollGuru: $e');
      rethrow;
    }
  }
}
