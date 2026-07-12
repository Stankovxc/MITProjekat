import 'package:discover_herceg_novi/models/reservation_model.dart';
import 'package:discover_herceg_novi/services/reservation_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:discover_herceg_novi/screens/user/booking_summary_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:discover_herceg_novi/models/season_price_model.dart';
import 'package:discover_herceg_novi/services/season_price_service.dart';
import 'package:discover_herceg_novi/services/auth_service.dart';

class AvailabilityCalendarScreen extends StatefulWidget {
  final String apartmentId;
  final String apartmentTitle;
  final double pricePerNight;

  final String imageUrl;
  final double rating;
  final int capacity;
  final bool hasWifi;

  const AvailabilityCalendarScreen({
    super.key,
    required this.apartmentId,
    required this.apartmentTitle,
    required this.pricePerNight,
    required this.imageUrl,
    required this.rating,
    required this.capacity,
    required this.hasWifi,
  });

  @override
  State<AvailabilityCalendarScreen> createState() =>
      _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState
    extends State<AvailabilityCalendarScreen> {
  final ReservationService _reservationService = ReservationService();

  final SeasonPriceService _seasonPriceService = SeasonPriceService();

  late final Stream<List<ReservationModel>> _reservationsStream;

  late final Stream<List<SeasonPriceModel>> _seasonPricesStream;

  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();

    _reservationsStream = _reservationService.getApartmentReservations(
      widget.apartmentId,
    );

    _seasonPricesStream = _seasonPriceService.getSeasonPrices(
      widget.apartmentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dostupnost smještaja')),
      body: StreamBuilder<List<ReservationModel>>(
        stream: _reservationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Greška pri učitavanju rezervacija: ${snapshot.error}',
              ),
            );
          }

          final reservations = snapshot.data ?? [];

          return StreamBuilder<List<SeasonPriceModel>>(
            stream: _seasonPricesStream,
            builder: (context, priceSnapshot) {
              if (priceSnapshot.connectionState == ConnectionState.waiting &&
                  !priceSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (priceSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Greška pri učitavanju cijena: ${priceSnapshot.error}',
                  ),
                );
              }

              final seasonPrices = priceSnapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Image.network(
                              widget.imageUrl,
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.apartmentTitle,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 15),

                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber),

                                    const SizedBox(width: 5),

                                    Text(
                                      widget.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const Spacer(),

                                    const Icon(Icons.people),

                                    Text(" ${widget.capacity} osobe"),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.wifi,
                                      color: widget.hasWifi
                                          ? Colors.green
                                          : Colors.grey,
                                    ),

                                    const SizedBox(width: 6),

                                    Text(
                                      widget.hasWifi
                                          ? "WiFi uključen"
                                          : "Bez WiFi",
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.euro,
                                        color: Colors.blue,
                                      ),

                                      const SizedBox(width: 8),

                                      Text(
                                        "${widget.pricePerNight.toStringAsFixed(2)} € / noć",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),
                      child: _buildLegend(),
                    ),

                    const SizedBox(height: 16),

                    TableCalendar(
                      rowHeight: 58,
                      firstDay: DateTime.now(),
                      lastDay: DateTime(DateTime.now().year + 2, 12, 31),
                      focusedDay: _focusedDay,
                      rangeStartDay: _rangeStart,
                      rangeEndDay: _rangeEnd,
                      rangeSelectionMode: RangeSelectionMode.toggledOn,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Mjesec',
                      },
                      enabledDayPredicate: (day) {
                        return !_isReservedDay(day, reservations);
                      },
                      onRangeSelected: (start, end, focusedDay) {
                        setState(() {
                          _rangeStart = start;
                          _rangeEnd = end;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          if (_isReservedDay(day, reservations)) {
                            return _buildDayCell(
                              day: day,
                              price: _getDayPrice(day, seasonPrices),
                              backgroundColor: Colors.red.shade400,
                              textColor: Colors.white,
                            );
                          }

                          return _buildDayCell(
                            day: day,
                            price: _getDayPrice(day, seasonPrices),
                            backgroundColor: Colors.green.shade100,
                            textColor: Colors.black,
                          );
                        },
                        todayBuilder: (context, day, focusedDay) {
                          if (_isReservedDay(day, reservations)) {
                            return _buildDayCell(
                              day: day,
                              price: _getDayPrice(day, seasonPrices),
                              backgroundColor: Colors.red.shade400,
                              textColor: Colors.white,
                              borderColor: Colors.blue,
                            );
                          }

                          return _buildDayCell(
                            day: day,
                            price: _getDayPrice(day, seasonPrices),
                            backgroundColor: Colors.green.shade100,
                            textColor: Colors.black,
                            borderColor: Colors.blue,
                          );
                        },
                        disabledBuilder: (context, day, focusedDay) {
                          final isReserved = _isReservedDay(day, reservations);

                          return _buildDayCell(
                            day: day,
                            price: _getDayPrice(day, seasonPrices),
                            backgroundColor: isReserved
                                ? Colors.red.shade400
                                : Colors.grey.shade300,
                            textColor: isReserved
                                ? Colors.white
                                : Colors.grey.shade600,
                          );
                        },
                        rangeStartBuilder: (context, day, focusedDay) {
                          return _buildDayCell(
                            day: day,
                            price: _getDayPrice(day, seasonPrices),
                            backgroundColor: Colors.blue,
                            textColor: Colors.white,
                          );
                        },
                        rangeEndBuilder: (context, day, focusedDay) {
                          return _buildDayCell(
                            day: day,
                            price: _getDayPrice(day, seasonPrices),
                            backgroundColor: Colors.blue,
                            textColor: Colors.white,
                          );
                        },
                        withinRangeBuilder: (context, day, focusedDay) {
                          return _buildDayCell(
                            day: day,
                            price: _getDayPrice(day, seasonPrices),
                            backgroundColor: Colors.blue.shade100,
                            textColor: Colors.black,
                          );
                        },
                      ),
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        rangeHighlightColor: Colors.transparent,
                        cellMargin: const EdgeInsets.all(5),
                        weekendTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        defaultTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                        weekendStyle: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        leftChevronIcon: const Icon(
                          Icons.chevron_left_rounded,
                          size: 32,
                        ),
                        rightChevronIcon: const Icon(
                          Icons.chevron_right_rounded,
                          size: 32,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildReservationSummary(reservations, seasonPrices),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 18,
      runSpacing: 10,
      children: [
        _legendItem(color: Colors.green.shade100, label: 'Slobodno'),
        _legendItem(color: Colors.red.shade400, label: 'Rezervisano'),
        _legendItem(color: Colors.blue.shade100, label: 'Izabrani period'),
        _legendItem(color: Colors.grey.shade300, label: 'Nedostupno'),
      ],
    );
  }

  Widget _legendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }

  double _getDayPrice(DateTime day, List<SeasonPriceModel> seasonPrices) {
    return _seasonPriceService.getPriceForDate(
      date: day,
      basePrice: widget.pricePerNight,
      seasonPrices: seasonPrices,
    );
  }

  Widget _buildDayCell({
    required DateTime day,
    required double price,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${price.toStringAsFixed(0)}€',
            style: TextStyle(
              color: textColor,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationSummary(
    List<ReservationModel> reservations,
    List<SeasonPriceModel> seasonPrices,
  ) {
    if (_rangeStart == null || _rangeEnd == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
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
          children: [
            Icon(
              Icons.date_range_rounded,
              size: 42,
              color: Colors.blue.shade400,
            ),
            const SizedBox(height: 10),
            const Text(
              'Izaberite period boravka',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Prvo izaberite datum dolaska, a zatim datum odlaska.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    final nights = _rangeEnd!.difference(_rangeStart!).inDays;
    final totalPrice = _seasonPriceService.calculateTotalPrice(
      checkIn: _rangeStart!,
      checkOut: _rangeEnd!,
      basePrice: widget.pricePerNight,
      seasonPrices: seasonPrices,
    );

    final averagePricePerNight = nights > 0
        ? totalPrice / nights
        : widget.pricePerNight;
    final periodAvailable = _isSelectedPeriodAvailable(reservations);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: periodAvailable ? Colors.blue.shade100 : Colors.red.shade200,
        ),
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
          const Text(
            'Pregled rezervacije',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _buildDateBox(
                  icon: Icons.login_rounded,
                  title: 'DOLAZAK',
                  date: _formatDate(_rangeStart!),
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
                child: _buildDateBox(
                  icon: Icons.logout_rounded,
                  title: 'ODLAZAK',
                  date: _formatDate(_rangeEnd!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.nights_stay_rounded, color: Colors.blue),
                const SizedBox(width: 10),
                const Text(
                  'Broj noćenja',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  '$nights',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.euro_rounded, color: Colors.blue),
                const SizedBox(width: 10),
                const Text(
                  'Cijena po noći',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  'Prosjek ${averagePricePerNight.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: periodAvailable ? Colors.blue.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'UKUPNO',
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${totalPrice.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: periodAvailable
                        ? Colors.blue.shade700
                        : Colors.red.shade700,
                  ),
                ),
                Text(
                  '$nights noćenja',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          if (!periodAvailable) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Izabrani period sadrži rezervisane datume.',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text(
                'REZERVIŠI ODMAH',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: periodAvailable
                  ? () async {
                      final user = FirebaseAuth.instance.currentUser;

                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Morate se prijaviti da biste nastavili sa rezervacijom.',
                            ),
                          ),
                        );
                        return;
                      }

                      final role = await AuthService().getUserRole();
                      if (role == 'admin') {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Administratorski nalog ne može praviti rezervacije.',
                            ),
                          ),
                        );
                        return;
                      }

                      final reservationCompleted = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingSummaryScreen(
                            apartmentId: widget.apartmentId,
                            apartmentTitle: widget.apartmentTitle,
                            checkIn: _rangeStart!,
                            checkOut: _rangeEnd!,
                            numberOfNights: nights,
                            pricePerNight: averagePricePerNight,
                            totalPrice: totalPrice,
                          ),
                        ),
                      );

                      if (reservationCompleted == true && mounted) {
                        setState(() {
                          _rangeStart = null;
                          _rangeEnd = null;
                        });
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox({
    required IconData icon,
    required String title,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            date,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  bool _isReservedDay(DateTime day, List<ReservationModel> reservations) {
    final normalizedDay = _dateOnly(day);

    for (final reservation in reservations) {
      final checkIn = _dateOnly(reservation.checkIn);
      final checkOut = _dateOnly(reservation.checkOut);

      final belongsToReservation =
          !normalizedDay.isBefore(checkIn) && normalizedDay.isBefore(checkOut);

      if (belongsToReservation) {
        return true;
      }
    }

    return false;
  }

  bool _isSelectedPeriodAvailable(List<ReservationModel> reservations) {
    if (_rangeStart == null || _rangeEnd == null) {
      return false;
    }

    final selectedStart = _dateOnly(_rangeStart!);
    final selectedEnd = _dateOnly(_rangeEnd!);

    for (final reservation in reservations) {
      final existingStart = _dateOnly(reservation.checkIn);
      final existingEnd = _dateOnly(reservation.checkOut);

      final overlaps =
          selectedStart.isBefore(existingEnd) &&
          selectedEnd.isAfter(existingStart);

      if (overlaps) {
        return false;
      }
    }

    return true;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day.$month.${date.year}.';
  }
}
