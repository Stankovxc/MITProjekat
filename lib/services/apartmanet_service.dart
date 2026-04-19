import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discover_herceg_novi/models/Apartmane_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> rateApartment(String apartmentId, int newRating) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentReference docRef = _db.collection('apartmants').doc(apartmentId);

    return _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);

      List<String> ratedUsers = List<String>.from(snapshot['ratedUsers'] ?? []);
      if (ratedUsers.contains(user.uid)) {
        throw Exception("Već ste ocenili ovaj smeštaj!");
      }

      int totalRatings = snapshot['totalRatings'] ?? 0;
      double sumOfRatings = (snapshot['sumOfRatings'] ?? 0.0).toDouble();

      int newTotal = totalRatings + 1;
      double newSum = sumOfRatings + newRating;
      double newAverage = newSum / newTotal;

      transaction.update(docRef, {
        'totalRatings': newTotal,
        'sumOfRatings': newSum,
        'rating': double.parse(newAverage.toStringAsFixed(1)),
        'ratedUsers': FieldValue.arrayUnion([user.uid]),
      });
    });
  }
}
