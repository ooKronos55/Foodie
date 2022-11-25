import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;
import 'package:uber_eats_consumer/main.dart';
import 'package:uber_eats_consumer/model/AddressModel.dart';
import 'package:uber_eats_consumer/model/BannerModel.dart';
import 'package:uber_eats_consumer/model/BlockUserModel.dart';
import 'package:uber_eats_consumer/model/BookTableModel.dart';
import 'package:uber_eats_consumer/model/ChannelParticipation.dart';
import 'package:uber_eats_consumer/model/ChatModel.dart';
import 'package:uber_eats_consumer/model/ChatVideoContainer.dart';
import 'package:uber_eats_consumer/model/CodModel.dart';
import 'package:uber_eats_consumer/model/ConversationModel.dart';
import 'package:uber_eats_consumer/model/CuisineModel.dart';
import 'package:uber_eats_consumer/model/CurrencyModel.dart';
import 'package:uber_eats_consumer/model/DeliveryChargeModel.dart';
import 'package:uber_eats_consumer/model/FavouriteModel.dart';
import 'package:uber_eats_consumer/model/FlutterWaveSettingDataModel.dart';
import 'package:uber_eats_consumer/model/HomeConversationModel.dart';
import 'package:uber_eats_consumer/model/MercadoPagoSettingsModel.dart';
import 'package:uber_eats_consumer/model/MessageData.dart';
import 'package:uber_eats_consumer/model/OrderModel.dart';
import 'package:uber_eats_consumer/model/PayFastSettingData.dart';
import 'package:uber_eats_consumer/model/PayStackSettingsModel.dart';
import 'package:uber_eats_consumer/model/ProductModel.dart';
import 'package:uber_eats_consumer/model/Ratingmodel.dart';
import 'package:uber_eats_consumer/model/User.dart';
import 'package:uber_eats_consumer/model/VendorCategoryModel.dart';
import 'package:uber_eats_consumer/model/VendorModel.dart';
import 'package:uber_eats_consumer/model/offer_model.dart';
import 'package:uber_eats_consumer/model/paypalSettingData.dart';
import 'package:uber_eats_consumer/model/paytmSettingData.dart';
import 'package:uber_eats_consumer/model/razorpayKeyModel.dart';
import 'package:uber_eats_consumer/model/stripeKey.dart';
import 'package:uber_eats_consumer/model/stripeSettingData.dart';
import 'package:uber_eats_consumer/model/topupTranHistory.dart';
import 'package:uber_eats_consumer/services/helper.dart';
import 'package:uber_eats_consumer/ui/reauthScreen/reauth_user_screen.dart';
import 'package:uber_eats_consumer/userPrefrence.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../constants.dart';
import '../model/TaxModel.dart';

class FireStoreUtils {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static Reference storage = FirebaseStorage.instance.ref();
  StreamSubscription? ordersStreamSub;
  StreamController<List<OrderModel>>? ordersStreamController;
  List<BlockUserModel> blockedList = [];
  StreamSubscription? offerStreamSub;
  StreamController<List<OfferModel>>? offerStreamController;
  late StreamSubscription vendorStreamSub;
  StreamController<List<VendorModel>>? vendorStreamController;
  StreamController<List<VendorModel>>? allResaturantStreamController;
  late StreamController<List<VendorModel>> allDineInResaturantStreamController;
  StreamController<List<VendorModel>>? newArrivalStreamController;
  late StreamController<List<VendorModel>> popularStreamController;
  late StreamController<List<VendorModel>> cusionStreamController;
  late StreamController<List<ProductModel>> productStreamController;
  late StreamController<List<ProductModel>> productStreamController123;
  late StreamController<List<FavouriteModel>> favouriteStreamControleer;
  late StreamSubscription favouriteStreamSub;
  final geo = Geoflutterfire();
  List<VendorModel> vendors1 = [];
  double radiusValue = 0.0;

  static Future<User?> getCurrentUser(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument = await firestore.collection(USERS).doc(uid).get();
    if (userDocument.data() != null && userDocument.exists) {
      return User.fromJson(userDocument.data()!);
    } else {
      return null;
    }
  }

  // Future<void> _showNotificationCustomSound() async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //   AndroidNotificationDetails(
  //     'your other channel id',
  //     'your other channel name',
  //     channelDescription: 'your other channel description',
  //     sound: RawResourceAndroidNotificationSound('slow_spring_board'),
  //   );
  //   const IOSNotificationDetails iOSPlatformChannelSpecifics =
  //   IOSNotificationDetails(sound: 'slow_spring_board.aiff');
  //   const MacOSNotificationDetails macOSPlatformChannelSpecifics =
  //   MacOSNotificationDetails(sound: 'slow_spring_board.aiff');
  //   final LinuxNotificationDetails linuxPlatformChannelSpecifics =
  //   LinuxNotificationDetails(
  //     sound: AssetsLinuxSound('sound/slow_spring_board.mp3'),
  //   );
  //   final NotificationDetails platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //     iOS: iOSPlatformChannelSpecifics,
  //     macOS: macOSPlatformChannelSpecifics,
  //     linux: linuxPlatformChannelSpecifics,
  //   );
  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'custom sound notification title',
  //     'custom sound notification body',
  //     platformChannelSpecifics,
  //   );
  // }

  static Future<bool> sendFcmMessage(String title, String message, String Token, String reqType) async {
    try {
      var url = 'https://fcm.googleapis.com/fcm/send';
      var header = {
        "Content-Type": "application/json",
        "Authorization": "key=$SERVER_KEY",
      };
      var request = {
        "notification": {
          "title": title,
          "body": message,
          "sound": "default",
          // "color": COLOR_PRIMARY,
        },
        "priority": "high",
        'data': <String, dynamic>{'click_action': 'FLUTTER_NOTIFICATION_CLICK', 'id': '1', 'status': 'done', 'reqtype': '$reqType'},
        "to": Token
      };

      var client = new http.Client();
      var response = await client.post(Uri.parse(url), headers: header, body: json.encode(request));
      print('done........ ');
      return true;
    } catch (e, s) {
      print(e);
      return false;
    }
  }

  Future<TaxModel?> getTaxSetting() async {
    DocumentSnapshot<Map<String, dynamic>> taxQuery = await firestore.collection(Setting).doc('taxSetting').get();
    if (taxQuery.data() != null) {
      return TaxModel.fromJson(taxQuery.data()!);
    }

    return null;
  }

  Future<String> uploadProductImage(File image, String progress) async {
    var uniqueID = Uuid().v4();
    Reference upload = storage.child('flutter/uberEats/productImages/$uniqueID'
        '.png');
    UploadTask uploadTask = upload.putFile(image);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress('{} \n{} / {}KB'.tr(args: [
        progress,
        '${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)}',
        '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
      ]));
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      print((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<User?> updateCurrentUser(User user) async {
    //UserPreference.setUserId(userID: user.userID);
    return await firestore.collection(USERS).doc(user.userID).set(user.toJson()).then((document) {
      return user;
    });
  }

  static Future<void> updateCurrentUserAddress(AddressModel userAddress) async {
    //UserPreference.setUserId(userID: user.userID);
    return await firestore.collection(USERS).doc(MyAppState.currentUser!.userID).update(
      {"shippingAddress": userAddress.toJson()},
    ).then((document) {
      print("AAADDDDDD");
    });
  }

  static Future<ProductModel?> updateProduct(ProductModel prodduct) async {
    return await firestore.collection(PRODUCTS).doc(prodduct.id).set(prodduct.toJson()).then((document) {
      return prodduct;
    });
  }

  static Future<VendorModel?> updateVendor(VendorModel vendor) async {
    return await firestore.collection(VENDORS).doc(vendor.id).set(vendor.toJson()).then((document) {
      return vendor;
    });
  }

  static Future<String> uploadUserImageToFireStorage(File image, String userID) async {
    Reference upload = storage.child('images/$userID.png');

    UploadTask uploadTask = upload.putFile(image);
    var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  Future<Url> uploadChatImageToFireStorage(File image, BuildContext context) async {
    showProgress(context, 'Uploading image...', false);
    var uniqueID = Uuid().v4();
    Reference upload = storage.child('images/$uniqueID.png');
    File compressedImage = await compressImage(image);
    UploadTask uploadTask = upload.putFile(compressedImage);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress('Uploading image ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
          'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      print((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return Url(mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  Future<ChatVideoContainer> uploadChatVideoToFireStorage(File video, BuildContext context) async {
    showProgress(context, 'Uploading video...', false);
    var uniqueID = Uuid().v4();
    Reference upload = storage.child('videos/$uniqueID.mp4');
    File compressedVideo = await _compressVideo(video);
    SettableMetadata metadata = SettableMetadata(contentType: 'video');
    UploadTask uploadTask = upload.putFile(compressedVideo, metadata);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress('Uploading video ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
          'KB');
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    final uint8list = await VideoThumbnail.thumbnailFile(
        video: downloadUrl, thumbnailPath: (await getTemporaryDirectory()).path, imageFormat: ImageFormat.PNG);
    final file = File(uint8list ?? '');
    String thumbnailDownloadUrl = await uploadVideoThumbnailToFireStorage(file);
    hideProgress();
    return ChatVideoContainer(
        videoUrl: Url(url: downloadUrl.toString(), mime: metaData.contentType ?? 'video'), thumbnailUrl: thumbnailDownloadUrl);
  }

  Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    var uniqueID = Uuid().v4();
    Reference upload = storage.child('thumbnails/$uniqueID.png');
    File compressedImage = await compressImage(file);
    UploadTask uploadTask = upload.putFile(compressedImage);
    var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  Stream<User> getUserByID(String id) async* {
    StreamController<User> userStreamController = StreamController();
    firestore.collection(USERS).doc(id).snapshots().listen((user) {
      try {
        User userModel = User.fromJson(user.data() ?? {});
        userStreamController.sink.add(userModel);
      } catch (e) {
        print('FireStoreUtils.getUserByID failed to parse user object ${user.id}');
      }
    });
    yield* userStreamController.stream;
  }

  Stream<StripeKeyModel> getStripe() async* {
    // ignore: close_sinks
    StreamController<StripeKeyModel> stripeStreamController = StreamController();
    firestore.collection(Setting).doc(StripeSetting).snapshots().listen((user) {
      try {
        StripeKeyModel userModel = StripeKeyModel.fromJson(user.data() ?? {});
        stripeStreamController.sink.add(userModel);
      } catch (e) {
        print('FireStoreUtils.getUserByID failed to parse user object ${user.id}');
      }
    });
    yield* stripeStreamController.stream;
  }

  static getPayFastSettingData() async {
    firestore.collection(Setting).doc("payFastSettings").get().then((payFastData) {
      print(payFastData.data().toString());
      try {
        PayFastSettingData payFastSettingData = PayFastSettingData.fromJson(payFastData.data() ?? {});
        print(payFastData);
        UserPreference.setPayFastData(payFastSettingData);
      } catch (error) {
        print("error>>>122");
        print(error.toString());
      }
    });
  }

  static getMercadoPagoSettingData() async {
    firestore.collection(Setting).doc("MercadoPago").get().then((mercadoPago) {
      print(mercadoPago.data());
      try {
        MercadoPagoSettingData mercadoPagoDataModel = MercadoPagoSettingData.fromJson(mercadoPago.data() ?? {});
        UserPreference.setMercadoPago(mercadoPagoDataModel);
      } catch (error) {
        print(error.toString());
      }
    });
  }

  static getPaypalSettingData() async {
    firestore.collection(Setting).doc("paypalSettings").get().then((paypalData) {
      try {
        PaypalSettingData paypalDataModel = PaypalSettingData.fromJson(paypalData.data() ?? {});
        UserPreference.setPayPalData(paypalDataModel);
      } catch (error) {
        print(error.toString());
      }
    });
  }

  static getStripeSettingData() async {
    firestore.collection(Setting).doc("stripeSettings").get().then((stripeData) {
      try {
        StripeSettingData stripeSettingData = StripeSettingData.fromJson(stripeData.data() ?? {});
        UserPreference.setStripeData(stripeSettingData);
      } catch (error) {
        print(error.toString());
      }
    });
  }

  static getFlutterWaveSettingData() async {
    firestore.collection(Setting).doc("flutterWave").get().then((flutterWaveData) {
      print("FlutterWave____>>>12");
      print(flutterWaveData.data().toString());
      try {
        FlutterWaveSettingData flutterWaveSettingData = FlutterWaveSettingData.fromJson(flutterWaveData.data() ?? {});
        print("____>>>121");
        print(flutterWaveData);
        UserPreference.setFlutterWaveData(flutterWaveSettingData);
      } catch (error) {
        print("error>>>122");
        print(error.toString());
      }
    });
  }

  static getPayStackSettingData() async {
    firestore.collection(Setting).doc("payStack").get().then((payStackData) {
      print("PayStack____>>>12");
      print(payStackData);
      try {
        PayStackSettingData payStackSettingData = PayStackSettingData.fromJson(payStackData.data() ?? {});
        print("____>>>122");
        print(payStackSettingData);
        UserPreference.setPayStackData(payStackSettingData);
      } catch (error) {
        print("error>>>122");
        print(error.toString());
      }
    });
  }

  static getPaytmSettingData() async {
    firestore.collection(Setting).doc("PaytmSettings").get().then((paytmData) {
      try {
        PaytmSettingData paytmSettingData = PaytmSettingData.fromJson(paytmData.data() ?? {});
        UserPreference.setPaytmData(paytmSettingData);
      } catch (error) {
        print(error.toString());
      }
    });
  }

  static getWalletSettingData() {
    firestore.collection(Setting).doc('walletSettings').get().then((walletSetting) {
      try {
        bool walletEnable = walletSetting.data()!['isEnabled'];
        UserPreference.setWalletData(walletEnable);
      } catch (e) {
        print(e.toString());
      }
    });
  }

  getRazorPayDemo() async {
    RazorPayModel userModel;
    firestore.collection(Setting).doc("razorpaySettings").get().then((user) {
      print(user.data());
      try {
        print("====loj");
        userModel = RazorPayModel.fromJson(user.data() ?? {});
        UserPreference.setRazorPayData(userModel);
        RazorPayModel fhg = UserPreference.getRazorPayData();
        print(fhg.razorpayKey);
        print("====loj");
        print(userModel);
        //
        // RazorPayController().updateRazorPayData(razorPayData: userModel);

        isRazorPayEnabled = userModel.isEnabled;
        isRazorPaySandboxEnabled = userModel.isSandboxEnabled;
        razorpayKey = userModel.razorpayKey;
        razorpaySecret = userModel.razorpaySecret;
      } catch (e) {
        print('FireStoreUtils.getUserByID failed to parse user object ${user.id}');
      }
    });

    //yield* razorPayStreamController.stream;
  }

  Future<CodModel?> getCod() async {
    DocumentSnapshot<Map<String, dynamic>> codQuery = await firestore.collection(Setting).doc('CODSettings').get();
    if (codQuery.data() != null) {
      print("dataaaaaa");
      return CodModel.fromJson(codQuery.data()!);
    } else {
      print("nulllll");
      return null;
    }
  }

  Future<DeliveryChargeModel?> getDeliveryCharges() async {
    DocumentSnapshot<Map<String, dynamic>> codQuery = await firestore.collection(Setting).doc('DeliveryCharge').get();
    if (codQuery.data() != null) {
      return DeliveryChargeModel.fromJson(codQuery.data()!);
    } else {
      return null;
    }
  }

  Future<String?> getRestaurantNearBy() async {
    DocumentSnapshot<Map<String, dynamic>> codQuery = await firestore.collection(Setting).doc('RestaurantNearBy').get();
    if (codQuery.data() != null) {
      radiusValue = double.parse(codQuery["radios"].toString());
      print(radiusValue.toString() + "===RADIUS");
      return codQuery["radios"].toString();
    } else {
      return "";
    }
  }

  Future<Map<String, dynamic>?> getAdminCommission() async {
    DocumentSnapshot<Map<String, dynamic>> codQuery = await firestore.collection(Setting).doc('AdminCommission').get();
    if (codQuery.data() != null) {
      Map<String, dynamic> getValue = {
        "adminCommission": codQuery["fix_commission"].toString(),
        "isAdminCommission": codQuery["isEnabled"],
        'adminCommissionType': codQuery["commissionType"]
      };
      print(getValue.toString() + "===____");
      return getValue;
    } else {
      return null;
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery =
        await firestore.collection(PRODUCTS).where("takeawayOption", isEqualTo: false).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        // print(document.data()["takeawayOption"].toString()+"<><><>===<><><>");
        //  if(document.data()["takeawayOption"]==null || document.data()["takeawayOption"]==false){
        products.add(ProductModel.fromJson(document.data()));
        // }
      } catch (e) {
        print('productspppp**-FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    return products;
  }

  Future<List<ProductModel>> getAllTakeAWayProducts() async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore.collection(PRODUCTS).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        products.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        print('productspppp**-123--FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    return products;
  }

  Future<ConversationModel?> getChannelByIdOrNull(String channelID) async {
    ConversationModel? conversationModel;
    await firestore.collection(CHANNELS).doc(channelID).get().then((channel) {
      if (channel.data() != null && channel.exists) {
        conversationModel = ConversationModel.fromJson(channel.data()!);
      }
    }, onError: (e) {
      print((e as PlatformException).message);
    });
    return conversationModel;
  }

  Stream<ChatModel> getChatMessages(HomeConversationModel homeConversationModel) async* {
    StreamController<ChatModel> chatModelStreamController = StreamController();
    ChatModel chatModel = ChatModel();
    List<MessageData> listOfMessages = [];
    List<User> listOfMembers = homeConversationModel.members;

    User friend = homeConversationModel.members.first;
    getUserByID(friend.userID).listen((user) {
      listOfMembers.clear();
      listOfMembers.add(user);
      chatModel.message = listOfMessages;
      chatModel.members = listOfMembers;
      chatModelStreamController.sink.add(chatModel);
    });

    if (homeConversationModel.conversationModel != null) {
      firestore
          .collection(CHANNELS)
          .doc(homeConversationModel.conversationModel!.id)
          .collection(THREAD)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((onData) {
        listOfMessages.clear();
        onData.docs.forEach((document) {
          listOfMessages.add(MessageData.fromJson(document.data()));
        });
        chatModel.message = listOfMessages;
        chatModel.members = listOfMembers;
        chatModelStreamController.sink.add(chatModel);
      });
    }
    yield* chatModelStreamController.stream;
  }

  Future<void> sendMessage(List<User> members, MessageData message, ConversationModel conversationModel) async {
    var ref = firestore.collection(CHANNELS).doc(conversationModel.id).collection(THREAD).doc();
    message.messageID = ref.id;
    ref.set(message.toJson());
    List<User> payloadFriends = [MyAppState.currentUser!];

    await Future.forEach(members, (User element) async {
      if (element.settings.pushNewMessages) {
        Map<String, dynamic> payload = <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
          'conversationModel': conversationModel.toPayload(),
          'isGroup': false,
          'members': payloadFriends.map((e) => e.toPayload()).toList()
        };
        await sendNotification(element.fcmToken, MyAppState.currentUser!.fullName(), message.content, payload);
      }
    });
  }

  Future<bool> createConversation(ConversationModel conversation) async {
    bool isSuccessful = false;
    await firestore.collection(CHANNELS).doc(conversation.id).set(conversation.toJson()).then((onValue) async {
      ChannelParticipation myChannelParticipation = ChannelParticipation(user: MyAppState.currentUser!.userID, channel: conversation.id);
      ChannelParticipation myFriendParticipation =
          ChannelParticipation(user: conversation.id.replaceAll(MyAppState.currentUser!.userID, ''), channel: conversation.id);
      await createChannelParticipation(myChannelParticipation);
      await createChannelParticipation(myFriendParticipation);
      isSuccessful = true;
    }, onError: (e) {
      print((e as PlatformException).message);
      isSuccessful = false;
    });
    return isSuccessful;
  }

  Future<void> updateChannel(ConversationModel conversationModel) async {
    await firestore.collection(CHANNELS).doc(conversationModel.id).update(conversationModel.toJson());
  }

  Future<void> createChannelParticipation(ChannelParticipation channelParticipation) async {
    await firestore.collection(CHANNEL_PARTICIPATION).add(channelParticipation.toJson());
  }

  Future<bool> blockUser(User blockedUser, String type) async {
    bool isSuccessful = false;
    BlockUserModel blockUserModel =
        BlockUserModel(type: type, source: MyAppState.currentUser!.userID, dest: blockedUser.userID, createdAt: Timestamp.now());
    await firestore.collection(REPORTS).add(blockUserModel.toJson()).then((onValue) {
      isSuccessful = true;
    });
    return isSuccessful;
  }

  Stream<bool> getBlocks() async* {
    StreamController<bool> refreshStreamController = StreamController();
    firestore.collection(REPORTS).where('source', isEqualTo: MyAppState.currentUser!.userID).snapshots().listen((onData) {
      List<BlockUserModel> list = [];
      for (DocumentSnapshot<Map<String, dynamic>> block in onData.docs) {
        list.add(BlockUserModel.fromJson(block.data() ?? {}));
      }
      blockedList = list;
      refreshStreamController.sink.add(true);
    });
    yield* refreshStreamController.stream;
  }

  bool validateIfUserBlocked(String userID) {
    for (BlockUserModel blockedUser in blockedList) {
      if (userID == blockedUser.dest) {
        return true;
      }
    }
    return false;
  }

  Future<Url> uploadAudioFile(File file, BuildContext context) async {
    showProgress(context, 'Uploading Audio...', false);
    var uniqueID = Uuid().v4();
    Reference upload = storage.child('audio/$uniqueID.mp3');
    SettableMetadata metadata = SettableMetadata(contentType: 'audio');
    UploadTask uploadTask = upload.putFile(file, metadata);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress('Uploading Audio ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
          'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      print((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return Url(mime: metaData.contentType ?? 'audio', url: downloadUrl.toString());
  }

  Future<List<CuisineModel>> getCuisines() async {
    List<CuisineModel> cuisines = [];
    QuerySnapshot<Map<String, dynamic>> cuisinesQuery = await firestore.collection(CATEGORIES).get();
    await Future.forEach(cuisinesQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        cuisines.add(CuisineModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCuisines Parse error $e');
      }
    });
    return cuisines;
  }

  Future<List<CuisineModel>> getDineCuisines() async {
    List<CuisineModel> cuisines = [];
    QuerySnapshot<Map<String, dynamic>> cuisinesQuery = await firestore.collection(CATEGORIES).get();
    GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosotion.latitude, longitude: MyAppState.selectedPosotion.longitude);
    await Future.forEach(cuisinesQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) async {
      await geo
          .collection(
              collectionRef: firestore
                  .collection(VENDORS)
                  .where('categoryID', isEqualTo: document.data()['id'])
                  .where("enabledDiveInFuture", isEqualTo: true))
          .within(center: center, radius: radiusValue, field: 'g', strictMode: true)
          .toList()
          .then((value) {
        if (value.length > 0) {
          try {
            cuisines.add(CuisineModel.fromJson(document.data()));
          } catch (e) {
            print('FireStoreUtils.getCuisines Parse error $e');
          }
        }
      });
    });
    return cuisines;
  }

  // ////rate order
  // Future<List<RatingModel>> getRateOrder() async {
  //   List<RatingModel> vendors = [];
  //   QuerySnapshot<Map<String, dynamic>> vendorsQuery =
  //       await firestore.collection(VENDORS).get();
  //   await Future.forEach(vendorsQuery.docs,
  //       (QueryDocumentSnapshot<Map<String, dynamic>> document) {
  //     try {
  //       vendors.add(VendorModel.fromJson(document.data()));
  //     } catch (e) {
  //       print('FireStoreUtils.getVendors Parse error $e');
  //     }
  //   });
  //   return vendors;
  // }

  /* Future<List<VendorModel>> getVendors() async {
    List<VendorModel> vendors = [];
    QuerySnapshot<Map<String, dynamic>> vendorsQuery =
        await firestore.collection(VENDORS).get();
    await Future.forEach(vendorsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        vendors.add(VendorModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getVendors Parse error $e');
      }
    });
    return vendors;
  }*/

  Stream<List<VendorModel>> getVendors1({String? path}) async* {
    vendorStreamController = StreamController<List<VendorModel>>.broadcast();
    List<VendorModel> vendors = [];
    var collectionReference = (path == null || path.isEmpty)
        ? firestore.collection(VENDORS)
        : firestore.collection(VENDORS).where("enabledDiveInFuture", isEqualTo: true);

    GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosotion.latitude, longitude: MyAppState.selectedPosotion.longitude);

    String field = 'g';
    print(radiusValue.toString() + "===RADIUSgetVendors1");
    Stream<List<DocumentSnapshot>> stream =
        geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      // doSomething()
      documentList.forEach((DocumentSnapshot document) {
        final data = document.data() as Map<String, dynamic>;
        vendors.add(VendorModel.fromJson(data));
        final GeoPoint point = data['g']['geopoint'];
        print("=========vendors  ${data['g']['id']} id " +
            point.latitude.toString() +
            " ||| " +
            point.longitude.toString() +
            " === " +
            data['title']);
        print(vendors.length.toString() + "----vendors11112222");
      });
      if (!vendorStreamController!.isClosed) {
        vendorStreamController!.add(vendors);
      }
    });

    yield* vendorStreamController!.stream;
  }

  closeVendorStream() {
    if (vendorStreamController != null) {
      vendorStreamController!.close();
    }
    if (allResaturantStreamController != null) {
      allResaturantStreamController!.close();
    }
    //newArrivalStreamController.close();
    //productStreamController123.close();
    //productStreamController.close();
  }

  Future<List<VendorModel>> getVendors() async {
    List<VendorModel> vendors = [];
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(VENDORS).get();
    await Future.forEach(vendorsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        vendors.add(VendorModel.fromJson(document.data()));
        print("*-*-/*-*-" + document["title"].toString());
      } catch (e) {
        print('FireStoreUtils.getVendors Parse error $e');
      }
    });
    return vendors;
  }

  Stream<List<OrderModel>> getOrders(String userID) async* {
    List<OrderModel> orders = [];
    ordersStreamController = StreamController();
    ordersStreamSub = firestore
        .collection(ORDERS)
        .where('authorID', isEqualTo: userID)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((onData) async {
      await Future.forEach(onData.docs, (QueryDocumentSnapshot<Map<String, dynamic>> element) {
        try {
          OrderModel orderModel = OrderModel.fromJson(element.data());
          if (!orders.contains(orderModel)) {
            orders.add(orderModel);
          }
        } catch (e, s) {
          print('watchOrdersStatus parse error ${element.id} $e $s');
        }
      });
      ordersStreamController!.sink.add(orders);
    });
    yield* ordersStreamController!.stream;
  }

  void initBookStream() {}

  Stream<List<BookTableModel>> getBookingOrders(String userID, bool isUpComing) async* {
    List<BookTableModel> orders = [];

    if (isUpComing) {
      StreamController<List<BookTableModel>> upcomingordersStreamController = StreamController();
      firestore
          .collection(ORDERS_TABLE)
          .where('author.id', isEqualTo: userID)
          .where('date', isGreaterThan: Timestamp.now())
          .orderBy('date', descending: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((onData) async {
        await Future.forEach(onData.docs, (QueryDocumentSnapshot<Map<String, dynamic>> element) {
          try {
            orders.add(BookTableModel.fromJson(element.data()));
          } catch (e, s) {
            print('booktable parse error ${element.id} $e $s');
          }
        });
        upcomingordersStreamController.sink.add(orders);
      });
      yield* upcomingordersStreamController.stream;
    } else {
      StreamController<List<BookTableModel>> bookedordersStreamController = StreamController();
      firestore
          .collection(ORDERS_TABLE)
          .where('author.id', isEqualTo: userID)
          .where('date', isLessThan: Timestamp.now())
          .orderBy('date', descending: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((onData) async {
        await Future.forEach(onData.docs, (QueryDocumentSnapshot<Map<String, dynamic>> element) {
          try {
            orders.add(BookTableModel.fromJson(element.data()));
          } catch (e, s) {
            print('booktable parse error ${element.id} $e $s');
          }
        });
        bookedordersStreamController.sink.add(orders);
      });
      yield* bookedordersStreamController.stream;
    }
  }

  closeOrdersStream() {
    if (ordersStreamSub != null) {
      ordersStreamSub!.cancel();
    }
    if (ordersStreamController != null) {
      ordersStreamController!.close();
    }
  }

/*  Stream<List<FavouriteModel>> getFavourites() async* {
    List<FavouriteModel> lstFavourites = [];
    favouriteStreamControleer =
        StreamController<List<FavouriteModel>>.broadcast();
    favouriteStreamSub = firestore
        .collection(FavouriteRestaurant)
        .snapshots()
        .listen((event) async {
      await Future.forEach(event.docs,
          (QueryDocumentSnapshot<Map<String, dynamic>> element) {
        try {
          lstFavourites.add(FavouriteModel.fromJson(element.data()));
        } catch (e, s) {
          print('FavouriteModel parse error ${element.id} $e $s');
        }
      });
      favouriteStreamControleer.sink.add(lstFavourites);
    });

    yield* favouriteStreamControleer.stream;
  }*/
  Future<List<FavouriteModel>> getFavourites() async {
    List<FavouriteModel> lstFavourites = [];

    QuerySnapshot<Map<String, dynamic>> favourites = await firestore.collection(FavouriteRestaurant).get();
    await Future.forEach(favourites.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        lstFavourites.add(FavouriteModel.fromJson(document.data()));
      } catch (e) {
        print('FavouriteModel.getCurrencys Parse error $e');
      }
    });

    return lstFavourites;
  }

  /*closeFavouriteStream() {
    favouriteStreamSub.cancel();
    favouriteStreamControleer.close();
  }*/

  void setFavouriteRestaurant(FavouriteModel favouriteModel) {
    var collectionReference = firestore.collection(FavouriteRestaurant).add(favouriteModel.toJson()).then((value) {
      print("===FAVOURITE ADDED===");
    });
  }

  void removeFavouriteRestaurant(FavouriteModel favouriteModel) {
    FirebaseFirestore.instance
        .collection(FavouriteRestaurant)
        .where("restaurant_id", isEqualTo: favouriteModel.restaurant_id)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        FirebaseFirestore.instance.collection(FavouriteRestaurant).doc(element.id).delete().then((value) {
          print("Success!");
        });
      });
    });
  }

  dynamic getStoreQuery() {
    var collectionReference = firestore.collection(VENDORS);
    print("data caled paginator");

    return collectionReference;
  }

  Stream<List<VendorModel>> getAllRestaurants() async* {
    allResaturantStreamController = StreamController<List<VendorModel>>.broadcast();
    List<VendorModel> vendors = [];
    var collectionReference = firestore.collection(VENDORS);

    GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosotion.latitude, longitude: MyAppState.selectedPosotion.longitude);

    String field = 'g';

    print(radiusValue.toString() + "===RADIUSgetAllRestaurants ${MyAppState.selectedPosotion}");

    Stream<List<DocumentSnapshot>> stream =
        geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);

    stream.listen((documentList) {
      documentList.forEach((DocumentSnapshot document) {
        final data = document.data() as Map<String, dynamic>;
        vendors.add(VendorModel.fromJson(data));
        if (!allResaturantStreamController!.isClosed) {
          allResaturantStreamController!.add(vendors);
        }
      });
    });
    print(vendors.length.toString() + "----vendors11112222All");
    yield* allResaturantStreamController!.stream;
  }

  Stream<List<VendorModel>> getAllDineInRestaurants() async* {
    List<VendorModel> vendors = [];

    allDineInResaturantStreamController = StreamController<List<VendorModel>>.broadcast();
    var collectionReference = firestore.collection(VENDORS).where("enabledDiveInFuture", isEqualTo: true);
    GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosotion.latitude, longitude: MyAppState.selectedPosotion.longitude);

    String field = 'g';
    print(radiusValue.toString() + "===RADIUSgetVendorsForNewArrival");
    Stream<List<DocumentSnapshot>> stream =
        geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      // doSomething()
      documentList.forEach((DocumentSnapshot document) {
        final data = document.data() as Map<String, dynamic>;

        vendors.add(VendorModel.fromJson(data));

        allDineInResaturantStreamController.add(vendors);
      });
    });

    yield* allDineInResaturantStreamController.stream;
  }

  Stream<List<VendorModel>> getVendorsForNewArrival({String? path}) async* {
    List<VendorModel> vendors = [];

    newArrivalStreamController = StreamController<List<VendorModel>>.broadcast();
    var collectionReference = (path == null || path.isEmpty)
        ? firestore.collection(VENDORS)
        : firestore.collection(VENDORS).where("enabledDiveInFuture", isEqualTo: true);
    GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosotion.latitude, longitude: MyAppState.selectedPosotion.longitude);
    String field = 'g';
    Stream<List<DocumentSnapshot>> stream =
        geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);
    stream.listen((List<DocumentSnapshot> documentList) {
      documentList.forEach((DocumentSnapshot document) {
        final data = document.data() as Map<String, dynamic>;
        vendors.add(VendorModel.fromJson(data));
        if (!newArrivalStreamController!.isClosed) {
          newArrivalStreamController!.add(vendors);
        }
      });
    });

    yield* newArrivalStreamController!.stream;
  }

  Stream<List<VendorModel>> getPopularsVendors({String? path}) async* {
    List<VendorModel> vendors = [];

    popularStreamController = StreamController<List<VendorModel>>.broadcast();
    var collectionReference = (path == null || path.isEmpty)
        ? firestore.collection(VENDORS)
        : firestore.collection(VENDORS).where("enabledDiveInFuture", isEqualTo: true);
    GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosotion.latitude, longitude: MyAppState.selectedPosotion.longitude);
    String field = 'g';
    print(radiusValue.toString() + "===RADIUSgetVendorsForNewArrival");
    Stream<List<DocumentSnapshot>> stream =
        geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);
    stream.listen((List<DocumentSnapshot> documentList) {
      if (documentList.isNotEmpty) {
        documentList.forEach((DocumentSnapshot document) {
          final data = document.data() as Map<String, dynamic>;
          VendorModel vendorModel = VendorModel.fromJson(data);
          if ((vendorModel.reviewsSum / vendorModel.reviewsCount) >= 4.0) {
            vendors.add(vendorModel);
            popularStreamController.add(vendors);
          } else {
            popularStreamController.add(vendors);
          }
        });
      } else {
        popularStreamController.add(vendors);
      }
    });

    yield* popularStreamController.stream;
  }

  closeNewArrivalStream() {
    if (newArrivalStreamController != null) {
      newArrivalStreamController!.close();
    }
  }

  Stream<List<VendorModel>> getVendorsByCuisineID(String cuisineID, {bool? isDinein}) async* {
    await getRestaurantNearBy();
    cusionStreamController = StreamController<List<VendorModel>>.broadcast();
    List<VendorModel> vendors = [];
    var collectionReference = isDinein!
        ? firestore.collection(VENDORS).where('categoryID', isEqualTo: cuisineID).where("enabledDiveInFuture", isEqualTo: true)
        : firestore.collection(VENDORS).where('categoryID', isEqualTo: cuisineID);
    GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosotion.latitude, longitude: MyAppState.selectedPosotion.longitude);
    String field = 'g';
    Stream<List<DocumentSnapshot>> stream =
        geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);
    stream.listen((List<DocumentSnapshot> documentList) {
      Future.forEach(documentList, (DocumentSnapshot element) {
        final data = element.data() as Map<String, dynamic>;
        vendors.add(VendorModel.fromJson(data));
        cusionStreamController.add(vendors);
      });
      cusionStreamController.close();
    });

    yield* cusionStreamController.stream;
  }

  Future<List<OfferModel>> getViewAllOffer() async {
    List<OfferModel> offersData = [];

    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore
        .collection(COUPONS)
        .where("isEnabled", isEqualTo: true)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now())
        .get();
    await Future.forEach(vendorsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        offersData.add(OfferModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getVendors Parse error $e');
      }
    });
    return offersData;
  }

  Stream<List<OfferModel>> getOfferStream() async* {
    List<OfferModel> offers = [];
    offerStreamController = StreamController<List<OfferModel>>.broadcast();
    var date = DateTime.now();
    offerStreamSub = firestore
        .collection(COUPONS)
        .where("isEnabled", isEqualTo: true)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now())
        .snapshots()
        .listen((event) async {
      offers.clear();
      await Future.forEach(event.docs, (QueryDocumentSnapshot<Map<String, dynamic>> element) {
        try {
          offers.add(OfferModel.fromJson(element.data()));
        } catch (e, s) {
          print('getProductsStream parse error ${element.id}$e $s');
        }
      });
      print(offers.length.toString() + "{}{}====+++999");
      offerStreamController!.add(offers);
    });
    yield* offerStreamController!.stream;
  }

  Future<List<BannerModel>> getHomeBanner() async {
    List<BannerModel> bannerHome = [];
    QuerySnapshot<Map<String, dynamic>> bannerHomeQuery =
        await firestore.collection(MENU_ITEM).where("is_publish", isEqualTo: true).orderBy("set_order", descending: false).get();
    await Future.forEach(bannerHomeQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print(document.data());
        bannerHome.add(BannerModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCuisines Parse error $e');
      }
    });
    return bannerHome;
  }

  Stream<List<OfferModel>> getOfferStreamByVendorID(String vendorID) async* {
    print(vendorID.toString() + "{}");
    List<OfferModel> offers = [];
    offerStreamController = StreamController<List<OfferModel>>();
    offerStreamSub = firestore
        .collection(COUPONS)
        .where("resturant_id", isEqualTo: vendorID)
        .where("isEnabled", isEqualTo: true)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now())
        .snapshots()
        .listen((event) async {
      offers.clear();
      await Future.forEach(event.docs, (QueryDocumentSnapshot<Map<String, dynamic>> element) {
        try {
          offers.add(OfferModel.fromJson(element.data()));
          print(element.data().toString());
        } catch (e, s) {
          print('getProductsStream parse error ${element.id}$e $s');
        }
      });
      print(offers.length.toString() + "{}{}");
      print(offers.length.toString() + "{}{}====+++999000");
      offerStreamController!.add(offers);
    });
    yield* offerStreamController!.stream;
  }

  closeOfferStream() {
    if (offerStreamSub != null) {
      offerStreamSub!.cancel();
    }
    if (offerStreamController != null) {
      offerStreamController!.close();
    }
  }

  Future<String?> getplaceholderimage() async {
//  var variable = await firestore.collection(Setting)
//  .doc('placeHolderImage').get();
// Map<String, dynamic>? mapEventData = variable.data() ;
//  Map<String, dynamic> getField = jsonDecode(mapEventData!['image']);
//  print(getField['data']);
    var collection = FirebaseFirestore.instance.collection(Setting);
    var docSnapshot = await collection.doc('placeHolderImage').get();
// if (docSnapshot.exists) {
    Map<String, dynamic>? data = docSnapshot.data();
    var value = data?['image'];
    // <-- The value you want to retrieve.
    // print(value);
    // Call setState if needed.
// }
    placeholderImage = value;
    return placeholderImage;
  }

  Future<List<CurrencyModel>> getCurrency() async {
    List<CurrencyModel> currency = [];

    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(Currency).where("isActive", isEqualTo: true).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        currency.add(CurrencyModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });

    print("uday");
    print(currency);
    return currency;
  }

  Future<List<OfferModel>> getAllCoupons() async {
    List<OfferModel> coupon = [];

    QuerySnapshot<Map<String, dynamic>> couponsQuery =
        await firestore.collection(COUPON).where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now()).get();
    await Future.forEach(couponsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        coupon.add(OfferModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    return coupon;
  }

  Future<List<ProductModel>> getVendorProducts(String vendorID) async {
    print(vendorID);
    print('we are Enter getVendorProducts--*');
    print('**622a02b704d84');
    List<ProductModel> products = [];
    print('we are Enter getVendorProducts');

    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore.collection(PRODUCTS).where('vendorID', isEqualTo: vendorID).get();
    print(productsQuery.docs);
    print('we are Enter getVendorProducts--.');
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        products.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getVendorProducts Parse error $e');
      }
    });
    print('product data1');
    print(products.toString());
    return products;
  }

  Future<List<ProductModel>> getVendorProductsTakeAWay(String vendorID) async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore.collection(PRODUCTS).where('vendorID', isEqualTo: vendorID).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        products.add(ProductModel.fromJson(document.data()));
        //print('=====TP+++++ ${document.data().toString()}');
      } catch (e) {
        print('FireStoreUtils.getVendorProducts Parse error $e');
      }
    });
    print("=====IDDDDDD" + products.length.toString());
    return products;
  }

  Future<List<ProductModel>> getVendorProductsDelivery(String vendorID) async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery =
        await firestore.collection(PRODUCTS).where('vendorID', isEqualTo: vendorID).where("takeawayOption", isEqualTo: false).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        products.add(ProductModel.fromJson(document.data()));
        print('=====FireStoreUtils.getVendorProducts Parse error ${document.data().toString()}');
      } catch (e) {
        print('FireStoreUtils.getVendorProducts Parse error $e');
      }
    });
    print("=====IDDDDDD----" + products.length.toString());
    return products;
  }

  //  Future<List<ProductModel>> updatevendorProduct(ProductModel productModel) async {
  //   return await firestore
  //       .collection(PRODUCTS)
  //       .doc(productModel.id).collection("quentity").doc(productModel.quantity)
  //       .set(user.toJson())
  //       .then((document) {
  //     return user;
  //   });
  // }
//  static Future<VendorModel?> updateVendor(VendorModel vendor) async {
//     return await firestore
//         .collection(VENDORS)
//         .doc(vendor.id)
//         .set(vendor.toJson())
//         .then((document) {
//       return vendor;
//     });
//   }

  Future<VendorCategoryModel> getVendorCategoryById(String vendorCategoryID) async {
    print('we are enter-->');
    late VendorCategoryModel vendorCategoryModel;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery =
        await firestore.collection(VENDORS_CATEGORIES).where('id', isEqualTo: vendorCategoryID).get();
    try {
      print('we are enter-->');
      if (vendorsQuery.docs.length > 0) {
        vendorCategoryModel = VendorCategoryModel.fromJson(vendorsQuery.docs.first.data());
      }
    } catch (e) {
      print('FireStoreUtils.getVendorByVendorID Parse error $e');
    }
    return vendorCategoryModel;
  }

  Future<VendorModel> getVendorByVendorID(String vendorID) async {
    late VendorModel vendor;
    print(vendorID.toString() + "----VENDORIDPLACEORDER");
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(VENDORS).where('id', isEqualTo: vendorID).get();
    try {
      if (vendorsQuery.docs.length > 0) {
        vendor = VendorModel.fromJson(vendorsQuery.docs.first.data());
      }
    } catch (e) {
      print('FireStoreUtils.getVendorByVendorID Parse error $e');
    }
    return vendor;
  }

  Future<RatingModel?> getReviewsbyID(String ordertId) async {
    RatingModel? ratingproduct;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(Order_Rating).where('orderid', isEqualTo: ordertId).get();
    try {
      if (vendorsQuery.docs.length > 0) {
        ratingproduct = RatingModel.fromJson(vendorsQuery.docs.first.data());
      }
    } catch (e) {
      print('FireStoreUtils.getVendorByVendorID Parse error $e');
    }
    return ratingproduct;
  }

  // Future<RatingModel> getReviewsbyVendorID(String vendorId) async {
  //   late RatingModel ratingproduct;
  //   QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore
  //       .collection(Order_Rating)
  //       .where('VendorId', isEqualTo: vendorId)
  //       .get();
  //   try {
  //     ratingproduct = RatingModel.fromJson(vendorsQuery.docs.first.data());
  //   } catch (e) {
  //     print('FireStoreUtils.getVendorByVendorID Parse error $e');
  //   }
  //   return ratingproduct;
  // }

  Future<List<RatingModel>> getReviewsbyVendorID(String vendorId) async {
    List<RatingModel> vendorreview = [];

    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore
        .collection(Order_Rating)
        .where('VendorId', isEqualTo: vendorId)
        // .orderBy('createdAt', descending: true)
        .get();
    await Future.forEach(vendorsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      print(document);
      try {
        vendorreview.add(RatingModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getOrders Parse error ${document.id} $e');
      }
    });
    return vendorreview;
  }

  static Future<RatingModel?> updateReviewbyId(RatingModel ratingproduct) async {
    return await firestore.collection(Order_Rating).doc(ratingproduct.id).set(ratingproduct.toJson()).then((document) {
      return ratingproduct;
    });
  }

  Future<List<FavouriteModel>> getFavouriteRestaurant(String userId) async {
    List<FavouriteModel> favouriteItem = [];

    QuerySnapshot<Map<String, dynamic>> vendorsQuery =
        await firestore.collection(FavouriteRestaurant).where('user_id', isEqualTo: userId).get();
    await Future.forEach(vendorsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        favouriteItem.add(FavouriteModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getVendors Parse error $e');
      }
    });
    print(favouriteItem.length.toString() + "===FL===" + userId);
    return favouriteItem;
  }

  Future<OrderModel> placeOrder(OrderModel orderModel) async {
    DocumentReference documentReference = firestore.collection(ORDERS).doc(UserPreference.getOrderId());
    orderModel.id = documentReference.id;
    await documentReference.set(orderModel.toJson());
    return orderModel;
  }

  Future<OrderModel> placeOrderWithTakeAWay(OrderModel orderModel) async {
    DocumentReference documentReference;
    if (orderModel.id == null || orderModel.id.isEmpty) {
      documentReference = firestore.collection(ORDERS).doc();
      orderModel.id = documentReference.id;
    } else {
      documentReference = firestore.collection(ORDERS).doc(orderModel.id);
    }
    await documentReference.set(orderModel.toJson());
    return orderModel;
  }

  Future<BookTableModel> bookTable(BookTableModel orderModel) async {
    DocumentReference documentReference = firestore.collection(ORDERS_TABLE).doc();
    orderModel.id = documentReference.id;
    await documentReference.set(orderModel.toJson());
    return orderModel;
  }

  static createOrder() async {
    DocumentReference documentReference = firestore.collection(ORDERS).doc();
    final orderId = documentReference.id;
    UserPreference.setOrderId(orderId: orderId);
  }

  static Future createPaymentId() async {
    DocumentReference documentReference = firestore.collection(Wallet).doc();
    final paymentId = documentReference.id;
    UserPreference.setPaymentId(paymentId: paymentId);
    return paymentId;
  }

  static Future<List<TopupTranHistoryModel>> getTopUpTransaction() async {
    final userId = MyAppState.currentUser!.userID; //UserPreference.getUserId();
    List<TopupTranHistoryModel> topUpHistoryList = [];
    QuerySnapshot<Map<String, dynamic>> documentReference = await firestore.collection(Wallet).where('user_id', isEqualTo: userId).get();
    await Future.forEach(documentReference.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        topUpHistoryList.add(TopupTranHistoryModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    // QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore.collection(Wallet).get();
    // await Future.forEach(productsQuery.docs,
    //         (QueryDocumentSnapshot<Map<String, dynamic>> document) {
    //       try {
    //         products.add(TopupTranHistoryModel.fromJson(document.data()));
    //       } catch (e) {
    //         print('FireStoreUtils.getAllProducts Parse error $e');
    //       }
    //     });

    // final paymentId = documentReference;
    // UserPreference.setPaymentId(paymentId: paymentId);
    return topUpHistoryList;
  }

  static Future topUpWalletAmount({String paymentMethod = "test", bool isTopup = true, required amount, required id, orderId = ""}) async {
    print("this is te payment id");
    print(id);
    print(MyAppState.currentUser!.userID);

    await firestore.collection(Wallet).doc(id).set({
      "user_id": MyAppState.currentUser!.userID,
      "payment_method": paymentMethod,
      "amount": amount,
      "id": id,
      "order_id": orderId,
      "isTopUp": isTopup,
      "payment_status": "success",
      "date": DateTime.now(),
    }).then((value) {
      firestore.collection(Wallet).doc(id).get().then((value) {
        DocumentSnapshot<Map<String, dynamic>> documentData = value;
        print("nato");
        print(documentData.data());
      });
    });

    return "updated Amount";
    // if (userDocument.data() != null && userDocument.exists) {
    //   try{
    //     print(userDocument.data());
    //     walletAmount = userDocument["wallet_amount"];
    //     print(userDocument["wallet_amount"]);
    //     print(userDocument["active"]);
    //   }catch(erro){
    //     print(erro);
    //     print(erro.toString());
    //     if(erro.toString() == "Bad state: field does not exist within the DocumentSnapshotPlatform"){
    //       print("dones not exist");
    //       await firestore.collection(USERS).doc(userId).set({"wallet_amount": 0});
    //       walletAmount = 0;
    //     }else{
    //       print("went wrong!!");
    //       walletAmount = "ERROR";
    //     }
    //
    //   }
    //   return walletAmount;//User.fromJson(userDocument.data()!);
    // } else {
    //   return null;
    // }
  }

  static Future updateWalletAmount({required amount}) async {
    dynamic walletAmount = 0;
    final userId = MyAppState.currentUser!.userID; //UserPreference.getUserId();
    /* DocumentSnapshot<Map<String, dynamic>> userDocument =*/
    await firestore.collection(USERS).doc(userId).get().then((value) async {
      DocumentSnapshot<Map<String, dynamic>> userDocument = value;
      if (userDocument.data() != null && userDocument.exists) {
        try {
          print(userDocument.data());
          User user = User.fromJson(userDocument.data()!);
          MyAppState.currentUser = user;
          print(user.lastName.toString() + "=====.....(user.wallet_amount");
          print("add ${user.lastName} + $amount");
          await firestore
              .collection(USERS)
              .doc(userId)
              .update({"wallet_amount": user.wallet_amount + amount}).then((value) => print("north"));
          /*print(user.wallet_amount);


          walletAmount = user.wallet_amount! + amount;*/
          DocumentSnapshot<Map<String, dynamic>> newUserDocument = await firestore.collection(USERS).doc(userId).get();
          MyAppState.currentUser = User.fromJson(newUserDocument.data()!);
          print(MyAppState.currentUser);
        } catch (error) {
          print(error);
          if (error.toString() == "Bad state: field does not exist within the DocumentSnapshotPlatform") {
            print("does not exist");
            //await firestore.collection(USERS).doc(userId).update({"wallet_amount": 0});
            //walletAmount = 0;
          } else {
            print("went wrong!!");
            walletAmount = "ERROR";
          }
        }
        print("data val");
        print(walletAmount);
        return walletAmount; //User.fromJson(userDocument.data()!);
      } else {
        return 0.111;
      }
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchOrderStatus(String orderID) async* {
    yield* firestore.collection(ORDERS).doc(orderID).snapshots();
  }

  /// compress image file to make it load faster but with lower quality,
  /// change the quality parameter to control the quality of the image after
  /// being compressed(100 = max quality - 0 = low quality)
  /// @param file the image file that will be compressed
  /// @return File a new compressed file with smaller size
  static Future<File> compressImage(File file) async {
    File compressedImage = await FlutterNativeImage.compressImage(
      file.path,
      quality: 25,
    );
    return compressedImage;
  }

  /// compress video file to make it load faster but with lower quality,
  /// change the quality parameter to control the quality of the video after
  /// being compressed
  /// @param file the video file that will be compressed
  /// @return File a new compressed file with smaller size
  Future<File> _compressVideo(File file) async {
    MediaInfo? info = await VideoCompress.compressVideo(file.path,
        quality: VideoQuality.DefaultQuality, deleteOrigin: false, includeAudio: true, frameRate: 24);
    if (info != null) {
      File compressedVideo = File(info.path!);
      return compressedVideo;
    } else {
      return file;
    }
  }

  static loginWithFacebook() async {
    /// creates a user for this facebook login when this user first time login
    /// and save the new user object to firebase and firebase auth
    FacebookAuth facebookAuth = FacebookAuth.instance;
    bool isLogged = await facebookAuth.accessToken != null;
    if (!isLogged) {
      LoginResult result = await facebookAuth.login(
        permissions: ['public_profile', 'email', 'pages_show_list', 'pages_messaging', 'pages_manage_metadata'],
      ); // by default we request the email and the public profile
      if (result.status == LoginStatus.success) {
        // you are logged
        AccessToken? token = await facebookAuth.accessToken;
        return await handleFacebookLogin(await facebookAuth.getUserData(), token!);
      }
    } else {
      AccessToken? token = await facebookAuth.accessToken;
      return await handleFacebookLogin(await facebookAuth.getUserData(), token!);
    }
  }

  static handleFacebookLogin(Map<String, dynamic> userData, AccessToken token) async {
    auth.UserCredential authResult =
        await auth.FirebaseAuth.instance.signInWithCredential(auth.FacebookAuthProvider.credential(token.token));
    User? user = await getCurrentUser(authResult.user?.uid ?? ' ');
    List<String> fullName = (userData['name'] as String).split(' ');
    String firstName = '';
    String lastName = '';
    if (fullName.isNotEmpty) {
      firstName = fullName.first;
      lastName = fullName.skip(1).join(' ');
    }
    if (user != null && user.role == USER_ROLE_CUSTOMER) {
      user.profilePictureURL = userData['picture']['data']['url'];
      user.firstName = firstName;
      user.lastName = lastName;
      user.email = userData['email'];
      //user.active = true;
      user.role = USER_ROLE_CUSTOMER;
      user.fcmToken = await firebaseMessaging.getToken() ?? '';
      dynamic result = await updateCurrentUser(user);
      return result;
    } else if (user == null) {
      user = User(
          email: userData['email'] ?? '',
          firstName: firstName,
          profilePictureURL: userData['picture']['data']['url'] ?? '',
          userID: authResult.user?.uid ?? '',
          lastOnlineTimestamp: Timestamp.now(),
          lastName: lastName,
          active: true,
          role: USER_ROLE_CUSTOMER,
          fcmToken: await firebaseMessaging.getToken() ?? '',
          phoneNumber: '',
          settings: UserSettings());
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return errorMessage;
      }
    }
  }

  static loginWithApple() async {
    final appleCredential = await apple.TheAppleSignIn.performRequests([
      apple.AppleIdRequest(requestedScopes: [apple.Scope.email, apple.Scope.fullName])
    ]);
    if (appleCredential.error != null) {
      return "notLoginApple".tr();
    }

    if (appleCredential.status == apple.AuthorizationStatus.authorized) {
      final auth.AuthCredential credential = auth.OAuthProvider('apple.com').credential(
        accessToken: String.fromCharCodes(appleCredential.credential?.authorizationCode ?? []),
        idToken: String.fromCharCodes(appleCredential.credential?.identityToken ?? []),
      );
      return await handleAppleLogin(credential, appleCredential.credential!);
    } else {
      return "notLoginApple".tr();
    }
  }

  static handleAppleLogin(
    auth.AuthCredential credential,
    apple.AppleIdCredential appleIdCredential,
  ) async {
    auth.UserCredential authResult = await auth.FirebaseAuth.instance.signInWithCredential(credential);
    User? user = await getCurrentUser(authResult.user?.uid ?? '');
    if (user != null) {
      //user.active = true;
      user.role = USER_ROLE_CUSTOMER;
      user.fcmToken = await firebaseMessaging.getToken() ?? '';
      dynamic result = await updateCurrentUser(user);
      return result;
    } else {
      user = User(
          email: appleIdCredential.email ?? '',
          firstName: appleIdCredential.fullName?.givenName ?? '',
          profilePictureURL: '',
          userID: authResult.user?.uid ?? '',
          lastOnlineTimestamp: Timestamp.now(),
          lastName: appleIdCredential.fullName?.familyName ?? '',
          role: USER_ROLE_CUSTOMER,
          active: true,
          fcmToken: await firebaseMessaging.getToken() ?? '',
          phoneNumber: '',
          settings: UserSettings());
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return errorMessage;
      }
    }
  }

  /// save a new user document in the USERS table in firebase firestore
  /// returns an error message on failure or null on success
  static Future<String?> firebaseCreateNewUser(User user) async {
    try {
      await firestore.collection(USERS).doc(user.userID).set(user.toJson());
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return "notSignUp".tr();
    }
  }

  static Future<String?> firebaseCreateNewReview(RatingModel ratingModel) async {
    try {
      await firestore.collection(Order_Rating).doc(ratingModel.id).set(ratingModel.toJson());
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return 'Couldn\'t review'.tr();
    }
  }

  /// login with email and password with firebase
  /// @param email user email
  /// @param password user password
  static Future<dynamic> loginWithEmailAndPassword(String email, String password) async {
    try {
      print('FireStoreUtils.loginWithEmailAndPassword');
      auth.UserCredential result = await auth.FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      // result.user.
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await firestore.collection(USERS).doc(result.user?.uid ?? '').get();
      User? user;

      if (documentSnapshot.exists) {
        // if(user!.role != 'vendor'){
        user = User.fromJson(documentSnapshot.data() ?? {});
        // if(  USER_ROLE_CUSTOMER ==user.role)
        // {
        user.fcmToken = await firebaseMessaging.getToken() ?? '';

        //user.active = true;

        //      }

      }
      return user;
    } on auth.FirebaseAuthException catch (exception, s) {
      print(exception.toString() + '$s');
      switch ((exception).code) {
        case 'invalid-email':
          return 'Email address is malformed.';
        case 'wrong-password':
          return 'Wrong password.';
        case 'user-not-found':
          return 'No user corresponding to the given email address.';
        case 'user-disabled':
          return 'This user has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts to sign in as this user.';
      }
      return 'Unexpected firebase error, Please try again.';
    } catch (e, s) {
      print(e.toString() + '$s');
      return 'Login failed, Please try again.';
    }
  }

  ///submit a phone number to firebase to receive a code verification, will
  ///be used later to login
  static firebaseSubmitPhoneNumber(
    String phoneNumber,
    auth.PhoneCodeAutoRetrievalTimeout? phoneCodeAutoRetrievalTimeout,
    auth.PhoneCodeSent? phoneCodeSent,
    auth.PhoneVerificationFailed? phoneVerificationFailed,
    auth.PhoneVerificationCompleted? phoneVerificationCompleted,
  ) {
    auth.FirebaseAuth.instance.verifyPhoneNumber(
      timeout: Duration(minutes: 2),
      phoneNumber: phoneNumber,
      verificationCompleted: phoneVerificationCompleted!,
      verificationFailed: phoneVerificationFailed!,
      codeSent: phoneCodeSent!,
      codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout!,
    );
  }

  /// submit the received code to firebase to complete the phone number
  /// verification process
  static Future<dynamic> firebaseSubmitPhoneNumberCode(String verificationID, String code, String phoneNumber, BuildContext context,
      {String firstName = 'Anonymous', String lastName = 'User', File? image}) async {
    auth.AuthCredential authCredential = auth.PhoneAuthProvider.credential(verificationId: verificationID, smsCode: code);
    auth.UserCredential userCredential = await auth.FirebaseAuth.instance.signInWithCredential(authCredential);
    User? user = await getCurrentUser(userCredential.user?.uid ?? '');
    if (user != null && user.role == USER_ROLE_CUSTOMER) {
      user.fcmToken = await firebaseMessaging.getToken() ?? '';
      user.role = USER_ROLE_CUSTOMER;
      //user.active = true;
      await updateCurrentUser(user);
      return user;
    } else if (user == null) {
      /// create a new user from phone login
      String profileImageUrl = '';
      if (image != null) {
        File compressedImage = await FireStoreUtils.compressImage(image);
        final bytes = compressedImage.readAsBytesSync().lengthInBytes;
        final kb = bytes / 1024;
        final mb = kb / 1024;

        if (mb > 2) {
          hideProgress();
          showAlertDialog(context, "error".tr(), "imageTooLarge".tr(), true);
          return;
        }
        profileImageUrl = await uploadUserImageToFireStorage(compressedImage, userCredential.user?.uid ?? '');
      }
      User user = User(
        firstName: firstName,
        lastName: lastName,
        fcmToken: await firebaseMessaging.getToken() ?? '',
        phoneNumber: phoneNumber,
        profilePictureURL: profileImageUrl,
        userID: userCredential.user?.uid ?? '',
        role: USER_ROLE_CUSTOMER,
        active: true,
        lastOnlineTimestamp: Timestamp.now(),
        settings: UserSettings(),
        email: '',
      );
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return 'Couldn\'t create new user with phone number.';
      }
    }
  }

  static firebaseSignUpWithEmailAndPassword(
      String emailAddress, String password, File? image, String firstName, String lastName, String mobile, BuildContext context) async {
    try {
      auth.UserCredential result = await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailAddress, password: password);
      String profilePicUrl = '';
      if (image != null) {
        File compressedImage = await FireStoreUtils.compressImage(image);
        final bytes = compressedImage.readAsBytesSync().lengthInBytes;
        final kb = bytes / 1024;
        final mb = kb / 1024;

        if (mb > 2) {
          hideProgress();
          showAlertDialog(context, "error".tr(), "imageTooLarge".tr(), true);
          return;
        }
        updateProgress('Uploading image, Please wait...'.tr());
        profilePicUrl = await uploadUserImageToFireStorage(compressedImage, result.user?.uid ?? '');
      }
      User user = User(
          email: emailAddress,
          settings: UserSettings(),
          lastOnlineTimestamp: Timestamp.now(),
          active: true,
          phoneNumber: mobile,
          firstName: firstName,
          role: USER_ROLE_CUSTOMER,
          userID: result.user?.uid ?? '',
          lastName: lastName,
          fcmToken: await firebaseMessaging.getToken() ?? '',
          profilePictureURL: profilePicUrl);
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return 'Couldn\'t sign up for firebase, Please try again.';
      }
    } on auth.FirebaseAuthException catch (error) {
      print(error.toString() + '${error.stackTrace}');
      String message = "notSignUp".tr();
      switch (error.code) {
        case 'email-already-in-use':
          message = 'Email already in use, Please pick another email!';
          break;
        case 'invalid-email':
          message = 'Enter valid e-mail';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled';
          break;
        case 'weak-password':
          message = 'Password must be more than 5 characters';
          break;
        case 'too-many-requests':
          message = 'Too many requests, Please try again later.';
          break;
      }
      return message;
    } catch (e) {
      return "notSignUp".tr();
    }
  }

  static Future<auth.UserCredential?> reAuthUser(AuthProviders provider,
      {String? email,
      String? password,
      String? smsCode,
      String? verificationId,
      AccessToken? accessToken,
      apple.AuthorizationResult? appleCredential}) async {
    late auth.AuthCredential credential;
    switch (provider) {
      case AuthProviders.PASSWORD:
        credential = auth.EmailAuthProvider.credential(email: email!, password: password!);
        break;
      case AuthProviders.PHONE:
        credential = auth.PhoneAuthProvider.credential(smsCode: smsCode!, verificationId: verificationId!);
        break;
      case AuthProviders.FACEBOOK:
        credential = auth.FacebookAuthProvider.credential(accessToken!.token);
        break;
      case AuthProviders.APPLE:
        credential = auth.OAuthProvider('apple.com').credential(
          accessToken: String.fromCharCodes(appleCredential!.credential?.authorizationCode ?? []),
          idToken: String.fromCharCodes(appleCredential.credential?.identityToken ?? []),
        );
        break;
    }
    return await auth.FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
  }

  static resetPassword(String emailAddress) async => await auth.FirebaseAuth.instance.sendPasswordResetEmail(email: emailAddress);

  static deleteUser() async {
    try {
      // delete user records from CHANNEL_PARTICIPATION table
      await firestore.collection(ORDERS).where('authorID', isEqualTo: MyAppState.currentUser!.userID).get().then((value) async {
        for (var doc in value.docs) {
          await firestore.doc(doc.reference.path).delete();
        }
      });

      await firestore.collection(CHANNEL_PARTICIPATION).where('user', isEqualTo: MyAppState.currentUser!.userID).get().then((value) async {
        for (var doc in value.docs) {
          await firestore.doc(doc.reference.path).delete();
        }
      });

      // delete user records from REPORTS table
      await firestore.collection(REPORTS).where('source', isEqualTo: MyAppState.currentUser!.userID).get().then((value) async {
        for (var doc in value.docs) {
          await firestore.doc(doc.reference.path).delete();
        }
      });

      // delete user records from REPORTS table
      await firestore.collection(REPORTS).where('dest', isEqualTo: MyAppState.currentUser!.userID).get().then((value) async {
        for (var doc in value.docs) {
          await firestore.doc(doc.reference.path).delete();
        }
      });

      // delete user records from users table
      await firestore.collection(USERS).doc(auth.FirebaseAuth.instance.currentUser!.uid).delete();

      // delete user  from firebase auth
      await auth.FirebaseAuth.instance.currentUser!.delete();
    } catch (e, s) {
      print('FireStoreUtils.deleteUser $e $s');
    }
  }

  void closeDineInStream() {
    // allDineInResaturantStreamController.close;
    // popularStreamController.close;
  }

  Future<List> getVendorCusions(String id) async {
    List tagList = [];
    List prodtagList = [];
    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore.collection(PRODUCTS).where('vendorID', isEqualTo: id).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      if (document.data().containsKey("categoryID") && document.data()['categoryID'].toString().isNotEmpty) {
        prodtagList.add(document.data()['categoryID']);
      }
    });
    QuerySnapshot<Map<String, dynamic>> catQuery = await firestore.collection(CATEGORIES).get();
    await Future.forEach(catQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      Map<String, dynamic> catDoc = document.data();
      if (catDoc.containsKey("id") &&
          catDoc['id'].toString().isNotEmpty &&
          catDoc.containsKey("title") &&
          catDoc['title'].toString().isNotEmpty &&
          prodtagList.contains(catDoc['id'])) {
        tagList.add(catDoc['title']);
      }
    });

    return tagList;
  }

  getContactUs() async {
    Map<String, dynamic> contactData = {};
    await firestore.collection(Setting).doc(CONTACT_US).get().then((value) {
      if (value != null) {
        contactData = value.data()!;
      }
    });

    return contactData;
  }
}

/// send back/fore ground notification to the user related to this token
/// @param token the firebase token associated to the user
/// @param title the notification title
/// @param body the notification body
/// @param payload this is a map of data required if you want to handle click
/// events on the notification from system tray when the app is in the
/// background or killed
sendNotification(String token, String title, String body, Map<String, dynamic>? payload) async {
  await http.post(
    Uri.parse('https://fcm.googleapis.com/fcm/send'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$SERVER_KEY',
    },
    body: jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{'body': body, 'title': title},
        'priority': 'high',
        'data': payload ?? <String, dynamic>{},
        'to': token
      },
    ),
  );
}
