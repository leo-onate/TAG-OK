import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class PolylineDecoder {
  static List<LatLng> decode(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        if (index >= len) break;
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }

    return poly;
  }
}

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
    
    final decoded = PolylineDecoder.decode(polylineStr);
    print('Decoded points: ${decoded.length}');
    if (decoded.isNotEmpty) {
      print('First point: ${decoded[0].latitude}, ${decoded[0].longitude}');
      print('Last point: ${decoded.last.latitude}, ${decoded.last.longitude}');
    }
    
  } catch (e) {
    print('Exception: $e');
  }
}
