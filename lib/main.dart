import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const DiscoverHercegNoviApp());
}

class DiscoverHercegNoviApp extends StatelessWidget {
  const DiscoverHercegNoviApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discover Herceg Novi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/splash',
      routes: AppRoutes,
    );
  }
}
