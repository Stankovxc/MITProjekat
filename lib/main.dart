import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey =
      'pk_test_51TrmQbHpXF8621nFUBCySAjTVq4MiMsWaZ4VqNWwfTl03lvsAdsS79BVMutcw0uO11AEy47OoadbwErMpccsavjo00oGSS8cIS';

  await Stripe.instance.applySettings();

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
