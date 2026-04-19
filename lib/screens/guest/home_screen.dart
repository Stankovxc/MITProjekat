import 'package:discover_herceg_novi/models/location_model.dart';
import 'package:discover_herceg_novi/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:discover_herceg_novi/widgets/location_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00A8CC), Color(0xFFF4E3B2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Istraži Herceg Novi",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<LocationModel>>(
                  stream: LocationService().getLocations(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("Nema pronađenih lokacija."),
                      );
                    }

                    final locations = snapshot.data!;

                    return ListView.builder(
                      itemCount: locations.length,
                      itemBuilder: (context, index) {
                        final loc = locations[index];
                        return LocationCard(locationModel: loc);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
