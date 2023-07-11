import 'package:turismup/src/model/place_model.dart';

import 'coordenadas_model.dart';

class PostNewPlaceModel {
  String? nombre;
  Coordenadas? coordenadas;
  String? descripcion;
  List<String>? imagesPaths;
  String? userId;
  String? categoria;
  PostNewPlaceModel({
    this.nombre,
    this.coordenadas,
    this.descripcion,
    this.imagesPaths,
    this.userId,
    this.categoria
});

  PostNewPlaceModel.fromJson(Map<String, dynamic> json) {
    nombre= json["nombre"];
    coordenadas= json["coordenadas"]!= null
    ? Coordenadas?.fromJson(json['coordenadas'])
        : null;
    imagesPaths = json["imagesPaths"].cast<String>();
    descripcion = json["descripcion"];
    userId = json["userId"];
    categoria=json["categoria"];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nombre'] = nombre;
    data['coordenadas'] = coordenadas?.toJson();
    data['descripcion'] = descripcion;
    data['imagesPaths'] = imagesPaths;
    data['userId'] = userId;
    data['categoria'] = categoria;
    return data;
  }
}
