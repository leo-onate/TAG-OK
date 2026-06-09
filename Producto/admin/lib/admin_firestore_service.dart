import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOverview {
  const AdminOverview({
    required this.users,
    required this.vehicles,
    required this.porticos,
    required this.tariffs,
    required this.alerts,
  });

  final int users;
  final int vehicles;
  final int porticos;
  final int tariffs;
  final int alerts;
}

class AdminFirestoreService {
  AdminFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<AdminOverview> fetchOverview() async {
    final results = await Future.wait([
      _count('usuarios'),
      _count('vehiculos'),
      _count('porticos'),
      _count('tarifas'),
      _count('alertas'),
    ]);

    return AdminOverview(
      users: results[0],
      vehicles: results[1],
      porticos: results[2],
      tariffs: results[3],
      alerts: results[4],
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamUsers() {
    return _firestore.collection('usuarios').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamPorticos() {
    return _firestore.collection('porticos').snapshots();
  }

  // Usa collectionGroup para obtener todos los "trips" sin importar de qué usuario sean
  Stream<QuerySnapshot<Map<String, dynamic>>> streamTrips() {
    return _firestore.collectionGroup('trips').snapshots();
  }

  Future<int> _count(String collection) async {
    final snapshot = await _firestore.collection(collection).get();
    return snapshot.size;
  }
}