import '../constants.dart';

class CuisineModel {
  String id;

  String order;

  String photo;

  String title;

  CuisineModel({this.id = '', this.order = '', this.photo = '', this.title = ''});

  factory CuisineModel.fromJson(Map<String, dynamic> parsedJson) {
    return CuisineModel(
        id: parsedJson['id'] ?? '',
        order: (parsedJson['order'] != null) ? ((parsedJson['order'] is int) ? parsedJson['order'].toString() : parsedJson['order']) : '',
        photo: (parsedJson['photo'] == null || parsedJson['photo'].toString().isEmpty) ? placeholderImage : parsedJson['photo'],
        title: parsedJson['title'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': this.id, 'order': this.order, 'photo': this.photo, 'title': this.title};
  }
}
