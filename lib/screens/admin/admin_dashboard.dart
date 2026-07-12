import 'package:discover_herceg_novi/screens/admin/add_location_screen.dart';
import 'package:discover_herceg_novi/screens/admin/admin_reservations_screen.dart';
import 'package:discover_herceg_novi/screens/admin/location_list_screen.dart';
import 'package:discover_herceg_novi/services/admin_stats_service.dart';
import 'package:discover_herceg_novi/services/auth_service.dart';
import 'package:discover_herceg_novi/widgets/admin_option.dart';
import 'package:discover_herceg_novi/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:discover_herceg_novi/screens/admin/admin_season_prices_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return FutureBuilder<String>(
      future: authService.getUserRole(),
      builder: (context, roleSnapshot) {
        if (roleSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = roleSnapshot.data ?? 'guest';

        if (role != 'admin') {
          return const Scaffold(
            body: Center(
              child: Text(
                'Ograničen pristup',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Admin Panel'),
            backgroundColor: const Color(0xFF00A8CC),
            elevation: 0,
          ),
          body: StreamBuilder<AdminStats>(
            stream: AdminStatsService().getStats(),
            builder: (context, statsSnapshot) {
              if (statsSnapshot.connectionState == ConnectionState.waiting &&
                  !statsSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (statsSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Greška pri učitavanju statistike:\n'
                      '${statsSnapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final stats =
                  statsSnapshot.data ??
                  const AdminStats(
                    locationsCount: 0,
                    usersCount: 0,
                    reservationsCount: 0,
                    confirmedReservationsCount: 0,
                    reservedNights: 0,
                    totalRevenue: 0,
                  );

              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00A8CC), Color(0xFFF4E3B2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dobrodošla, Bojana 👋',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Pregled poslovanja i upravljanje aplikacijom',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Statistika',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: 'Lokacije',
                              value: '${stats.locationsCount}',
                              icon: Icons.map_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              title: 'Korisnici',
                              value: '${stats.usersCount}',
                              icon: Icons.people_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: 'Rezervacije',
                              value: '${stats.reservationsCount}',
                              icon: Icons.calendar_month_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              title: 'Potvrđene',
                              value: '${stats.confirmedReservationsCount}',
                              icon: Icons.check_circle_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: 'Prihod',
                              value:
                                  '${stats.totalRevenue.toStringAsFixed(2)} €',
                              icon: Icons.euro_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              title: 'Noćenja',
                              value: '${stats.reservedNights}',
                              icon: Icons.nights_stay_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        'Upravljanje sadržajem',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 18),

                      AdminOption(
                        title: 'Dodaj novu lokaciju',
                        subtitle: 'Ubaci tvrđave, plaže ili restorane',
                        icon: Icons.add_location_alt_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddLocationScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      AdminOption(
                        title: 'Pregled svih lokacija',
                        subtitle: 'Izmijeni ili obriši postojeće podatke',
                        icon: Icons.edit_note_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ManageLocationsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      AdminOption(
                        title: 'Pregled rezervacija',
                        subtitle: 'Pregled gostiju, termina, cijena i plaćanja',
                        icon: Icons.calendar_month_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminReservationsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      AdminOption(
                        title: 'Upravljanje cijenama',
                        subtitle: 'Definiši sezonske cijene apartmana',
                        icon: Icons.price_change_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminSeasonPricesScreen(
                                apartmentId: '1',
                                basePrice: 50,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
