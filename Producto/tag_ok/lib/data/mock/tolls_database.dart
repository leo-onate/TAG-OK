import 'package:latlong2/latlong.dart';
import '../models/route_model.dart';

/// Base de datos extensa de Pórticos y Tarifas (Santiago de Chile)
/// Reemplazo completo de TollGuru con cobertura de las 4 autopistas principales.
class TollsDatabase {
  static final List<TollData> santiagoTolls = [
    // --- COSTANERA NORTE ---
    TollData(name: "Pórtico P1 - Ruta 68 / Vespucio", location: const LatLng(-33.4357, -70.7712), cost: 650.0),
    TollData(name: "Pórtico P2 - Petersen / Carrascal", location: const LatLng(-33.4285, -70.7301), cost: 550.0),
    TollData(name: "Pórtico P3 - Walker Martínez", location: const LatLng(-33.4250, -70.6950), cost: 500.0),
    TollData(name: "Pórtico P4 - Vivaceta / San Martín", location: const LatLng(-33.4243, -70.6628), cost: 1100.0),
    TollData(name: "Pórtico P5 - Purísima / Recoleta", location: const LatLng(-33.4280, -70.6400), cost: 950.0),
    TollData(name: "Pórtico P6 - La Concepción / P. de Valdivia", location: const LatLng(-33.4170, -70.6120), cost: 800.0),
    TollData(name: "Pórtico P7 - Lo Saldes / Centenario", location: const LatLng(-33.3980, -70.5960), cost: 1450.0),
    TollData(name: "Pórtico P8 - San Francisco de Asís", location: const LatLng(-33.3850, -70.5500), cost: 750.0),
    TollData(name: "Pórtico P9 - La Dehesa / Estoril", location: const LatLng(-33.3762, -70.5303), cost: 800.0),
    TollData(name: "Pórtico P10 - Padre Hurtado", location: const LatLng(-33.3880, -70.5400), cost: 500.0),
    TollData(name: "Pórtico P11 - Tabancura", location: const LatLng(-33.3830, -70.5280), cost: 600.0),
    TollData(name: "Pórtico Ramal Kennedy", location: const LatLng(-33.3980, -70.5750), cost: 1200.0),

    // --- AUTOPISTA CENTRAL (Eje Norte Sur y General Velásquez) ---
    TollData(name: "Pórtico P1 - Américo Vespucio Norte (Ruta 5)", location: const LatLng(-33.3642, -70.6974), cost: 750.0),
    TollData(name: "Pórtico P2 - 14 de la Fama", location: const LatLng(-33.3920, -70.6780), cost: 850.0),
    TollData(name: "Pórtico P3 - Domingo Santa María", location: const LatLng(-33.4080, -70.6700), cost: 650.0),
    TollData(name: "Pórtico P4 - Mapocho / Alameda", location: const LatLng(-33.4398, -70.6582), cost: 1200.0),
    TollData(name: "Pórtico P5 - Toesca / Rondizzoni", location: const LatLng(-33.4580, -70.6580), cost: 700.0),
    TollData(name: "Pórtico P6 - Carlos Valdovinos", location: const LatLng(-33.4830, -70.6610), cost: 950.0),
    TollData(name: "Pórtico P7 - Departamental", location: const LatLng(-33.5040, -70.6690), cost: 800.0),
    TollData(name: "Pórtico P8 - Américo Vespucio Sur (Ruta 5)", location: const LatLng(-33.5350, -70.6820), cost: 850.0),
    TollData(name: "Pórtico P9 - San Bernardo", location: const LatLng(-33.5800, -70.7020), cost: 650.0),
    // General Velasquez
    TollData(name: "Pórtico GV1 - Ruta 5 / Vespucio Norte", location: const LatLng(-33.3600, -70.7000), cost: 700.0),
    TollData(name: "Pórtico GV2 - Carrascal", location: const LatLng(-33.4250, -70.6950), cost: 900.0),
    TollData(name: "Pórtico GV3 - Ecuador / 5 de Abril", location: const LatLng(-33.4550, -70.6950), cost: 850.0),
    TollData(name: "Pórtico GV4 - Departamental", location: const LatLng(-33.5000, -70.6950), cost: 750.0),

    // --- VESPUCIO SUR ---
    TollData(name: "Pórtico VS1 - Ruta 78 / Cerrillos", location: const LatLng(-33.5250, -70.7300), cost: 650.0),
    TollData(name: "Pórtico VS2 - General Velásquez / Central", location: const LatLng(-33.5350, -70.6850), cost: 800.0),
    TollData(name: "Pórtico VS3 - Gran Avenida / Santa Rosa", location: const LatLng(-33.5412, -70.6441), cost: 600.0),
    TollData(name: "Pórtico VS4 - Vicuña Mackenna / Macul", location: const LatLng(-33.5135, -70.5950), cost: 550.0),
    TollData(name: "Pórtico VS5 - Quilín / Las Torres", location: const LatLng(-33.4900, -70.5750), cost: 700.0),
    TollData(name: "Pórtico VS6 - Grecia / Tobalaba", location: const LatLng(-33.4600, -70.5600), cost: 850.0),

    // --- VESPUCIO NORTE ---
    TollData(name: "Pórtico VN1 - Ruta 68 / Pudahuel", location: const LatLng(-33.4200, -70.7700), cost: 750.0),
    TollData(name: "Pórtico VN2 - San Pablo / Mapocho", location: const LatLng(-33.4000, -70.7600), cost: 600.0),
    TollData(name: "Pórtico VN3 - Costanera Norte / Aeropuerto", location: const LatLng(-33.3850, -70.7600), cost: 1100.0),
    TollData(name: "Pórtico VN4 - Lo Echevers", location: const LatLng(-33.3600, -70.7300), cost: 800.0),
    TollData(name: "Pórtico VN5 - Independencia / Ruta 5", location: const LatLng(-33.3645, -70.6900), cost: 700.0),
    TollData(name: "Pórtico VN6 - Pedro Fontova / Recoleta", location: const LatLng(-33.3685, -70.6540), cost: 650.0),
    TollData(name: "Pórtico VN7 - El Salto", location: const LatLng(-33.3750, -70.6200), cost: 850.0),
    
    // --- AUTOPISTA NORORIENTE / OTROS ---
    TollData(name: "Pórtico Nororiente - Chicureo", location: const LatLng(-33.3200, -70.6400), cost: 1500.0),
    TollData(name: "Pórtico Ruta 68 - Lo Prado", location: const LatLng(-33.4250, -70.8500), cost: 2400.0),
  ];
}