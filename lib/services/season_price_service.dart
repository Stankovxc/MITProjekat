import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discover_herceg_novi/models/season_price_model.dart';

class SeasonPriceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<SeasonPriceModel>> getSeasonPrices(String apartmentId) {
    return _db
        .collection('season_prices')
        .where('apartmentId', isEqualTo: apartmentId)
        .snapshots()
        .map((snapshot) {
          final prices = snapshot.docs
              .map((doc) => SeasonPriceModel.fromMap(doc.data(), doc.id))
              .toList();

          prices.sort(
            (first, second) => first.startDate.compareTo(second.startDate),
          );

          return prices;
        });
  }

  Future<void> addSeasonPrice({
    required String apartmentId,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required double pricePerNight,
  }) async {
    if (endDate.isBefore(startDate)) {
      throw Exception('Krajnji datum mora biti poslije početnog datuma.');
    }

    if (pricePerNight <= 0) {
      throw Exception('Cijena mora biti veća od nule.');
    }

    final existingPrices = await _db
        .collection('season_prices')
        .where('apartmentId', isEqualTo: apartmentId)
        .get();

    final newStart = _dateOnly(startDate);
    final newEnd = _dateOnly(endDate);

    for (final document in existingPrices.docs) {
      final existing = SeasonPriceModel.fromMap(document.data(), document.id);

      final existingStart = _dateOnly(existing.startDate);
      final existingEnd = _dateOnly(existing.endDate);

      final overlaps =
          !newStart.isAfter(existingEnd) && !newEnd.isBefore(existingStart);

      if (overlaps) {
        throw Exception(
          'Izabrani period se preklapa sa postojećim cjenovnikom.',
        );
      }
    }

    final documentReference = _db.collection('season_prices').doc();

    final seasonPrice = SeasonPriceModel(
      id: documentReference.id,
      apartmentId: apartmentId,
      title: title,
      startDate: _dateOnly(startDate),
      endDate: _dateOnly(endDate),
      pricePerNight: pricePerNight,
      createdAt: DateTime.now(),
    );

    await documentReference.set(seasonPrice.toMap());
  }

  Future<void> deleteSeasonPrice(String id) async {
    await _db.collection('season_prices').doc(id).delete();
  }

  double getPriceForDate({
    required DateTime date,
    required double basePrice,
    required List<SeasonPriceModel> seasonPrices,
  }) {
    final normalizedDate = _dateOnly(date);

    for (final season in seasonPrices) {
      final start = _dateOnly(season.startDate);
      final end = _dateOnly(season.endDate);

      final belongsToPeriod =
          !normalizedDate.isBefore(start) && !normalizedDate.isAfter(end);

      if (belongsToPeriod) {
        return season.pricePerNight;
      }
    }

    return basePrice;
  }

  double calculateTotalPrice({
    required DateTime checkIn,
    required DateTime checkOut,
    required double basePrice,
    required List<SeasonPriceModel> seasonPrices,
  }) {
    double total = 0;
    DateTime currentDate = _dateOnly(checkIn);
    final normalizedCheckOut = _dateOnly(checkOut);

    while (currentDate.isBefore(normalizedCheckOut)) {
      total += getPriceForDate(
        date: currentDate,
        basePrice: basePrice,
        seasonPrices: seasonPrices,
      );

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return total;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
