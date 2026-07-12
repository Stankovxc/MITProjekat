import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStats {
  final int locationsCount;
  final int usersCount;
  final int reservationsCount;
  final int confirmedReservationsCount;
  final int reservedNights;
  final double totalRevenue;

  const AdminStats({
    required this.locationsCount,
    required this.usersCount,
    required this.reservationsCount,
    required this.confirmedReservationsCount,
    required this.reservedNights,
    required this.totalRevenue,
  });
}

class AdminStatsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<AdminStats> getStats() {
    late StreamController<AdminStats> controller;

    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
    locationsSubscription;

    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? usersSubscription;

    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
    reservationsSubscription;

    QuerySnapshot<Map<String, dynamic>>? locationsSnapshot;
    QuerySnapshot<Map<String, dynamic>>? usersSnapshot;
    QuerySnapshot<Map<String, dynamic>>? reservationsSnapshot;

    void emitStats() {
      if (locationsSnapshot == null ||
          usersSnapshot == null ||
          reservationsSnapshot == null) {
        return;
      }

      int confirmedReservationsCount = 0;
      int reservedNights = 0;
      double totalRevenue = 0;

      for (final document in reservationsSnapshot!.docs) {
        final data = document.data();
        final status = data['status'] ?? '';

        if (status == 'confirmed') {
          confirmedReservationsCount++;

          reservedNights += (data['numberOfNights'] as num?)?.toInt() ?? 0;

          totalRevenue += (data['totalPrice'] as num?)?.toDouble() ?? 0;
        }
      }

      if (!controller.isClosed) {
        controller.add(
          AdminStats(
            locationsCount: locationsSnapshot!.docs.length,
            usersCount: usersSnapshot!.docs.length,
            reservationsCount: reservationsSnapshot!.docs.length,
            confirmedReservationsCount: confirmedReservationsCount,
            reservedNights: reservedNights,
            totalRevenue: totalRevenue,
          ),
        );
      }
    }

    controller = StreamController<AdminStats>(
      onListen: () {
        locationsSubscription = _db.collection('locations').snapshots().listen((
          snapshot,
        ) {
          locationsSnapshot = snapshot;
          emitStats();
        }, onError: controller.addError);

        usersSubscription = _db.collection('users').snapshots().listen((
          snapshot,
        ) {
          usersSnapshot = snapshot;
          emitStats();
        }, onError: controller.addError);

        reservationsSubscription = _db
            .collection('reservations')
            .snapshots()
            .listen((snapshot) {
              reservationsSnapshot = snapshot;
              emitStats();
            }, onError: controller.addError);
      },
      onCancel: () async {
        await locationsSubscription?.cancel();
        await usersSubscription?.cancel();
        await reservationsSubscription?.cancel();
      },
    );

    return controller.stream;
  }
}
