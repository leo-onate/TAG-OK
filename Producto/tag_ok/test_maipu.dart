import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://apis.tollguru.com/toll/v2/origin-destination-waypoints');
  final body = jsonEncode({
    "from": {"lat": -33.4042, "lng": -70.5645}, // Escandinavia, Las Condes
    "to": {"lat": -33.5100, "lng": -70.7600}, // El Molino, Maipu
    "vehicle": {"type": "2AxlesAuto"}
  });

  try {
    final response = await http.post(
      url,
      headers: {
        'x-api-key': 'tg_65A671FAC41C4A1782CFBE2678B16F2C',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    final resultado = jsonDecode(response.body);
    Map<String, dynamic> routeObj;
    if (resultado.containsKey('routes') && (resultado['routes'] as List).isNotEmpty) {
      routeObj = resultado['routes'][0];
    } else {
      routeObj = resultado;
    }
    
    final polylineStr = routeObj['polyline'] as String? ?? '';
    print('Polyline length: ${polylineStr.length}');
  } catch (e) {
    print('Exception: $e');
  }
}
