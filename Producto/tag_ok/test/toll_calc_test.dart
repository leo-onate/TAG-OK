import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';
import 'package:tag_ok/data/services/simulated_toll_service.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Test toll calc', (WidgetTester tester) async {
    await dotenv.load(fileName: ".env");
    final service = SimulatedTollService();
    final origin = LatLng(-33.45, -70.65);
    final destination = LatLng(-33.50, -70.75);
    
    print('Starting request...');
    final routeData = await service.calculateRouteAndTolls(
      origin: origin,
      destination: destination,
    );
    print('Done! Distance: ${routeData.distanceKm}');
    print('Tolls: ${routeData.tolls.length}');
  });
}
