import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/guest/home_screen.dart';
import '../screens/user/profile_screen.dart';
import '../screens/admin/admin_dashboard.dart';

final Map<String, WidgetBuilder> AppRoutes = {
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const SignupScreen(),
  '/home': (context) => const HomeScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/admin': (context) => const AdminDashboard(),
};
