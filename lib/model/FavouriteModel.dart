class FavouriteModel {
  String? restaurant_id;
  String? user_id;

  FavouriteModel({this.restaurant_id, this.user_id});

  factory FavouriteModel.fromJson(Map<String, dynamic> parsedJson) {
    return new FavouriteModel(restaurant_id: parsedJson["restaurant_id"] ?? "", user_id: parsedJson["user_id"] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {"restaurant_id": this.restaurant_id, "user_id": this.user_id};
  }
}
