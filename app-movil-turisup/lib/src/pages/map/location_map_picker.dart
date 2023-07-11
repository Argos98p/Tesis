import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart'; // ignore: unnecessary_import
import 'package:get_it/get_it.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:turismup/src/pages/map/my_location_marker.dart';
import 'package:turismup/src/service/connectivity_utils.dart';

import '../../utils/AppColor.dart';

const randomMarkerNum = 2;

class LocationMapPicker extends StatefulWidget {
  final  _myFunction;
  const LocationMapPicker(this._myFunction, {super.key});

  @override
  State createState() => _LocationMapPickerState();
}

class _LocationMapPickerState extends State<LocationMapPicker>
    {
  final Random _rnd = new Random();
  late CameraPosition _kInitialPosition;
  final CameraTargetBounds _cameraTargetBounds;
  static double defaultZoom = 12.0;
  CameraPosition _position;
   MapboxMapController? _mapController;
  final bool _compassEnabled = true;
  final MinMaxZoomPreference _minMaxZoomPreference =
      const MinMaxZoomPreference(10.0, 24.0);
  final bool _rotateGesturesEnabled = true;
  final bool _scrollGesturesEnabled = true;
  final bool _tiltGesturesEnabled = false;
  final bool _zoomGesturesEnabled = true;
  List<Marker> _markers = [];
  List<_MarkerState> _markerStates = [];
  bool isPlaceSelected = true;
  Location location = Location();
  int itemIndexSelect = 0;
  final String _styleString = "mapbox://styles/mapbox/streets-v11";
  _LocationMapPickerState._(
      this._kInitialPosition, this._position, this._cameraTargetBounds);

  @override
  void initState() {

    // TODO: implement initState

    super.initState();

  }

  @override
  void dispose() {
    // TODO: implement dispose1

    _mapController!.dispose();
    super.dispose();
  }


  static CameraPosition _getCameraPosition() {
    const latLng = LatLng(-2.899126, -79.014958);
    return CameraPosition(
      target: latLng,
      zoom: defaultZoom,
    );
  }

  factory _LocationMapPickerState() {
    CameraPosition cameraPosition = _getCameraPosition();

    final cityBounds = LatLngBounds(
      southwest: const LatLng(-3.435455, -78.447153),
      northeast: const LatLng(-2.407281, -79.560420),
    );

    return _LocationMapPickerState._(
        cameraPosition, cameraPosition, CameraTargetBounds(cityBounds));
  }



  void _extractMapInfo() {
    _position = _mapController!.cameraPosition!;
    //_isMoving = _mapController.isCameraMoving;
  }

  void _addMarkerStates(_MarkerState markerState) {
    _markerStates.add(markerState);
  }

  Future<void> _onMapCreated(MapboxMapController controller) async {
    _mapController = controller;


    controller.addListener(() {
      if (controller.isCameraMoving) {
        isPlaceSelected = false;
        setState(() {});
        _updateMarkerPosition();
      }
    });
    _extractMapInfo();
    setState(() {});
  }

  void _onStyleLoadedCallback() {
    print('onStyleLoadedCallback');
  }

  void _updateMarkerPosition() {
    if(_markers.isNotEmpty){
      final coordinates = <LatLng>[];

      coordinates.add(_markerStates[0].getCoordinate());


      _mapController!.toScreenLocationBatch(coordinates).then((points) {
        if(points.isNotEmpty){
          _markerStates[0].updatePosition(points[0]);

        }

      });
    }

  }

  void _addMarker(Point<double> point, LatLng coordinates) {
    _markers.add(Marker(
        _rnd.nextInt(100000).toString(), coordinates, point, _addMarkerStates));

    setState(() {});
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            FloatingActionButton.extended(
              heroTag: "cancelar",
              backgroundColor: AppColor.primaryColorOpacity,
              foregroundColor: AppColor.primaryColor,
              onPressed: () {
                Navigator.pop(context);
              },

              label: const Text('Cancelar'),
            ),
            FloatingActionButton.extended(
              heroTag: "aceptar",
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
              onPressed: () {
                widget._myFunction(_markerStates[0].getCoordinate());
                Navigator.pop(context);
              },
              label: const Text('Aceptar'),
            )
          ],
        ),
      ),
      body: Stack(children: [
        MapboxMap(
          //myLocationEnabled: true,
          accessToken:
              "pk.eyJ1IjoianVhbmtsbDIyOTQiLCJhIjoiY2xkamxpc2lvMHpoeDNwbGxsNnJ0d2QxcSJ9.HBz6_Ry_0l5CPyOmyKfZqw",
          trackCameraPosition: true,
          compassEnabled: _compassEnabled,
          onMapCreated: _onMapCreated,
          //onMapLongClick: _onMapLongClickCallback,
          onMapClick: (point, latLng) async {
            if(_markers.isEmpty){
              _addMarker(point, latLng);

            }else{
              _markers[0].setNewCoordinates(latLng);
              _markerStates[0].setPosition(point);
              _updateMarkerPosition();
            }


          },
          onStyleLoadedCallback: _onStyleLoadedCallback,
          initialCameraPosition: _kInitialPosition,
          cameraTargetBounds: _cameraTargetBounds,
          minMaxZoomPreference: _minMaxZoomPreference,
          styleString: _styleString,
          rotateGesturesEnabled: _rotateGesturesEnabled,
          scrollGesturesEnabled: _scrollGesturesEnabled,
          tiltGesturesEnabled: _tiltGesturesEnabled,
          zoomGesturesEnabled: _zoomGesturesEnabled,
        ),
        IgnorePointer(
            ignoring: true,
            child: Stack(
              children: _markers,
            )),
        /*
        Positioned(
          bottom: 50,
            child: Row(
          children: [
            ElevatedButton(onPressed: (){}, child: Text("Cancelar")),
            ElevatedButton(onPressed: (){}, child: Text("Aceptar")),
          ],
        ))*/

        /*IgnorePointer(
              child: MyLocationMarker(_animationController),
            )*/
      ]),
    );
  }
}


class Marker extends StatefulWidget {
  final Point _initialPosition;
  LatLng _coordinate;
  final void Function(_MarkerState) _addMarkerState;

  Marker(
      String key, this._coordinate, this._initialPosition, this._addMarkerState)
      : super(key: Key(key));

  void setNewCoordinates(LatLng newLocation) {
    _coordinate = newLocation;
  }

  @override
  State<StatefulWidget> createState() {
    final state = _MarkerState(_initialPosition);
    _addMarkerState(state);
    return state;
  }
}

class _MarkerState extends State {
  final _iconSize = 20.0;
  Point _position;

  _MarkerState(
    this._position,
  );

  setPosition(Point newPosition) {
    _position = newPosition;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var ratio = 1.0;
    var userLocationAnimationSize = MediaQuery.of(context).size.width * 0.7;
    //web does not support Platform._operatingSystem
    if (!kIsWeb) {
      // iOS returns logical pixel while Android returns screen pixel
      ratio = Platform.isIOS ? 1.0 : MediaQuery.of(context).devicePixelRatio;
    }

    return Positioned(
        left: _position.x / ratio - _iconSize / 2,
        top: _position.y / ratio - _iconSize / 2,
        child: Image.asset("assets/images/location.png",height: 30,width: 30,)/*Icon(FontAwesomeIcons.locationDot, color: AppColor.primaryColor,)*/
    );
  }

  void updatePosition(Point<num> point) {
    setState(() {
      _position = point;
    });
  }

  LatLng getCoordinate() {
    return (widget as Marker)._coordinate;
  }
}
