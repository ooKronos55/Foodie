import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uber_eats_consumer/model/CurrencyModel.dart';
import 'package:uber_eats_consumer/model/VendorModel.dart';

import 'model/TaxModel.dart';

const FINISHED_ON_BOARDING = 'finishedOnBoarding';
const COLOR_ACCENT = 0xFF8fd468;
const COLOR_PRIMARY_DARK = 0xFF683A;
var COLOR_PRIMARY = 0xFFFF683A;
const FACEBOOK_BUTTON_COLOR = 0xFF415893;
const DARK_COLOR = 0xff191A1C;
const DARK_VIEWBG_COLOR = 0xff191A1C;
const DARK_CARD_BG_COLOR = 0xff242528;
const DARK_BG_COLOR = 0xff121212;
const COUPON_BG_COLOR = 0xFFFCF8F3;
const COUPON_DASH_COLOR = 0xFFCACFDA;
const GREY_TEXT_COLOR = 0xff5E5C5C;
const DARK_GREY_TEXT_COLOR = 0xff9F9F9F;

const MENU_ITEM = 'menu_items';
const USERS = 'users';
const CHANNEL_PARTICIPATION = 'channel_participation';
const CHANNELS = 'channels';
const THREAD = 'thread';
const REPORTS = 'reports';
const Deliverycharge = 6;
const CATEGORIES = 'vendor_categories';
const VENDORS = 'vendors';
const PRODUCTS = 'vendor_products';
const ORDERS = 'restaurant_orders';
const ORDERS_TABLE = 'booked_table';
const COUPONS = "coupons";
const SECOND_MILLIS = 1000;
const MINUTE_MILLIS = 60 * SECOND_MILLIS;
const HOUR_MILLIS = 60 * MINUTE_MILLIS;
const SERVER_KEY =
    'Replace with your Server key';
const GOOGLE_API_KEY = 'Replace with your API key';

const ORDER_STATUS_PLACED = 'Order Placed';
const ORDER_STATUS_ACCEPTED = 'Order Accepted';
const ORDER_STATUS_REJECTED = 'Order Rejected';
const ORDER_STATUS_DRIVER_PENDING = 'Driver Pending';
const ORDER_STATUS_DRIVER_REJECTED = 'Driver Rejected';
const ORDER_STATUS_SHIPPED = 'Order Shipped';
const ORDER_STATUS_IN_TRANSIT = 'In Transit';
const ORDER_STATUS_COMPLETED = 'Order Completed';
const ORDERREQUEST = 'Order';
const BOOKREQUEST = 'TableBook';

const STRIPE_CURRENCY_CODE = 'USD';
const PAYMENT_SERVER_URL = 'https://murmuring-caverns-94283.herokuapp.com/';

const STRIPE_PUBLISHABLE_KEY =
    '';

const PAYSTACK_KEY = "";

String mercadoPublicKey = "";
String mercadoAccessToken = "";

const USER_ROLE_DRIVER = 'driver';
const USER_ROLE_CUSTOMER = 'customer';
const VENDORS_CATEGORIES = 'vendor_categories';
const Order_Rating = 'foods_review';
const CONTACT_US = 'ContactUs';
const COUPON = 'coupons';
const Wallet = "wallet";

const Setting = 'settings';
const StripeSetting = 'stripeSettings';
const FavouriteRestaurant = "favorite_restaurant";

const COD = 'CODSettings';

const GlobalURL = "Replace with your web";

const Currency = 'currencies';
String symbol = '';
bool isRight = false;
bool isDineInEnable = false;
int decimal = 0;
String currName = "";
CurrencyModel? currencyData;
List<VendorModel> allstoreList = [];

bool isRazorPayEnabled = false;
bool isRazorPaySandboxEnabled = false;
String razorpayKey = "";
String razorpaySecret = "";

String placeholderImage =
    'https://firebasestorage.googleapis.com/v0/b/foodies-3c1d9.appspot.com/o/images%2Fplace_holder.png?alt=media&token=f391844e-0f04-44ed-bf37-e6a1c7d91020';

double getDoubleVal(dynamic input) {
  if (input == null) {
    return 0.1;
  }

  if (input is int) {
    return double.parse(input.toString());
  }

  if (input is double) {
    return input;
  }
  return 0.1;
}

double getTaxValue(TaxModel? taxModel, double amount) {
  double taxVal = 0;
  if (taxModel != null && taxModel.tax != null && taxModel.tax! > 0) {
    if (taxModel.type == "fix") {
      taxVal = taxModel.tax!.toDouble();
    } else {
      taxVal = (amount * taxModel.tax!.toDouble()) / 100;
    }
  }
  return double.parse(taxVal.toStringAsFixed(2));
}

Uri createCoordinatesUrl(double latitude, double longitude, [String? label]) {
  var uri;
  if (kIsWeb) {
    uri = Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': '$latitude,$longitude'});
  } else if (Platform.isAndroid) {
    var query = '$latitude,$longitude';
    if (label != null) query += '($label)';
    uri = Uri(scheme: 'geo', host: '0,0', queryParameters: {'q': query});
  } else if (Platform.isIOS) {
    var params = {'ll': '$latitude,$longitude'};
    if (label != null) params['q'] = label;
    uri = Uri.https('maps.apple.com', '/', params);
  } else {
    uri = Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': '$latitude,$longitude'});
  }

  return uri;
}

String getKm(Position pos1, Position pos2) {
  double distanceInMeters = Geolocator.distanceBetween(pos1.latitude, pos1.longitude, pos2.latitude, pos2.longitude);
  double kilometer = distanceInMeters / 1000;
  print("KiloMeter$kilometer");
  return kilometer.toStringAsFixed(2).toString();
}

String getImageVAlidUrl(String url) {
  String imageUrl = placeholderImage;
  if (url != null && url.isNotEmpty) {
    imageUrl = url;
  }
  return imageUrl;
}
