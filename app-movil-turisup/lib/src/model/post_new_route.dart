class PostNewRoute {
  String? userId;
  String? nombre;
  String? descripcion;
  List<String>? lugares;

  PostNewRoute({this.userId, this.nombre, this.descripcion, this.lugares});

  PostNewRoute.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    nombre = json['nombre'];
    descripcion = json['descripcion'];
    lugares = json['lugares'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['nombre'] = this.nombre;
    data['descripcion'] = this.descripcion;
    data['lugares'] = this.lugares;
    return data;
  }
}