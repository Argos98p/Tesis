import 'coordenadas_model.dart';

class PlaceModel {
  String? id;
  String? nombre;
  String? status;
  Coordenadas? coordenadas;
  String? descripcion;
  List<String>? imagenesPaths;
  List<String>? fbVideoIds;
  List<String>? fbImagenesIds;
  Organizacion? organizacion;
  Organizacion? region;
  User? user;
  double? distancia;
  String? fecha;
  String? categoria;
  List<String>? localImages;
  bool? esFavorito;
  double? rate;

  PlaceModel(
      {this.id,
      this.nombre,
      this.status,
      this.coordenadas,
      this.descripcion,
      this.imagenesPaths,
      this.fbVideoIds,
      this.fbImagenesIds,
      this.organizacion,
      this.region,
      this.user,
      this.distancia,
      this.fecha,
      this.localImages,
      this.categoria,
      this.esFavorito,
      this.rate});

  PlaceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nombre = json['nombre'];
    status = json['status'];
    localImages =
        json['localImages'] != null ? json['localImages'].cast<String>() : [];
    coordenadas = json['coordenadas'] != null
        ? new Coordenadas.fromJson(json['coordenadas'])
        : null;
    descripcion = json['descripcion'];
    imagenesPaths = json['imagenesPaths'].cast<String>();
    fbVideoIds = json['fbVideoIds'].cast<String>();
    fbImagenesIds = json['fbImagenesIds'].cast<String>();
    organizacion = json['organizacion'] != null
        ? new Organizacion.fromJson(json['organizacion'])
        : null;
    region = json['region'] != null
        ? new Organizacion.fromJson(json['region'])
        : null;
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    distancia = json['distancia'];
    fecha = json['fecha'];
    categoria = json['categoria'];
    esFavorito = json["favorito"] == "si" ? true : false;
    rate = json['rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nombre'] = this.nombre;
    data['status'] = this.status;
    data['localImages'] = this.localImages;
    if (this.coordenadas != null) {
      data['coordenadas'] = this.coordenadas?.toJson();
    }
    data['descripcion'] = this.descripcion;
    data['imagenesPaths'] = this.imagenesPaths;
    data['fbVideoIds'] = this.fbVideoIds;
    data['fbImagenesIds'] = this.fbImagenesIds;
    if (this.organizacion != null) {
      data['organizacion'] = this.organizacion?.toJson();
    }
    if (this.region != null) {
      data['region'] = this.region?.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user?.toJson();
    }
    data['distancia'] = this.distancia;
    data['fecha'] = this.fecha;
    data['categoria'] = this.categoria;
    data['favorito'] = this.esFavorito == true ? "si" : "no";
    data['rate'] = this.rate;
    return data;
  }
}

class Organizacion {
  late String id;
  late String nombre;

  Organizacion({required this.id, required this.nombre});

  Organizacion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nombre = json['nombre'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nombre'] = this.nombre;
    return data;
  }
}

class User {
  late String image;
  late String id;
  late String nombre;

  User({required this.image, required this.id, required this.nombre});

  User.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    id = json['id'];
    nombre = json['nombre'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user'] = this.image;
    data['id'] = this.id;
    data['image'] = this.image;
    return data;
  }
}

class DatosModel {
  List<PlaceModel> datos = [];
  String? error;
  DatosModel({required this.datos});

  List<PlaceModel> get recursos {
    return datos;
  }

  DatosModel.withError(String errorMessage) {
    error = errorMessage;
  }
}
