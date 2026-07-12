import 'package:discover_herceg_novi/screens/admin/admin_dashboard.dart';
import 'package:discover_herceg_novi/screens/guest/apartment_screen.dart';
import 'package:discover_herceg_novi/screens/guest/home_screen.dart';
import 'package:discover_herceg_novi/screens/user/my_reservations_screen.dart';
import 'package:discover_herceg_novi/services/auth_service.dart';
import 'package:flutter/material.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  final AuthService _authService = AuthService();

  int _selectedIndex = 0;
  String userRole = 'guest';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await _authService.getUserRole();

    if (!mounted) return;

    setState(() {
      userRole = role;
      isLoading = false;
    });
  }

  List<Widget> get _screens {
    if (userRole == 'admin') {
      return const [
        HomeScreen(),
        ApartmentDetailsScreen(accommodationId: '1'),
        AdminDashboard(),
      ];
    }

    return const [
      HomeScreen(),
      ApartmentDetailsScreen(accommodationId: '1'),
      MyReservationsScreen(),
    ];
  }

  List<BottomNavigationBarItem> get _navigationItems {
    if (userRole == 'admin') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Početna',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.holiday_village_rounded),
          label: 'Apartman',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_rounded),
          label: 'Admin',
        ),
      ];
    }

    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Početna'),
      BottomNavigationBarItem(
        icon: Icon(Icons.holiday_village_rounded),
        label: 'Apartman',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_rounded),
        label: 'Rezervacije',
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF00A8CC),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: _navigationItems,
      ),
    );
  }
}
