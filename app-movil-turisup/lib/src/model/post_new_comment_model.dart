class PostNewCommentModel {
  String? lugarId;
  List<String>? imagenes;
  int? puntaje;
  String? comentario;
  String? userId;

  PostNewCommentModel({this.lugarId,this.imagenes, this.puntaje, this.comentario, this.userId});

  PostNewCommentModel.fromJson(Map<String, dynamic> json) {
    lugarId = json["lugarId"];
    imagenes = json['imagenes'].cast<String>();
    puntaje = json['puntaje'];
    comentario = json['comentario'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lugarId'] = this.lugarId;
    data['imagenes'] = this.imagenes;
    data['puntaje'] = this.puntaje;
    data['comentario'] = this.comentario;
    data['userId'] = this.userId;
    return data;
  }
}