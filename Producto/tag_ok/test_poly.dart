import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://apis.tollguru.com/toll/v2/origin-destination-waypoints');
  final body = jsonEncode({
    "from": {"lat": -33.4489, "lng": -70.6693},
    "to": {"lat": -33.0472, "lng": -71.6127},
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
    if (polylineStr.length > 50) {
       print('Polyline head: ${polylineStr.substring(0, 50)}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}
