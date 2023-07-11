import 'package:flutter/material.dart';

Widget TitleWidget(mensaje){
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(mensaje, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
  );
}