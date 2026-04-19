import 'package:discover_herceg_novi/models/location_model.dart';
import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final LocationModel locationModel;

  const LocationCard({super.key, required this.locationModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),

        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            locationModel.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Text(locationModel.category),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // ovde će kasnije ići navigacija do detalja
          },
        ),
      ),
    );
  }
}
