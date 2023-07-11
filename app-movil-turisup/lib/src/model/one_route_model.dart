import 'package:turismup/src/model/place_model.dart';

class OneRouteModel {
  String? descripcion;
  String? creador;
  String? id;
  String? nombre;
  List<PlaceModel>? lugares;

  OneRouteModel(
      {this.id, this.descripcion, this.lugares, this.creador, this.nombre});

  OneRouteModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descripcion = json['descripcion'];
    creador = json['creador'];
    nombre = json['nombre'];
    if (json['lugares'] != null) {
      lugares = <PlaceModel>[];
      json['lugares'].forEach((v) {
        if (v != null) {
          lugares!.add(PlaceModel.fromJson(v));
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['descripcion'] = this.descripcion;
    data['creador'] = this.creador;
    data['id'] = this.id;
    if (this.lugares != null) {
      data['lugares'] = this.lugares!.map((v) => v.toJson()).toList();
    }
    data['nombre'] = this.nombre;
    return data;
  }
}
