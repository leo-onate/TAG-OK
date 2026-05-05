import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../data/services/tollguru_service.dart';
import '../data/services/geocoding_service.dart';
import '../data/models/route_model.dart';
import '../utils/polyline_decoder.dart';

class RouteSetupScreen extends StatefulWidget {
  const RouteSetupScreen({super.key});

  @override
  State<RouteSetupScreen> createState() => _RouteSetupScreenState();
}

class _RouteSetupScreenState extends State<RouteSetupScreen> {
  // Colores del tema dark
  final Color bgColor = const Color(0xFF0F172A);
  final Color primaryColor = const Color(0xFF4F46E5);
  final Color textMain = const Color(0xFFF8FAFC);
  final Color textMuted = const Color(0xFF94A3B8);
  final Color inputBg = const Color(0x990F172A);
  final Color surfaceBorder = const Color(0x1AFFFFFF);
  final Color navBgColor = const Color(0xFF1E293B);

  String? _selectedVehicle = 'Vehiculo prueba';
  bool _isLoading = false;
  
  // Servicios
  final TollGuruService _tollGuruService = TollGuruService();
  final GeocodingService _geocodingService = GeocodingService();

  // Coordenadas seleccionadas
  LatLng? _originLocation;
  LatLng? _destinationLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textMuted),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Text(
                'Configurar Viaje',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Busca tu origen, destino y vehículo.',
                style: TextStyle(color: textMuted, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // 1. Buscador Origen
              _buildAutocompleteField(
                hintText: 'Ruta Origen (Buscar dirección...)',
                icon: Icons.my_location,
                iconColor: primaryColor,
                onSelected: (selection) {
                  setState(() {
                    _originLocation = selection.location;
                  });
                },
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
                child: Icon(Icons.more_vert, color: textMuted.withOpacity(0.5)),
              ),

              // 2. Buscador Destino
              _buildAutocompleteField(
                hintText: 'Ruta Destino (Buscar dirección...)',
                icon: Icons.location_on,
                iconColor: const Color(0xFF10B981),
                onSelected: (selection) {
                  setState(() {
                    _destinationLocation = selection.location;
                  });
                },
              ),
              
              const SizedBox(height: 32),

              // 3. Desplegable de Vehículo
              Text(
                '  Vehículo a utilizar',
                style: TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: surfaceBorder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.directions_car_outlined, color: textMuted),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedVehicle,
                          dropdownColor: bgColor,
                          icon: Icon(Icons.keyboard_arrow_down, color: textMuted),
                          style: TextStyle(color: textMain, fontSize: 16),
                          items: <String>['Vehiculo prueba'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedVehicle = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Botón Iniciar Viaje
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _iniciarViaje,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: Colors.transparent,
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Iniciar viaje',
                            style: TextStyle(
                              color: textMain,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.directions, color: textMain),
                        ],
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _iniciarViaje() async {
    if (_originLocation == null || _destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un Origen y Destino válidos.'),
          backgroundColor: Colors.orange,
        )
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final resultado = await _tollGuruService.calculateToll(
        origin: _originLocation!,
        destination: _destinationLocation!,
      );
      
      if (!mounted) return;
      
      // Procesar JSON
      Map<String, dynamic> routeObj;
      if (resultado.containsKey('routes') && (resultado['routes'] as List).isNotEmpty) {
        routeObj = resultado['routes'][0];
      } else {
        routeObj = resultado;
      }

      final polylineStr = routeObj['polyline'] as String? ?? '';
      final costsObj = routeObj['costs'] as Map<String, dynamic>? ?? {};
      final tollsList = routeObj['tolls'] as List? ?? [];
      final summaryObj = routeObj['summary'] as Map<String, dynamic>? ?? {};

      // Decodificar polyline
      final decodedPolyline = PolylineDecoder.decode(polylineStr);

      // Decodificar tolls
      final List<TollData> parsedTolls = [];
      for (var t in tollsList) {
        if (t is Map<String, dynamic>) {
          final lat = t['lat'];
          final lng = t['lng'];
          final name = t['name'] ?? 'Pórtico';
          final cost = (t['tagCost'] ?? t['cashCost'] ?? 0).toDouble();
          
          if (lat != null && lng != null) {
            parsedTolls.add(TollData(
              location: LatLng(lat, lng),
              name: name,
              cost: cost,
            ));
          }
        }
      }

      // Costo total
      final totalCost = (costsObj['tagAndCash'] ?? costsObj['minimumTollCost'] ?? 0).toDouble();
      
      // Distancia y tiempo
      final distanceObj = summaryObj['distance'] as Map<String, dynamic>? ?? {};
      final durationObj = summaryObj['duration'] as Map<String, dynamic>? ?? {};
      
      final distanceKm = ((distanceObj['value'] ?? 0) / 1000).toDouble();
      final durationText = durationObj['text'] ?? 'Desconocido';

      final routeData = RouteData(
        polyline: decodedPolyline,
        tolls: parsedTolls,
        totalCost: totalCost,
        distanceKm: distanceKm,
        durationText: durationText,
      );

      // Retornar datos a la pantalla anterior (HomeScreen)
      Navigator.pop(context, routeData);
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        )
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildAutocompleteField({
    required String hintText,
    required IconData icon,
    required Color iconColor,
    required Function(PlaceSuggestion) onSelected,
  }) {
    return Autocomplete<PlaceSuggestion>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<PlaceSuggestion>.empty();
        }
        // Llamar a Mapbox API
        return await _geocodingService.searchPlaces(textEditingValue.text);
      },
      onSelected: onSelected,
      displayStringForOption: (PlaceSuggestion option) => option.address,
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return Container(
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: surfaceBorder),
          ),
          child: TextField(
            controller: textEditingController,
            focusNode: focusNode,
            style: TextStyle(color: textMain),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: textMuted.withOpacity(0.7)),
              prefixIcon: Icon(icon, color: iconColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            color: navBgColor, // Color oscuro para el desplegable
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 48, // Ajustar al padding
              height: 200,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final PlaceSuggestion option = options.elementAt(index);
                  return ListTile(
                    leading: const Icon(Icons.location_city, color: Colors.white54),
                    title: Text(
                      option.address,
                      style: TextStyle(color: textMain, fontSize: 14),
                    ),
                    onTap: () {
                      onSelected(option);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
