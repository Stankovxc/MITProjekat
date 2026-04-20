import 'package:discover_herceg_novi/models/Apartmane_model.dart';
import 'package:discover_herceg_novi/services/apartmanet_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    Text(
                      "${stan.rating} (${stan.totalRatings} ocena)",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text("Ostavi svoju ocenu:"),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < 3 ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () async {
                        if (FirebaseAuth.instance.currentUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Samo ulogovani korisnici mogu ocenjivati!",
                              ),
                            ),
                          );
                          return;
                        }
                        try {
                          await ApartmanetService().rateApartment(
                            stan.id,
                            index + 1,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Hvala na oceni!")),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Već ste ocenili ovaj smeštaj!"),
                            ),
                          );
                        }
                      },
                    );
                  }),
                ),
                prikazMape(stan),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget prikazMape(ApartmaneModel stan) {
    // Koordinate stana
    final pozicijaStana = LatLng(
      stan.position.latitude,
      stan.position.longitude,
    );

    return Container(
      height: 250,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.hardEdge,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: pozicijaStana,
          initialZoom: 15.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag
                .all, //  .none Ovo onemogućava pomeranje mape prstom ako želiš da bude statična
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.discover_herceg_novi',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: pozicijaStana,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
