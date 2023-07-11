class Datos_Comment {
  List? imagenes = [];
  int puntaje;
  String id = '';
  String comentario = '';
  List? video = [];
  Map? user = {};

  Datos_Comment({
    this.imagenes,
    required this.puntaje,
    required this.id,
    required this.comentario,
    this.video,
    this.user,
  });

  static Datos_Comment formJson(json) => Datos_Comment(
      imagenes: json['imagenes'],
      puntaje: json['puntaje'],
      id: json['id'],
      comentario: json['comentario'],
      video: json['video'],
      user: json['user']);
}
