import 'package:discover_herceg_novi/models/reservation_model.dart';
import 'package:discover_herceg_novi/services/reservation_service.dart';
import 'package:flutter/material.dart';

class AdminReservationsScreen extends StatelessWidget {
  const AdminReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sve rezervacije'),
        backgroundColor: const Color(0xFF00A8CC),
      ),
      body: StreamBuilder<List<ReservationModel>>(
        stream: ReservationService().getAllReservations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Greška pri učitavanju rezervacija:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final reservations = snapshot.data ?? [];

          if (reservations.isEmpty) {
            return const Center(
              child: Text(
                'Trenutno nema rezervacija.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            );
          }

          final confirmedReservations = reservations
              .where((reservation) => reservation.status == 'confirmed')
              .toList();

          final totalRevenue = confirmedReservations.fold<double>(
            0,
            (sum, reservation) => sum + reservation.totalPrice,
          );

          final totalNights = confirmedReservations.fold<int>(
            0,
            (sum, reservation) => sum + reservation.numberOfNights,
          );

          return Column(
            children: [
              _buildStatistics(
                totalReservations: reservations.length,
                confirmedReservations: confirmedReservations.length,
                totalRevenue: totalRevenue,
                totalNights: totalNights,
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: reservations.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 14);
                  },
                  itemBuilder: (context, index) {
                    return _buildReservationCard(context, reservations[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatistics({
    required int totalReservations,
    required int confirmedReservations,
    required double totalRevenue,
    required int totalNights,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF00A8CC).withOpacity(0.10),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildStatBox(
            title: 'Ukupno',
            value: '$totalReservations',
            icon: Icons.calendar_month,
          ),
          _buildStatBox(
            title: 'Potvrđene',
            value: '$confirmedReservations',
            icon: Icons.check_circle,
          ),
          _buildStatBox(
            title: 'Prihod',
            value: '${totalRevenue.toStringAsFixed(2)} €',
            icon: Icons.euro,
          ),
          _buildStatBox(
            title: 'Noćenja',
            value: '$totalNights',
            icon: Icons.nights_stay,
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 7, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00A8CC), size: 30),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildReservationCard(
    BuildContext context,
    ReservationModel reservation,
  ) {
    final statusColor = _getStatusColor(reservation.status);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        _showReservationDetails(context, reservation);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A8CC),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.apartment, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.apartmentTitle,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        reservation.bookingReference,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(reservation.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              reservation.customerName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 3),
            Text(
              reservation.userEmail,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_formatDate(reservation.checkIn)} - '
                    '${_formatDate(reservation.checkOut)}',
                  ),
                ),
                Text(
                  '${reservation.totalPrice.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00A8CC),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReservationDetails(
    BuildContext context,
    ReservationModel reservation,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Detalji rezervacije'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detail('Broj rezervacije', reservation.bookingReference),
                _detail('Gost', reservation.customerName),
                _detail('Email', reservation.userEmail),
                _detail('Dolazak', _formatDate(reservation.checkIn)),
                _detail('Odlazak', _formatDate(reservation.checkOut)),
                _detail('Broj noćenja', '${reservation.numberOfNights}'),
                _detail(
                  'Ukupna cijena',
                  '${reservation.totalPrice.toStringAsFixed(2)} €',
                ),
                _detail('Status', _getStatusText(reservation.status)),
                _detail('Plaćanje', reservation.paymentStatus),
                if (reservation.paymentIntentId != null)
                  _detail('Stripe PaymentIntent', reservation.paymentIntentId!),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Zatvori'),
            ),
          ],
        );
      },
    );
  }

  Widget _detail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'POTVRĐENA';
      case 'pending':
        return 'NA ČEKANJU';
      case 'cancelled':
        return 'OTKAZANA';
      case 'expired':
        return 'ISTEKLA';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day.$month.${date.year}.';
  }
}
