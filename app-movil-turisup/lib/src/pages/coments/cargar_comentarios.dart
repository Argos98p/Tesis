import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../model/datos_comment.dart';
import 'coments.dart';

// import 'package:photo_view/photo_view.dart';
// import 'package:photo_view/photo_view_gallery.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: camel_case_types
class cargarComentarios extends StatefulWidget {
  final String id;
  final myFunc;
  // ignore: use_key_in_widget_constructors
  const cargarComentarios({
    super.key,
    required this.id,
    required this.myFunc
  });

  @override
  State<cargarComentarios> createState() => _cargarComentariosState();
}

class _cargarComentariosState extends State<cargarComentarios> {
  late Future<List<Datos_Comment>> comentariosFuture = getComents();
  List<Datos_Comment> datos = [];


  Future<List<Datos_Comment>> getComents() async {
    Map<String, String> modelo = <String, String>{};
    String model = json.encode(modelo);
    String urlB = 'http://35.222.144.68:8083/api/comentario?lugarId=';
    String urlA = widget.id;
    String urlf = urlB + urlA;
    // print(widget.id);
    final response = await http.get(
      Uri.parse(urlf),
    );
    final body = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 500) {
      datos = [];
      return datos;
    } else {
      datos = body.map<Datos_Comment>(Datos_Comment.formJson).toList();
      widget.myFunc(datos.length);

      return body.map<Datos_Comment>(Datos_Comment.formJson).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (datos.isEmpty) ? 150 : 300,
      child: FutureBuilder<List<Datos_Comment>>(
          future: comentariosFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final comments = snapshot.data!;
              if (comments.isEmpty) {
                return const Center(child: Text('No existen comentarios'));
              } else {
                return bulidComments(comments);
              }
            } else {
              return const  CircularProgressIndicator();
            }
          }),
    );
  }

  Widget bulidComments(List<Datos_Comment> comment) {
    return ListView.builder(
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        itemCount: comment.length,
        itemBuilder: (context, index) {
          final coment = comment[index];
          return ComentarioWidget(
            comentario: coment.comentario,
            nombre: coment.user?['nombre'],
            valoracion: (coment.puntaje).toDouble(),
            foto: coment.user?['foto'],
          );
        });
  }
}