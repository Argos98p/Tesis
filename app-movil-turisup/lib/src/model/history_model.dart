import 'package:turismup/src/model/place_model.dart';

class  HistoryModel {
  String? date;
  int? rating;
  String? contenido;
  String? comentarioId;
  String? placeId;
  PlaceModel? place;

  HistoryModel(
      {this.date,
        this.rating,
        this.contenido,
        this.comentarioId,
        this.placeId,
        this.place
      });

  HistoryModel.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    rating = json['rating'];
    contenido = json['contenido'];
    comentarioId = json['comentarioId'];
    placeId = json['placeId'];
    place = PlaceModel.fromJson(json['place']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['rating'] = this.rating;
    data['contenido'] = this.contenido;
    data['comentarioId'] = this.comentarioId;
    data['placeId'] = this.placeId;
    data['place'] = this.place;
    return data;
  }
}