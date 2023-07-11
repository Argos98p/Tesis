import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarker{
  const MapMarker({
    required this.image,
    required this.title,
    required this.location,
});

  final String image;
  final String title;
  final LatLng location;

}