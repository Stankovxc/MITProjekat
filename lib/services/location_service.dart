import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_model.dart';

class LocationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<LocationModel>> getLocations() {
    return _db.collection('locations').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return LocationModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<LocationModel>> getLocationsByCategory(String category) {
    return _db
        .collection('locations')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return LocationModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<void> addLocation(LocationModel location) async {
    try {
      await _db.collection('locations').add(location.toMap());
    } catch (e) {
      print("Greška pri dodavanju lokacije: $e");
      rethrow;
    }
  }
}
