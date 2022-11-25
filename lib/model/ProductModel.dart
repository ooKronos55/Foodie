import 'package:uber_eats_consumer/constants.dart';

class ProductModel {
  String categoryID;

  String description;

  String id;

  String photo;

  List<dynamic> photos;

  String price;

  String name;

  String vendorID;

  int quantity;

  bool publish;

  int calories;

  int grams;

  int proteins;

  int fats;

  bool veg;

  bool nonveg;

  String? disPrice = "0";
  bool takeaway;

  List<dynamic> size;

  List<dynamic> sizePrice;

  List<dynamic> addOnsTitle = [];

  List<dynamic> addOnsPrice = [];

  ProductModel(
      {this.categoryID = '',
      this.description = '',
      this.id = '',
      required this.photo,
      this.photos = const [],
      this.price = '',
      this.name = '',
      this.quantity = 1,
      this.vendorID = '',
      this.calories = 0,
      this.grams = 0,
      this.proteins = 0,
      this.fats = 0,
      this.publish = true,
      this.veg = true,
      this.nonveg = true,
      this.disPrice,
      this.takeaway = false,
      this.addOnsPrice = const [],
      this.addOnsTitle = const [],
      this.size = const [],
      this.sizePrice = const []});

  factory ProductModel.fromJson(Map<String, dynamic> parsedJson) {
    int gdval = 0;
    if (parsedJson['grams'] == null || parsedJson['grams'] == double.nan || parsedJson['grams'] == double.infinity) {
      gdval = 0;
    } else {
      gdval =
          (parsedJson['grams'] is double) ? (parsedJson["grams"].isNaN ? 0 : (parsedJson['grams'] as double).toInt()) : parsedJson['grams'];
    }
    int ptval = 0;
    if (parsedJson['proteins'] == null || parsedJson['proteins'] == double.nan || parsedJson['proteins'] == double.infinity) {
      ptval = 0;
    } else {
      ptval = (parsedJson['proteins'] is double)
          ? (parsedJson["proteins"].isNaN ? 0 : (parsedJson['proteins'] as double).toInt())
          : parsedJson['proteins'];
    }

    int ftval = 0;
    if (parsedJson['fats'] == null || parsedJson['fats'] == double.nan || parsedJson['fats'] == double.infinity) {
      ftval = 0;
    } else {
      ftval = (parsedJson['fats'] is double) ? (parsedJson["fats"].isNaN ? 0 : (parsedJson['fats'] as double).toInt()) : parsedJson['fats'];
    }

    int clval = 0;
    if (parsedJson['calories'] == null || parsedJson['calories'] == double.nan || parsedJson['calories'] == double.infinity) {
      clval = 0;
    } else {
      clval = (parsedJson['calories'] is double)
          ? (parsedJson["calories"].isNaN ? 0 : (parsedJson['calories'] as double).toInt())
          : parsedJson['calories'];
    }
    int qtval = 0;
    if (parsedJson['quantity'] == null || parsedJson['quantity'] == double.nan || parsedJson['quantity'] == double.infinity) {
      qtval = 0;
    } else {
      if (parsedJson['quantity'] is String) {
        qtval = int.parse(parsedJson['quantity']);
      } else {
        qtval = (parsedJson['quantity'] is double)
            ? (parsedJson["quantity"].isNaN ? 0 : (parsedJson['quantity'] as double).toInt())
            : parsedJson['quantity'];
      }
    }

    return new ProductModel(
      categoryID: parsedJson['categoryID'] ?? '',
      description: parsedJson['description'] ?? '',
      id: parsedJson['id'] ?? '',
      photo: parsedJson.containsKey('photo') ? parsedJson['photo'] : placeholderImage,
      photos: parsedJson['photos'] ?? [],
      price: parsedJson['price'] ?? '',
      quantity: qtval,
      name: parsedJson['name'] ?? '',
      vendorID: parsedJson['vendorID'] ?? '',
      publish: parsedJson['publish'] ?? true,
      calories: clval,
      grams: gdval,
      proteins: ptval,
      fats: ftval,
      nonveg: parsedJson['nonveg'] ?? false,
      veg: parsedJson['veg'] ?? false,
      disPrice: parsedJson['disPrice'] ?? '0',
      takeaway: parsedJson['takeawayOption'] == null ? false : parsedJson['takeawayOption'],
      size: parsedJson['size'] ?? [],
      sizePrice: parsedJson['sizePrice'] ?? [],
      addOnsPrice: parsedJson['addOnsPrice'] ?? [],
      addOnsTitle: parsedJson['addOnsTitle'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    photos.toList().removeWhere((element) => element == null);
    return {
      'categoryID': this.categoryID,
      'description': this.description,
      'id': this.id,
      'photo': this.photo,
      'photos': this.photos,
      'price': this.price,
      'name': this.name,
      'quantity': this.quantity,
      'vendorID': this.vendorID,
      'publish': this.publish,
      'calories': this.calories,
      'grams': this.grams,
      'proteins': this.proteins,
      'fats': this.fats,
      'veg': this.veg,
      'nonveg': this.nonveg,
      'takeawayOption': this.takeaway,
      'disPrice': this.disPrice,
      'size': this.size,
      'sizePrice': this.sizePrice,
      "addOnsTitle": this.addOnsTitle,
      "addOnsPrice": this.addOnsPrice
    };
  }
}
