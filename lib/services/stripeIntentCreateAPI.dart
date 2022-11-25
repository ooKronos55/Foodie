import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uber_eats_consumer/constants.dart';
import 'package:uber_eats_consumer/model/stripeIntentModel.dart';

class StripeCreateIntent {
  static Future<StripeCreateIntentModel> stripeCreateIntent({
    required currency,
    required amount,
    required stripesecret,
  }) async {
    final url = "${GlobalURL}payments/stripepaymentintent";

    final response = await http.post(
      Uri.parse(url),
      body: {
        "currency": currency,
        "stripesecret": stripesecret,
        "amount": amount,
      },
    );
    print(response.body);

    final data = jsonDecode(response.body);
    return StripeCreateIntentModel.fromJson(data); //PayPalClientSettleModel.fromJson(data);
  }
}
