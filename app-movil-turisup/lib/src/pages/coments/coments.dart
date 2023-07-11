import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:turismup/src/utils/AppColor.dart';

class ComentarioWidget extends StatefulWidget {
  final String comentario;
  final String nombre;
  final double valoracion;
  final String foto;

  // ignore: use_key_in_widget_constructors
  const ComentarioWidget(
      {required this.comentario,
      required this.nombre,
      required this.valoracion,
      required this.foto});

  @override
  State<ComentarioWidget> createState() => _ComentarioWidgetState();
}

class _ComentarioWidgetState extends State<ComentarioWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 0),
      // padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          cabecera(widget.foto),
          calificacion(),
          // comentarioText(),
        ],
      ),
    );
  }

  Widget comentarioText() {
    return Container(
      width: 350,
      height: 60,
      alignment: Alignment.centerLeft,
      margin:
          const EdgeInsets.only(left: 20.0, top: 10.0, right: 20, bottom: 20),
      child: SingleChildScrollView(
        child: ReadMoreText(widget.comentario,
            colorClickableText: Colors.blue[300],
            trimMode: TrimMode.Line,
            trimLines: 3,
            trimCollapsedText: 'Leer mas',
            trimExpandedText: 'Leer menos',
            style: const TextStyle(fontSize: 13.0)),
      ),
    );
  }

  Widget calificacion() {
    String fecha = '10/01/2023';
    return Container(
        child: Row(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 2, left: 20, bottom: 2),
          child: RatingBar.builder(
            initialRating: widget.valoracion,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 16,
            itemPadding: EdgeInsets.only(right: 3),
            unratedColor: AppColor.unratedStarColor,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: AppColor.ratedStarColor,
            ),
            ignoreGestures: true,
            onRatingUpdate: (rating) {
              print(rating);
            },
          ),
        ),
        Container(margin: EdgeInsets.only(left: 10), child: Text('$fecha'))
      ],
    ));
  }

  Widget cabecera(String url) {
    // aqui deberia ir el enlacde de la foto de perfil
    // String urlImagen = widget.foto;
    // String urlImagen =
    //     'https://static.vecteezy.com/system/resources/previews/005/337/799/non_2x/icon-image-not-found-free-vector.jpg';
    String urlImagen = url;
    return Container(
      margin: const EdgeInsets.only(top: 0, left: 0, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        // ignore: prefer_const_literals_to_create_immutables
        children: <Widget>[
          // ignore: prefer_const_constructors
          Padding(
            padding:
                // Margenes dentro del cuadro de la imagen de usuario
                const EdgeInsets.only(top: 5, left: 20, bottom: 5, right: 20),
            // ignore: prefer_const_constructors
            child: CircleAvatar(
              // backgroundImage: NetworkImage(
              //     'https://static.vecteezy.com/system/resources/previews/005/337/799/non_2x/icon-image-not-found-free-vector.jpg'),
              backgroundImage: NetworkImage(urlImagen),
              radius: 30,
            ),
          ),
          Container(
            width: 150,
            alignment: Alignment.centerLeft,
            child: Text(
              widget.nombre,
              textAlign: TextAlign.left,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            // ignore: prefer_const_literals_to_create_immutables
          ),
        ],
      ),
    );
  }
}
