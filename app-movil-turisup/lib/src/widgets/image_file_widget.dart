
import 'dart:io';

import 'package:flutter/material.dart';

Future<Widget> ImageFileWidget(String path) async {
  File localImage = File (path);
  if(await localImage.exists()){
  return Image.file(localImage,fit: BoxFit.cover,);
  }else{
  return Image.asset("assets/imageNotFound.jpg",fit: BoxFit.cover,);
  }
}