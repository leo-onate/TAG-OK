import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip_history.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? 'anonymous';

  Future<void> saveTrip(TripHistory trip) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(_userId)
          .collection('trips')
          .add(trip.toMap());
    } catch (e) {
      print('Error saving trip: $e');
      rethrow;
    }
  }

  Future<void> updateMonthlyLimit(double limit) async {
    await _firestore.collection('usuarios').doc(_userId).set({
      'limite_presupuesto_mensual': limit.toInt(),
    }, SetOptions(merge: true));
  }

  Stream<double> getMonthlyLimit() {
    return _firestore.collection('usuarios').doc(_userId).snapshots().map((doc) {
      if (doc.exists && doc.data()!.containsKey('limite_presupuesto_mensual')) {
        final val = doc.data()!['limite_presupuesto_mensual'];
        if (val is num) return val.toDouble();
      }
      return 50000.0; // Valor por defecto
    });
  }

  Stream<List<TripHistory>> getTripHistory() {
    return _firestore
        .collection('usuarios')
        .doc(_userId)
        .collection('trips')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TripHistory.fromFirestore(doc)).toList();
    });
  }
}
