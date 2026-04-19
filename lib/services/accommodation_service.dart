import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discover_herceg_novi/models/Apartmane_model.dart';

class ApartmanetService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<ApartmaneModel> getAccommodation(String id) {
    return _db.collection('apartmants').doc(id).snapshots().map((snap) {
      if (!snap.exists) {
        throw Exception("Dokument ne postoji u bazi!");
      }

      return ApartmaneModel.fromMap(snap.data()!, snap.id);
    });
  }
}
