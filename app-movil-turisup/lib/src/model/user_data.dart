class UserData {
  int id;
  String token;
  String email;
  String nombre;
  String urlPhoto;

  UserData({
    required this.id,
    required this.token,
    required this.email,
    required this.nombre,
    required this.urlPhoto,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      token: json['token'],
      email: json['email'],
      nombre: json['nombre'],
      urlPhoto: json['urlPhoto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'email': email,
      'nombre': nombre,
      'urlPhoto': urlPhoto,
    };
  }

  @override
  String toString() {
    return 'UserData{id: $id, token: $token, email: $email, nombre: $nombre, urlPhoto: $urlPhoto}';
  }
}