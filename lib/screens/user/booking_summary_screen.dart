import 'package:discover_herceg_novi/models/reservation_model.dart';
import 'package:discover_herceg_novi/services/reservation_service.dart';
import 'package:discover_herceg_novi/services/stripe_payment_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class BookingSummaryScreen extends StatefulWidget {
  final String apartmentId;
  final String apartmentTitle;
  final DateTime checkIn;
  final DateTime checkOut;
  final int numberOfNights;
  final double pricePerNight;
  final double totalPrice;

  const BookingSummaryScreen({
    super.key,
    required this.apartmentId,
    required this.apartmentTitle,
    required this.checkIn,
    required this.checkOut,
    required this.numberOfNights,
    required this.pricePerNight,
    required this.totalPrice,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  final ReservationService _reservationService = ReservationService();
  final StripePaymentService _stripePaymentService = StripePaymentService();

  bool _isProcessingPayment = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Potvrda rezervacije')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildApartmentHeader(),

            const SizedBox(height: 24),

            _buildInfoCard(
              icon: Icons.login_rounded,
              title: 'Dolazak',
              value: _formatDate(widget.checkIn),
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.logout_rounded,
              title: 'Odlazak',
              value: _formatDate(widget.checkOut),
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.nights_stay_rounded,
              title: 'Broj noćenja',
              value: '${widget.numberOfNights}',
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.euro_rounded,
              title: 'Cijena po noćenju',
              value: '${widget.pricePerNight.toStringAsFixed(2)} €',
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.person_rounded,
              title: 'Korisnik',
              value: user?.email ?? 'Nepoznat korisnik',
            ),

            const SizedBox(height: 24),

            _buildTotalPriceCard(),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                icon: _isProcessingPayment
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.payment_rounded),
                label: Text(
                  _isProcessingPayment
                      ? 'OBRADA PLAĆANJA...'
                      : 'PLATI ${widget.totalPrice.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.blue.shade300,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isProcessingPayment ? null : _startPayment,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Plaćanje se obavlja u Stripe test režimu. '
                    'Neće biti naplaćen pravi novac.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startPayment() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Morate biti prijavljeni da biste izvršili rezervaciju.');
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    ReservationModel? pendingReservation;

    try {
      // 1. Ponovna provjera dostupnosti i kreiranje privremene rezervacije.
      pendingReservation = await _reservationService.createPendingReservation(
        apartmentId: widget.apartmentId,
        apartmentTitle: widget.apartmentTitle,
        checkIn: widget.checkIn,
        checkOut: widget.checkOut,
        pricePerNight: widget.pricePerNight,
        totalPrice: widget.totalPrice,
      );

      // 2. Stripe testno plaćanje.
      final paymentResult = await _stripePaymentService.makePayment(
        amount: widget.totalPrice,
        merchantDisplayName: 'Discover Herceg Novi',
      );

      // 3. Potvrđivanje rezervacije nakon uspješnog plaćanja.
      await _reservationService.confirmReservation(
        reservationId: pendingReservation.id,
        paymentIntentId: paymentResult.paymentIntentId,
      );

      if (!mounted) return;

      await _showSuccessDialog(
        bookingReference: pendingReservation.bookingReference,
      );

      if (!mounted) return;

      // Povratak na kalendar. Stream će automatski prikazati datume crveno.
      Navigator.pop(context, true);
    } on StripeException catch (error) {
      if (pendingReservation != null) {
        await _reservationService.cancelPendingReservation(
          pendingReservation.id,
        );
      }

      if (!mounted) return;

      final message = error.error.localizedMessage ?? 'Plaćanje je otkazano.';

      _showMessage(message);
    } catch (error) {
      if (pendingReservation != null) {
        await _reservationService.cancelPendingReservation(
          pendingReservation.id,
        );
      }

      if (!mounted) return;

      _showMessage(_cleanErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  Widget _buildApartmentHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.apartment_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rezervacija smještaja',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.apartmentTitle,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPriceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          const Text(
            'UKUPNO ZA PLAĆANJE',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.totalPrice.toStringAsFixed(2)} €',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.numberOfNights} noćenja × '
            '${widget.pricePerNight.toStringAsFixed(2)} €',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessDialog({required String bookingReference}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 64,
          ),
          title: const Text(
            'Rezervacija je potvrđena!',
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Plaćanje je uspješno.\n\n'
            'Broj rezervacije:\n$bookingReference',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('U redu'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _cleanErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day.$month.${date.year}.';
  }
}
