import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'lib/utils/polyline_decoder.dart';
import 'dart:io';

void main() async {
  final envContent = File('.env').readAsStringSync();
  String mapboxToken = '';
  for (var line in envContent.split('\n')) {
    if (line.startsWith('MAPBOX_ACCESS_TOKEN=')) {
      mapboxToken = line.split('=')[1].trim();
      break;
    }
  }
  
  final url = Uri.parse('https://api.mapbox.com/directions/v5/mapbox/driving/-70.6693,-33.4489;-70.6628,-33.4243?overview=full&geometries=polyline&access_token=$mapboxToken');
  final r = await http.get(url);
  print(r.statusCode);
  if (r.statusCode == 200) {
    final data = jsonDecode(r.body);
    final polylineStr = data['routes'][0]['geometry'] as String;
    print('Polyline: ${polylineStr.substring(0, 20)}...');
    final points = PolylineDecoder.decode(polylineStr);
    print('First point: ${points.first.latitude}, ${points.first.longitude}');
  } else {
    print(r.body);
  }
}
