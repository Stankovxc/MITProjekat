import 'package:discover_herceg_novi/screens/admin/add_location_screen.dart';
import 'package:discover_herceg_novi/screens/admin/location_list_screen.dart';
import 'package:discover_herceg_novi/services/auth_service.dart';
import 'package:discover_herceg_novi/widgets/admin_option.dart';
import 'package:discover_herceg_novi/widgets/stat_card.dart';

import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    return FutureBuilder<String>(
      future: authService.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final String role = snapshot.data ?? 'guest';

        if (role == 'admin') {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Admin Panel"),
              backgroundColor: const Color(0xFF00A8CC),
              elevation: 0,
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00A8CC), Color(0xFFF4E3B2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Dobrodošla, Bojana",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        StatCard(
                          title: "Lokacije",
                          value: "12",
                          icon: Icons.map,
                        ),
                        const SizedBox(width: 15),
                        StatCard(
                          title: "Korisnici",
                          value: "45",
                          icon: Icons.people,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      "Upravljanje sadržajem",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Glavne akcije
                    AdminOption(
                      title: "Dodaj novu lokaciju",
                      subtitle: "Ubaci tvrđave, plaže ili restorane",
                      icon: Icons.add_location_alt,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddLocationScreen(),
                          ),
                        );
                      },
                    ),

                    AdminOption(
                      title: "Pregled svih lokacija",
                      subtitle: "Izmeni ili obriši postojeće podatke",
                      icon: Icons.edit_note,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageLocationsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Center(child: Text("Ogranicen pristup"));
        }
      },
    );
  }
}
