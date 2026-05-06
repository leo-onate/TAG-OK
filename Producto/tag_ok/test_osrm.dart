import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'lib/utils/polyline_decoder.dart';

void main() async {
  final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/-70.6693,-33.4489;-70.6628,-33.4243?overview=full&geometries=polyline');
  final r = await http.get(url);
  final data = jsonDecode(r.body);
  final polylineStr = data['routes'][0]['geometry'] as String;
  print('Polyline: ${polylineStr.substring(0, 20)}...');
  
  try {
    final points = PolylineDecoder.decode(polylineStr);
    print('First point: ${points.first.latitude}, ${points.first.longitude}');
    
    final distance = const Distance();
    final toll = LatLng(-33.4243, -70.6628);
    for (var p in points) {
      distance.as(LengthUnit.Meter, p, toll);
    }
    print('Distance calculated perfectly!');
  } catch(e) {
    print('Error: \$e');
  }
}
