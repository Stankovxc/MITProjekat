import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final String title;
  final String category;

  const LocationCard({super.key, required this.title, required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(category),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // ovde će kasnije ići navigacija do detalja
        },
      ),
    );
  }
}
