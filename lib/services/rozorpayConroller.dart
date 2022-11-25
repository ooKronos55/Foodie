import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uber_eats_consumer/constants.dart';
import 'package:uber_eats_consumer/model/createRazorPayOrderModel.dart';
import 'package:uber_eats_consumer/model/razorpayKeyModel.dart';
import 'package:uber_eats_consumer/userPrefrence.dart';

class RazorPayController {
  Future<CreateRazorPayOrderModel?> createOrderRazorPay({required int amount, bool isTopup = false}) async {
    final String orderId = isTopup ? UserPreference.getPaymentId() : UserPreference.getOrderId();
    RazorPayModel razorPayData = UserPreference.getRazorPayData();
    print(razorPayData.razorpayKey);
    print("we Enter In");
    final url = "${GlobalURL}payments/razorpay/createorder";
    print(orderId);
    final response = await http.post(
      Uri.parse(url),
      body: {
        "amount": (amount * 100).toString(),
        "receipt_id": orderId,
        "currency": currencyData?.code,
        "razorpaykey": razorPayData.razorpayKey,
        "razorPaySecret": razorPayData.razorpaySecret,
        "isSandBoxEnabled": razorPayData.isSandboxEnabled.toString(),
      },
    );
    print(response);

    if (response.statusCode == 500) {
      return null;
    } else {
      final data = jsonDecode(response.body);
      print(data);

      return CreateRazorPayOrderModel.fromJson(data);
    }
  }
}
