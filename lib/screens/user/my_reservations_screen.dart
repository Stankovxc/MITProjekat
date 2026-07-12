import 'package:discover_herceg_novi/models/reservation_model.dart';
import 'package:discover_herceg_novi/services/reservation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyReservationsScreen extends StatelessWidget {
  const MyReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Moje rezervacije')),
      body: user == null
          ? _buildNotLoggedInMessage()
          : StreamBuilder<List<ReservationModel>>(
              stream: ReservationService().getUserReservations(user.uid),
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
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: reservations.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 16);
                  },
                  itemBuilder: (context, index) {
                    return _buildReservationCard(context, reservations[index]);
                  },
                );
              },
            ),
    );
  }

  Widget _buildNotLoggedInMessage() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 72, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Morate biti prijavljeni da biste vidjeli svoje rezervacije.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 80,
              color: Colors.blue.shade300,
            ),
            const SizedBox(height: 18),
            const Text(
              'Još nemate rezervacija',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Kada rezervišete smještaj, rezervacija će se pojaviti ovdje.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationCard(
    BuildContext context,
    ReservationModel reservation,
  ) {
    final statusColor = _getStatusColor(reservation.status);
    final statusText = _getStatusText(reservation.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.apartmentTitle,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        reservation.bookingReference,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDateInfo(
                        title: 'DOLAZAK',
                        date: _formatDate(reservation.checkIn),
                        icon: Icons.login_rounded,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Expanded(
                      child: _buildDateInfo(
                        title: 'ODLAZAK',
                        date: _formatDate(reservation.checkOut),
                        icon: Icons.logout_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _buildDetailRow(
                  icon: Icons.nights_stay_rounded,
                  label: 'Broj noćenja',
                  value: '${reservation.numberOfNights}',
                ),

                const Divider(height: 24),

                _buildDetailRow(
                  icon: Icons.euro_rounded,
                  label: 'Ukupna cijena',
                  value:
                      '${reservation.totalPrice.toStringAsFixed(2)} ${reservation.currency}',
                ),

                const Divider(height: 24),

                _buildDetailRow(
                  icon: Icons.payment_rounded,
                  label: 'Plaćanje',
                  value: _getPaymentStatusText(reservation.paymentStatus),
                ),

                if (reservation.confirmedAt != null) ...[
                  const Divider(height: 24),
                  _buildDetailRow(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Potvrđeno',
                    value: _formatDateTime(reservation.confirmedAt!),
                  ),
                ],
                if (reservation.status == 'confirmed' &&
                    reservation.checkIn.isAfter(DateTime.now())) ...[
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'OTKAŽI REZERVACIJU',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _confirmCancellation(context, reservation);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo({
    required String title,
    required String date,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Future<void> _confirmCancellation(
    BuildContext context,
    ReservationModel reservation,
  ) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 54,
          ),
          title: const Text(
            'Otkazivanje rezervacije',
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Da li ste sigurni da želite da otkažete rezervaciju '
            '${reservation.bookingReference}?\n\n'
            'Rezervisani datumi će ponovo postati dostupni.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Ne'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Da, otkaži'),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) {
      return;
    }

    try {
      await ReservationService().cancelConfirmedReservation(reservation.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rezervacija je uspješno otkazana.')),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
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

  String _getPaymentStatusText(String paymentStatus) {
    switch (paymentStatus) {
      case 'paid':
        return 'Plaćeno';
      case 'unpaid':
        return 'Nije plaćeno';
      case 'failed':
        return 'Neuspješno';
      case 'refunded':
        return 'Refundirano';
      default:
        return paymentStatus;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day.$month.${date.year}.';
  }

  String _formatDateTime(DateTime date) {
    final formattedDate = _formatDate(date);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$formattedDate $hour:$minute';
  }
}
