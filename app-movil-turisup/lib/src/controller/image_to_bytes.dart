import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> imageToBytes(String path) async {
  Size size = const Size(150.0, 150.0);
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Radius radius = Radius.circular(size.width / 2);
  final Paint shadowPaint = Paint()..color = Color.fromARGB(255, 63, 125, 254);
  const double shadowWidth = 15.0;
  final Paint borderPaint = Paint()..color = Colors.white;
  const double borderWidth = 3.0;
  const double imageOffset = shadowWidth + borderWidth;
  late Uint8List bytes;

  Future<ui.Image> getImageFromPath(String path) async {
    //File imageFile = File(path);
    final archivo = await DefaultCacheManager().getSingleFile(path);
    bytes = await archivo.readAsBytes();
    Uint8List imageBytes = bytes;

    final Completer<ui.Image> completer = Completer();

    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });

    return completer.future;
  }

  // Add shadow circle
  canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0.0, 0.0, size.width, size.height),
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ),
      shadowPaint);

  // Add border circle
  canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(shadowWidth, shadowWidth, size.width - (shadowWidth * 2),
            size.height - (shadowWidth * 2)),
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ),
      borderPaint);

  // Oval for the image
  Rect oval = Rect.fromLTWH(imageOffset, imageOffset,
      size.width - (imageOffset * 2), size.height - (imageOffset * 2));

  // Add path for oval image
  canvas.clipPath(Path()..addOval(oval));

  // Add image
  ui.Image image = await getImageFromPath(
      path); // Alternatively use your own method to get the image
  paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fitWidth);

  // Convert canvas to image
  final ui.Image markerAsImage = await pictureRecorder
      .endRecording()
      .toImage(size.width.toInt(), size.height.toInt());

  // Convert image to bytes
  final ByteData? byteData =
      await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List? uint8List = byteData?.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(uint8List!);
}
