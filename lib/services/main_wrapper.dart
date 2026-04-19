import 'package:discover_herceg_novi/screens/admin/admin_dashboard.dart';
import 'package:discover_herceg_novi/screens/guest/apartment_screen.dart';
import 'package:discover_herceg_novi/screens/guest/home_screen.dart';
import 'package:flutter/material.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  String userRole = 'user'; // Početna vrednost
  bool isLoading = true;

  // Lista ekrana koje prikazujemo
  final List<Widget> _screens = [
    const HomeScreen(),
    const ApartmentDetailsScreen(accommodationId: "1"),
    const AdminDashboard(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF00A8CC), // Tvoja plava boja
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Početna'),
          BottomNavigationBarItem(
            icon: Icon(Icons.holiday_village),
            label: 'Apartment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}
