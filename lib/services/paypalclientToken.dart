import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uber_eats_consumer/constants.dart';
import 'package:uber_eats_consumer/model/paypalClientToken.dart';
import 'package:uber_eats_consumer/model/paypalSettingData.dart';

class PayPalClientTokenGen {
  static Future<PayPalClientTokenModel> paypalClientToken({
    required PaypalSettingData paypalSettingData,
  }) async {
    // final String userId = UserPreference.getUserId();
    // final String orderId = isTopup ? UserPreference.getPaymentId() : UserPreference.getOrderId();

    final url = "${GlobalURL}payments/paypalclientid";

    final response = await http.post(
      Uri.parse(url),
      body: {
        "environment": paypalSettingData.isLive ? "production" : "sandbox",
        "merchant_id": paypalSettingData.braintree_merchantid,
        "public_key": paypalSettingData.braintree_publickey,
        "private_key": paypalSettingData.braintree_privatekey,
      },
    );
    print(response.body);

    final data = jsonDecode(response.body);
    print(data);

    return PayPalClientTokenModel.fromJson(data);
  }

  static paypalSettleAmount({
    required nonceFromTheClient,
    required amount,
    required deviceDataFromTheClient,
    required PaypalSettingData paypalSettingData,
  }) async {
    final url = "${GlobalURL}payments/paypaltransaction";

    final response = await http.post(
      Uri.parse(url),
      body: {
        "environment": paypalSettingData.isLive ? "production" : "sandbox",
        "merchant_id": paypalSettingData.braintree_merchantid,
        "public_key": paypalSettingData.braintree_publickey,
        "private_key": paypalSettingData.braintree_privatekey,
        "nonceFromTheClient": nonceFromTheClient,
        "amount": amount,
        "deviceDataFromTheClient": deviceDataFromTheClient,
      },
    );

    final data = jsonDecode(response.body);

    return data; //PayPalClientSettleModel.fromJson(data);
  }
}
