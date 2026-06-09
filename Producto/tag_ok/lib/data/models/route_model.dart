import 'package:latlong2/latlong.dart';

class RouteData {
  final List<LatLng> polyline;
  final List<TollData> tolls;
  final double totalCost;
  final double distanceKm;
  final String durationText;
  final String direction; // ej: "Sentido Santiago" o "Sentido San Antonio"

  RouteData({
    required this.polyline,
    required this.tolls,
    required this.totalCost,
    required this.distanceKm,
    required this.durationText,
    required this.direction,
  });
}

class TollData {
  final LatLng location;
  final String name;
  final double cost; // TBFP
  final double? costPunta; // TBP
  final double? costSaturacion; // TS
  final String? direction; // "N-S", "S-N", "P-O", "O-P"
  final String? highway;
  final String? group;
  final int? sequence;

  TollData({
    required this.location,
    required this.name,
    required this.cost,
    this.costPunta,
    this.costSaturacion,
    this.direction,
    this.highway,
    this.group,
    this.sequence,
  });
}
