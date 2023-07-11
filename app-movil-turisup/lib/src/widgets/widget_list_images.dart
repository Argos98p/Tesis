import 'dart:io';

import 'package:flutter/material.dart';
Widget listaFotos(List paths, bool isOffline) {
  return Container(
    margin: const EdgeInsets.only(top: 15),
    width: double.infinity,
    height: 150,
    child: Row(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: paths.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      10), // define el radio del borde redondeado
                  child: isOffline ? Image.file(
                    File(paths[index]),
                    width: 150, // define el ancho de la imagen
                    height: 150, // define la altura de la imagen
                    fit: BoxFit.cover,
                  ) : Image.network(
                    paths[index],
                    width: 150, // define el ancho de la imagen
                    height: 150, // define la altura de la imagen
                    fit: BoxFit.cover,
                  ),
                ),
                // child: Text('$paths[index]'),
              );
            },
          ),
        )
      ],
    ),
  );
}