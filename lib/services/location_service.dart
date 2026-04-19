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

  Future<void> deleteLocation(String id) async {
    try {
      await _db.collection('locations').doc(id).delete();
    } catch (e) {
      print("Greška pri brisanju: $e");
      rethrow;
    }
  }

  Future<void> updateLocation(LocationModel location) async {
    try {
      await _db
          .collection('locations')
          .doc(location.id)
          .update(location.toMap());
    } catch (e) {
      print("Greška pri izmeni: $e");
      rethrow;
    }
  }
}
