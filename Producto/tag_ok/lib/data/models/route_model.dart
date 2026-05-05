import 'package:latlong2/latlong.dart';

class RouteData {
  final List<LatLng> polyline;
  final List<TollData> tolls;
  final double totalCost;
  final double distanceKm;
  final String durationText;

  RouteData({
    required this.polyline,
    required this.tolls,
    required this.totalCost,
    required this.distanceKm,
    required this.durationText,
  });
}

class TollData {
  final LatLng location;
  final String name;
  final double cost;

  TollData({
    required this.location,
    required this.name,
    required this.cost,
  });
}
