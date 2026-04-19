import 'package:discover_herceg_novi/models/location_model.dart';
import 'package:discover_herceg_novi/services/auth_service.dart';
import 'package:discover_herceg_novi/services/location_service.dart';
import 'package:discover_herceg_novi/widgets/travel_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  String searchQuery = ""; // Čuva tekst koji korisnik kuca
  final TextEditingController _searchController = TextEditingController();
  bool isGuest = FirebaseAuth.instance.currentUser == null;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        "Where do\nyou want to go?",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (!isGuest) {
                          await authService.signOut();
                        }

                        if (!mounted) return;

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/splash',
                          (route) => false,
                        );
                      },
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          'https://via.placeholder.com/150',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Discover city",
                      border: InputBorder.none,
                      suffixIcon: Icon(Icons.tune, color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                const Text(
                  "Categories",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                if (!isGuest)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCategoryItem("All", Icons.all_inclusive),
                      _buildCategoryItem("Zabava", Icons.terrain),
                      _buildCategoryItem("Plaža", Icons.beach_access),
                      _buildCategoryItem("Kultura", Icons.park),
                      _buildCategoryItem("Restorani", Icons.location_city),
                    ],
                  ),
                const SizedBox(height: 30),

                const Text(
                  "Explore the City",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                SizedBox(
                  height: 250,
                  child: StreamBuilder<List<LocationModel>>(
                    stream: selectedCategory == 'All'
                        ? LocationService().getLocations()
                        : LocationService().getLocationsByCategory(
                            selectedCategory,
                          ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      List<LocationModel> locations = snapshot.data!;

                      if (searchQuery.isNotEmpty) {
                        locations = locations
                            .where(
                              (loc) =>
                                  loc.title.toLowerCase().contains(
                                    searchQuery,
                                  ) ||
                                  loc.category.toLowerCase().contains(
                                    searchQuery,
                                  ),
                            )
                            .toList();
                      }

                      if (locations.isEmpty) {
                        return const Center(
                          child: Text("Nema lokacija u ovoj kategoriji."),
                        );
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          return TravelCard(loc: locations[index]);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon) {
    bool isActive = selectedCategory == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label; // Menjamo kategoriju i UI se osvežava
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              // Menjamo boju kruga ako je aktivan
              color: isActive ? Colors.blue : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(icon, color: isActive ? Colors.white : Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
