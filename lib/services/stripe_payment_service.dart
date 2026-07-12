import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripePaymentResult {
  final String paymentIntentId;

  const StripePaymentResult({required this.paymentIntentId});
}

class StripePaymentService {
  static const String _baseUrl = 'http://10.69.161.120:3000';

  Future<StripePaymentResult> makePayment({
    required double amount,
    required String merchantDisplayName,
  }) async {
    final amountInCents = (amount * 100).round();

    final response = await http.post(
      Uri.parse('$_baseUrl/create-payment-intent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amountInCents, 'currency': 'eur'}),
    );

    if (response.statusCode != 200) {
      final responseBody = jsonDecode(response.body);

      throw Exception(
        responseBody['error'] ?? 'Nije moguće pokrenuti plaćanje.',
      );
    }

    final responseBody = jsonDecode(response.body);

    final clientSecret = responseBody['clientSecret'] as String?;
    final paymentIntentId = responseBody['paymentIntentId'] as String?;

    if (clientSecret == null || paymentIntentId == null) {
      throw Exception(
        'Server nije vratio potrebne podatke za Stripe plaćanje.',
      );
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: merchantDisplayName,
      ),
    );

    await Stripe.instance.presentPaymentSheet();

    return StripePaymentResult(paymentIntentId: paymentIntentId);
  }
}
