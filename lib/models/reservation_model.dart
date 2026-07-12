import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String id;

  final String apartmentId;
  final String apartmentTitle;

  final String userId;
  final String userEmail;
  final String customerName;

  final DateTime checkIn;
  final DateTime checkOut;
  final int numberOfNights;

  final double pricePerNight;
  final double totalPrice;
  final String currency;

  final String status;
  final String paymentStatus;

  final String? paymentIntentId;

  final String bookingReference;

  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? expiresAt;

  ReservationModel({
    required this.id,
    required this.apartmentId,
    required this.apartmentTitle,
    required this.userId,
    required this.userEmail,
    required this.customerName,
    required this.checkIn,
    required this.checkOut,
    required this.numberOfNights,
    required this.pricePerNight,
    required this.totalPrice,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    required this.bookingReference,
    required this.createdAt,
    this.paymentIntentId,
    this.confirmedAt,
    this.expiresAt,
  });

  factory ReservationModel.fromMap(Map<String, dynamic> data, String id) {
    return ReservationModel(
      id: id,
      apartmentId: data['apartmentId'] ?? '',
      apartmentTitle: data['apartmentTitle'] ?? '',
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      customerName: data['customerName'] ?? '',
      checkIn: _timestampToDate(data['checkIn']),
      checkOut: _timestampToDate(data['checkOut']),
      numberOfNights: data['numberOfNights'] ?? 0,
      pricePerNight: (data['pricePerNight'] ?? 0).toDouble(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'EUR',
      status: data['status'] ?? 'pending',
      paymentStatus: data['paymentStatus'] ?? 'unpaid',
      paymentIntentId: data['paymentIntentId'],
      bookingReference: data['bookingReference'] ?? '',
      createdAt: _timestampToDate(data['createdAt']),
      confirmedAt: data['confirmedAt'] == null
          ? null
          : _timestampToDate(data['confirmedAt']),
      expiresAt: data['expiresAt'] == null
          ? null
          : _timestampToDate(data['expiresAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'apartmentId': apartmentId,
      'apartmentTitle': apartmentTitle,
      'userId': userId,
      'userEmail': userEmail,
      'customerName': customerName,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'numberOfNights': numberOfNights,
      'pricePerNight': pricePerNight,
      'totalPrice': totalPrice,
      'currency': currency,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentIntentId': paymentIntentId,
      'bookingReference': bookingReference,
      'createdAt': Timestamp.fromDate(createdAt),
      'confirmedAt': confirmedAt == null
          ? null
          : Timestamp.fromDate(confirmedAt!),
      'expiresAt': expiresAt == null ? null : Timestamp.fromDate(expiresAt!),
    };
  }

  static DateTime _timestampToDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }
}
