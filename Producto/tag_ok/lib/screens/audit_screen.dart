import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/trip_history.dart';
import '../data/services/history_service.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HistoryService historyService = HistoryService();
    final Color bgColor = const Color(0xFF0F172A);
    final Color surfaceColor = const Color(0xFF1E293B);
    final Color textMain = const Color(0xFFF8FAFC);
    final Color textMuted = const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Historial de Viajes',
          style: TextStyle(color: textMain, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<TripHistory>>(
        stream: historyService.getTripHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(textMuted);
          }

          final trips = snapshot.data!;
          final double totalSpent = trips.fold(
            0,
            (sum, trip) => sum + trip.totalCost,
          );

          return StreamBuilder<double>(
            stream: historyService.getMonthlyLimit(),
          builder: (context, limitSnapshot) {
            // Si el límite aún no carga, no mostramos el cálculo para evitar parpadeos
            if (!limitSnapshot.hasData) {
              return const SizedBox.shrink();
            }

            final double monthlyLimit = limitSnapshot.data!;
            final double progress = (monthlyLimit > 0) 
                ? (totalSpent / monthlyLimit).clamp(0.0, 1.1) 
                : 0.0;

              return Column(
                children: [
                  _buildTotalSpentCard(
                    totalSpent,
                    trips.length,
                    progress,
                    monthlyLimit,
                    textMain,
                    textMuted,
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: trips.length,
                      itemBuilder: (context, index) {
                        return _buildTripCard(
                          context,
                          trips[index],
                          surfaceColor,
                          textMain,
                          textMuted,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTotalSpentCard(
    double total,
    int count,
    double progress,
    double limit,
    Color textMain,
    Color textMuted,
  ) {
    Color progressColor = const Color(0xFF4F46E5); // Violeta (Base)
    if (progress >= 1.0) {
      progressColor = Colors.redAccent; // Rojo (Excedido)
    } else if (progress >= 0.9) {
      progressColor = Colors.orangeAccent; // Naranja (Crítico)
    } else if (progress >= 0.75) {
      progressColor = Colors.yellowAccent; // Amarillo (Precaución)
    } else if (progress >= 0.5) {
      progressColor = const Color(0xFF10B981); // Verde/Cian (Mitad)
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gasto Mensual',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.speed, color: progressColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ \$${limit.toStringAsFixed(0)}',
                style: TextStyle(color: textMuted, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              color: progressColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Has usado el ${(progress * 100).round()}% de tu límite',
            style: TextStyle(
              color: progressColor.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textMuted) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: textMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay viajes registrados aún',
            style: TextStyle(color: textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(
    BuildContext context,
    TripHistory trip,
    Color surfaceColor,
    Color textMain,
    Color textMuted,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateFormat.format(trip.date),
                style: TextStyle(color: textMain, fontSize: 14),
              ),
              Text(
                '\$${trip.totalCost.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${trip.distanceKm.toStringAsFixed(1)} km • ${trip.tolls.length} pórticos',
                style: TextStyle(color: textMuted, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.directions_car_filled, color: textMuted, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    trip.vehicleName,
                    style: TextStyle(
                      color: textMuted.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0x1A000000),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  ...trip.tolls
                      .map(
                        (toll) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      toll.name,
                                      style: TextStyle(
                                        color: textMain,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'HH:mm',
                                      ).format(toll.timestamp),
                                      style: TextStyle(
                                        color: textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${toll.cost.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: textMain.withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
