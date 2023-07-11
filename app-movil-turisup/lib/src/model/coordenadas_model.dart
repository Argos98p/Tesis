class Coordenadas {
  late double latitud;
  late double longitud;

  Coordenadas({ required this.latitud,  required this.longitud});

  Coordenadas.fromJson(Map<String, dynamic> json) {
    latitud = json['latitud'];
    longitud = json['longitud'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['latitud'] = this.latitud;
    data['longitud'] = this.longitud;
    return data;
  }
}