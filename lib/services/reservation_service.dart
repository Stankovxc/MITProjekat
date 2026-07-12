import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discover_herceg_novi/models/reservation_model.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

class ReservationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ReservationModel>> getApartmentReservations(String apartmentId) {
    return _db
        .collection('reservations')
        .where('apartmentId', isEqualTo: apartmentId)
        .snapshots()
        .map((snapshot) {
          final reservations = snapshot.docs
              .map((doc) => ReservationModel.fromMap(doc.data(), doc.id))
              .where((reservation) => reservation.status == 'confirmed')
              .toList();

          reservations.sort(
            (first, second) => first.checkIn.compareTo(second.checkIn),
          );

          return reservations;
        });
  }

  Stream<List<ReservationModel>> getUserReservations(String userId) {
    return _db
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final reservations = snapshot.docs
              .map((doc) => ReservationModel.fromMap(doc.data(), doc.id))
              .toList();

          reservations.sort(
            (first, second) => second.createdAt.compareTo(first.createdAt),
          );

          return reservations;
        });
  }

  Stream<List<ReservationModel>> getAllReservations() {
    return _db.collection('reservations').snapshots().map((snapshot) {
      final reservations = snapshot.docs
          .map((doc) => ReservationModel.fromMap(doc.data(), doc.id))
          .toList();

      reservations.sort(
        (first, second) => second.createdAt.compareTo(first.createdAt),
      );

      return reservations;
    });
  }

  Future<bool> isPeriodAvailable({
    required String apartmentId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    if (!checkOut.isAfter(checkIn)) {
      return false;
    }

    final normalizedCheckIn = _dateOnly(checkIn);
    final normalizedCheckOut = _dateOnly(checkOut);

    final snapshot = await _db
        .collection('reservations')
        .where('apartmentId', isEqualTo: apartmentId)
        .get();

    for (final doc in snapshot.docs) {
      final reservation = ReservationModel.fromMap(doc.data(), doc.id);

      if (reservation.status != 'confirmed') {
        continue;
      }

      final existingCheckIn = _dateOnly(reservation.checkIn);
      final existingCheckOut = _dateOnly(reservation.checkOut);

      final periodsOverlap =
          normalizedCheckIn.isBefore(existingCheckOut) &&
          normalizedCheckOut.isAfter(existingCheckIn);

      if (periodsOverlap) {
        return false;
      }
    }

    return true;
  }

  Future<ReservationModel> createPendingReservation({
    required String apartmentId,
    required String apartmentTitle,
    required DateTime checkIn,
    required DateTime checkOut,
    required double pricePerNight,
    required double totalPrice,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Korisnik nije prijavljen.');
    }

    final available = await isPeriodAvailable(
      apartmentId: apartmentId,
      checkIn: checkIn,
      checkOut: checkOut,
    );

    if (!available) {
      throw Exception('Izabrani period više nije dostupan.');
    }

    final documentReference = _db.collection('reservations').doc();

    final now = DateTime.now();
    final numberOfNights = checkOut.difference(checkIn).inDays;

    final reservation = ReservationModel(
      id: documentReference.id,
      apartmentId: apartmentId,
      apartmentTitle: apartmentTitle,
      userId: user.uid,
      userEmail: user.email ?? '',
      customerName: user.displayName ?? user.email ?? 'Korisnik',
      checkIn: _dateOnly(checkIn),
      checkOut: _dateOnly(checkOut),
      numberOfNights: numberOfNights,
      pricePerNight: pricePerNight,
      totalPrice: totalPrice,
      currency: 'EUR',
      status: 'pending',
      paymentStatus: 'unpaid',
      paymentIntentId: null,
      bookingReference: _generateBookingReference(),
      createdAt: now,
      confirmedAt: null,
      expiresAt: now.add(const Duration(minutes: 10)),
    );

    await documentReference.set(reservation.toMap());

    return reservation;
  }

  Future<void> confirmReservation({
    required String reservationId,
    required String paymentIntentId,
  }) async {
    final documentReference = _db.collection('reservations').doc(reservationId);

    await documentReference.update({
      'status': 'confirmed',
      'paymentStatus': 'paid',
      'paymentIntentId': paymentIntentId,
      'confirmedAt': Timestamp.now(),
      'expiresAt': null,
    });
  }

  Future<void> cancelPendingReservation(String reservationId) async {
    final documentReference = _db.collection('reservations').doc(reservationId);

    final snapshot = await documentReference.get();

    if (!snapshot.exists) {
      return;
    }

    final data = snapshot.data();

    if (data == null) {
      return;
    }

    if (data['status'] == 'pending') {
      await documentReference.update({
        'status': 'cancelled',
        'paymentStatus': 'failed',
        'expiresAt': null,
      });
    }
  }

  Future<void> cancelConfirmedReservation(String reservationId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Korisnik nije prijavljen.');
    }

    final documentReference = _db.collection('reservations').doc(reservationId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(documentReference);

      if (!snapshot.exists) {
        throw Exception('Rezervacija ne postoji.');
      }

      final data = snapshot.data();

      if (data == null) {
        throw Exception('Podaci rezervacije nisu dostupni.');
      }

      final reservationUserId = data['userId'] ?? '';
      final status = data['status'] ?? '';

      if (reservationUserId != user.uid) {
        throw Exception('Nemate dozvolu da otkažete ovu rezervaciju.');
      }

      if (status != 'confirmed') {
        throw Exception('Samo potvrđena rezervacija može biti otkazana.');
      }

      transaction.update(documentReference, {
        'status': 'cancelled',
        'cancelledAt': Timestamp.now(),
      });
    });
  }

  String _generateBookingReference() {
    final now = DateTime.now();
    final random = Random();

    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    final randomPart = random.nextInt(9999).toString().padLeft(4, '0');

    return 'HN-$year$month$day-$randomPart';
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
