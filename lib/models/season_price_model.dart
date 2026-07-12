import 'package:cloud_firestore/cloud_firestore.dart';

class SeasonPriceModel {
  final String id;
  final String apartmentId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final double pricePerNight;
  final DateTime createdAt;

  const SeasonPriceModel({
    required this.id,
    required this.apartmentId,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.pricePerNight,
    required this.createdAt,
  });

  factory SeasonPriceModel.fromMap(Map<String, dynamic> data, String id) {
    return SeasonPriceModel(
      id: id,
      apartmentId: data['apartmentId'] ?? '',
      title: data['title'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      pricePerNight: (data['pricePerNight'] ?? 0).toDouble(),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'apartmentId': apartmentId,
      'title': title,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'pricePerNight': pricePerNight,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
