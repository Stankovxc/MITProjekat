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
                  'Discover Herceg Novi',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    LocationCard(
                      title: 'Tvrđava Forte Mare',
                      category: 'Znamenitost',
                    ),
                    LocationCard(title: 'Plaža Zanjice', category: 'Plaža'),
                    LocationCard(
                      title: 'Restoran Portun',
                      category: 'Restoran',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
