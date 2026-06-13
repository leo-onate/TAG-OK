import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:tag_ok/data/mock/tolls_database.dart';
import 'package:tag_ok/data/services/simulated_toll_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

void main() {
  test('Validar Base de Datos de Pórticos', () {
    final tolls = TollsDatabase.santiagoTolls;
    expect(tolls.length, 104);
    
    final p3 = tolls.firstWhere((t) => t.name == "P3 Puente Lo Saldes - Vivaceta" && t.direction == "O-P");
    expect(p3.cost, 719.04);
    expect(p3.costPunta, 1384.32);
    expect(p3.costSaturacion, 2096.64);
  });

  test('Simular Ruta y Detección de Peajes', () async {
    // Cargar variables de entorno
    await dotenv.load(fileName: ".env");
    
    final service = SimulatedTollService();
    final origin = LatLng(-33.280, -70.690);      // Chicureo
    final destination = LatLng(-33.560, -70.680); // San Bernardo
    
    print("Iniciando cálculo de ruta de prueba...");
    final routeData = await service.calculateRouteAndTolls(
      origin: origin,
      destination: destination,
    );
    
    print("Distancia calculada: ${routeData.distanceKm} km");
    print("Costo total estimado: ${routeData.totalCost} CLP");
    print("Pórticos detectados: ${routeData.tolls.length}");
    for (var toll in routeData.tolls) {
      print("  - ${toll.name} (Costo: ${toll.cost} CLP)");
    }
    
    expect(routeData.tolls.length, greaterThan(0));
  });

  test('Simular Ruta y Detección de Peajes - Lampa a Maipú', () async {
    // Cargar variables de entorno
    await dotenv.load(fileName: ".env");
    
    final service = SimulatedTollService();
    final origin = LatLng(-33.282, -70.879);      // Lampa
    final destination = LatLng(-33.517, -70.767); // Maipú
    
    print("Iniciando cálculo de ruta Lampa -> Maipú...");
    final routeData = await service.calculateRouteAndTolls(
      origin: origin,
      destination: destination,
    );
    
    print("Distancia calculada: ${routeData.distanceKm} km");
    print("Costo total estimado: ${routeData.totalCost} CLP");
    print("Pórticos detectados: ${routeData.tolls.length}");
    for (var toll in routeData.tolls) {
      print("  - ${toll.name} (Costo: ${toll.cost} CLP)");
    }
    
    expect(routeData.tolls.length, equals(4));
  });
}
