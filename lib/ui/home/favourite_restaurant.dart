import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_eats_consumer/main.dart';
import 'package:uber_eats_consumer/model/FavouriteModel.dart';
import 'package:uber_eats_consumer/model/VendorModel.dart';
import 'package:uber_eats_consumer/services/FirebaseHelper.dart';
import 'package:uber_eats_consumer/services/helper.dart';
import 'package:uber_eats_consumer/ui/vendorProductsScreen/VendorProductsScreen.dart';

import '../../constants.dart';

class FavouriteRestaurantScreen extends StatefulWidget {
  const FavouriteRestaurantScreen({Key? key}) : super(key: key);

  @override
  _FavouriteRestaurantScreenState createState() => _FavouriteRestaurantScreenState();
}

class _FavouriteRestaurantScreenState extends State<FavouriteRestaurantScreen> {
  late Future<List<VendorModel>> vendorFuture;
  final fireStoreUtils = FireStoreUtils();
  List<VendorModel> restaurantAllLst = [];
  List<FavouriteModel> lstFavourite = [];
  var position = LatLng(23.12, 70.22);
  bool showLoader = true;
  String placeHolderImage = "";
  VendorModel? vendorModel = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fireStoreUtils.getplaceholderimage().then((value) {
      placeHolderImage = value!;
    });
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Colors.white,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
            child: showLoader
                ? Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                    ),
                  )
                : lstFavourite.length == 0
                    ? showEmptyState('No Favourite Vendors'.tr(), 'Start by adding favourite vendors'.tr())
                    : ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: BouncingScrollPhysics(),
                        itemCount: lstFavourite.length,
                        itemBuilder: (context, index) {
                          if (restaurantAllLst.length != 0) {
                            for (int a = 0; a < restaurantAllLst.length; a++) {
                              print(restaurantAllLst[a].id.toString() + "===<><>FR<><==" + lstFavourite[index].restaurant_id!);
                              if (restaurantAllLst[a].id == lstFavourite[index].restaurant_id) {
                                vendorModel = restaurantAllLst[a];
                              } else {}
                            }
                          }
                          return vendorModel == null ? Container() : buildAllRestaurantsData(vendorModel!, index);
                        })));
  }

  Widget buildAllRestaurantsData(VendorModel vendorModel, int index) {
    return GestureDetector(
      onTap: () => push(
        context,
        VendorProductsScreen(vendorModel: vendorModel),
      ),
      child: Container(
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(10),
          color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
        ),
        width: MediaQuery.of(context).size.width * 0.8,
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: new BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: getImageVAlidUrl(vendorModel.photo),
                height: 100,
                width: 100,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Center(
                    child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                )),
                errorWidget: (context, url, error) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      placeHolderImage,
                      fit: BoxFit.cover,
                    )),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendorModel.title,
                          style: TextStyle(
                            fontFamily: "Poppinssm",
                            fontSize: 18,
                            color: isDarkMode(context) ? Colors.white : Color(0xff000000),
                          ),
                          maxLines: 1,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            print(lstFavourite.length.toString() + "----REMOVE");
                            FavouriteModel favouriteModel =
                                FavouriteModel(restaurant_id: vendorModel.id, user_id: MyAppState.currentUser!.userID);
                            lstFavourite.removeWhere((item) => item == vendorModel.id);
                            fireStoreUtils.removeFavouriteRestaurant(favouriteModel);

                            lstFavourite.removeAt(index);
                          });
                        },
                        child: Icon(
                          Icons.favorite,
                          color: Color(COLOR_PRIMARY),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    vendorModel.location,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: "Poppinssm",
                      fontSize: 16,
                      color: isDarkMode(context) ? Colors.white60 : Color(0xff9091A4),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 20,
                        color: Color(COLOR_PRIMARY),
                      ),
                      SizedBox(width: 3),
                      Text(
                          vendorModel.reviewsCount != 0
                              ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}'
                              : 0.toString(),
                          style: TextStyle(
                            fontFamily: "Poppinssr",
                            letterSpacing: 0.5,
                            color: isDarkMode(context) ? Colors.white70 : Color(0xff000000),
                          )),
                      SizedBox(width: 3),
                      Text('(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                          style: TextStyle(
                            fontFamily: "Poppinssr",
                            letterSpacing: 0.5,
                            color: isDarkMode(context) ? Colors.white60 : Color(0xff666666),
                          )),
                      SizedBox(width: 5),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void getData() {
    fireStoreUtils.getFavouriteRestaurant(MyAppState.currentUser!.userID).then((value) {
      if (value != null) {
        setState(() {
          lstFavourite.clear();
          lstFavourite.addAll(value);
        });
      }
    });
    vendorFuture = fireStoreUtils.getVendors();

    vendorFuture.then((value) {
      if (value != null) {
        setState(() {
          restaurantAllLst.clear();
          restaurantAllLst.addAll(value);
          print(restaurantAllLst.length.toString() + "===FR" + value.length.toString());
          showLoader = false;
        });
      }
    });
  }
}
