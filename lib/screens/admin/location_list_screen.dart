import 'package:flutter/material.dart';
import '../../models/location_model.dart';
import '../../services/location_service.dart';
import './edit_location_screen.dart'; // Napravićemo ga u sledećem koraku

class ManageLocationsScreen extends StatelessWidget {
  const ManageLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upravljanje lokacijama")),
      body: StreamBuilder<List<LocationModel>>(
        stream: LocationService().getLocations(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final locations = snapshot.data!;

          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final loc = locations[index];
              return ListTile(
                leading: Image.network(
                  loc.imageUrl,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported),
                ),
                title: Text(loc.title),
                subtitle: Text(loc.category),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditLocationScreen(location: loc),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, loc),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, LocationModel loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Obriši lokaciju?"),
        content: Text("Da li ste sigurni da želite obrisati ${loc.title}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Odustani"),
          ),
          TextButton(
            onPressed: () async {
              await LocationService().deleteLocation(loc.id);
              Navigator.pop(context);
            },
            child: const Text("Obriši", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
