import 'package:discover_herceg_novi/screens/splash/splash_screen.dart';
import 'package:discover_herceg_novi/services/main_wrapper.dart';
import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/admin/admin_dashboard.dart';

final Map<String, WidgetBuilder> AppRoutes = {
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const SignupScreen(),
  '/home': (context) => const MainWrapper(),
  '/splash': (context) => const SplashScreen(),
  '/admin': (context) => const AdminDashboard(),
};
