import 'package:discover_herceg_novi/models/Apartmane_model.dart';
import 'package:discover_herceg_novi/services/accommodation_service.dart';
import 'package:flutter/material.dart';

class ApartmentDetailsScreen extends StatelessWidget {
  final String accommodationId;

  const ApartmentDetailsScreen({super.key, required this.accommodationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalji smeštaja")),
      body: StreamBuilder<ApartmaneModel>(
        stream: ApartmanetService().getAccommodation(accommodationId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Smeštaj nije pronađen."));
          }

          final stan = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  stan.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stan.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${stan.pricePerNight}€ po noćenju",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Opis:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(stan.description),
                      const SizedBox(height: 20),

                      // Pogodnosti
                      Row(
                        children: [
                          if (stan.hasWifi)
                            const Icon(Icons.wifi, color: Colors.green),
                          const SizedBox(width: 10),
                          const Icon(Icons.person),
                          Text(" do ${stan.capacity} osobe"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
