import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart'; // ignore: unnecessary_import
import 'package:get_it/get_it.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import 'package:turismup/src/pages/map/my_location_marker.dart';
import 'package:turismup/src/service/connectivity_utils.dart';

import '../../model/place_model.dart';
import '../../providers/km_around_provider.dart';
import '../../repository/place_repository.dart';
import '../../utils/AppColor.dart';
import '../../widgets/image_file_widget.dart';
import 'map_place_details.dart';
import 'route_map_multiple_places.dart';

const randomMarkerNum = 2;

class principal_map extends StatefulWidget {
  const principal_map({super.key});

  @override
  State createState() => _principal_mapState();
}

class _principal_mapState extends State<principal_map>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final _pageController = PageController();
  final Random _rnd = new Random();
  late CameraPosition _kInitialPosition;
  final CameraTargetBounds _cameraTargetBounds;
  static double defaultZoom = 12.0;
  CameraPosition _position;

  late MapboxMapController _mapController;
  final bool _compassEnabled = true;
  final MinMaxZoomPreference _minMaxZoomPreference =
      const MinMaxZoomPreference(8.0, 28.0);
  final bool _rotateGesturesEnabled = true;
  String filter = "todo";
  final bool _scrollGesturesEnabled = true;
  final bool _tiltGesturesEnabled = false;
  final bool _zoomGesturesEnabled = true;
  LocationData? _currentLocation;
  List<Marker> _markers = [];
  List<_MarkerState> _markerStates = [];
  List<PlaceModel> places = [];
  bool isPlaceSelected = false;
  Location location = Location();
  List<PlaceModel> selectedPlaces = [];
  List<PlaceModel> allPlaces = [];
  int itemIndexSelect = 0;
  bool isSelectedMode = false;
  double aux = 700;
  final PlaceRepository _placeRepository = GetIt.I.get();
  final String _styleString = "mapbox://styles/mapbox/streets-v11";
  _principal_mapState._(
      this._kInitialPosition, this._position, this._cameraTargetBounds);

  double kmAround = 80.0;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    // TODO: implement initState

    super.initState();
    getCurrentLocation();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getCurrentLocation();
      aux = MediaQuery.of(context).size.height - 120.0;
    });
    readLocalPlaces();
    kmAround = Provider.of<KmAroundProvider>(context, listen: false).km_around;
  }

  @override
  void dispose() {
    // TODO: implement dispose1
    _animationController.dispose();
    if (mounted) {
      _mapController.dispose();
    }

    super.dispose();
  }

  Widget _ButtonIni(String nombre) {
    return Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4),
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              filter = nombre;
              if (filter.toLowerCase().contains("todo") ||
                  "todo".contains(filter.toLowerCase())) {
                places = allPlaces;
              } else {
                String widgetCategory = filter.toLowerCase().split(" ")[2];

                places = allPlaces
                    .where((place) =>
                    place.categoria!.toLowerCase().split(",").contains(widgetCategory))
                    .toList();
              }
              initPlaceMarkers();

              print(filter);
              print(places);
            });
          },
          style: OutlinedButton.styleFrom(
            backgroundColor:
                filter == nombre ? AppColor.primaryColorOpacity : Colors.white,
            shape: StadiumBorder(),
          ),
          child: Text(nombre),
        ));
  }

  // ignore: non_constant_identifier_names
  Widget _CrearBotonesCabecera() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        _ButtonIni('✅  Todo'),
        _ButtonIni('🎭  Museo'),
        _ButtonIni('⛪  Iglesia'),
        _ButtonIni('🛶  Laguna'),
        _ButtonIni('🏞  Montaña'),
        _ButtonIni('🛌  Hotel'),
        Container(
          margin: EdgeInsetsDirectional.only(start: 30, end: 100),
          child: IconButton(
            onPressed: () {
              Fluttertoast.showToast(msg: "Actualizando...");
              _placeRepository.getAllPlaces().then((value) {
                places = value;

                allPlaces = value;
                initPlaceMarkers();
              });
            },
            icon: Icon(FontAwesomeIcons.refresh),
          ),
        ),
      ],
    );
  }

  setSelectMode() {
    isSelectedMode = true;
    for (int i = 0; i < _markerStates.length; i++) {
      _markerStates[i].updateSelectMode(true);
    }
  }

  addToSelectedPlaces(PlaceModel place, int index) {
    if (selectedPlaces.contains(place)) {
      selectedPlaces.remove(place);
      _markerStates[index].setIsSelected(false);
    } else {
      selectedPlaces.add(place);
      _markerStates[index].setIsSelected(true);
    }
    setState(() {});
  }

  setIndexPlaceSelected(int i) {
    setState(() {
      isPlaceSelected = true;
      itemIndexSelect = i - 1;
      _pageController.animateToPage(i - 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut);
    });
  }

  static CameraPosition _getCameraPosition() {
    const latLng = LatLng(-2.899126, -79.014958);
    return CameraPosition(
      target: latLng,
      zoom: defaultZoom,
    );
  }

  factory _principal_mapState() {
    CameraPosition cameraPosition = _getCameraPosition();

    final cityBounds = LatLngBounds(
      southwest: const LatLng(-3.721267, -79.935360),
      northeast: const LatLng(-1.955161, -77.238897),
    );

    return _principal_mapState._(
        cameraPosition, cameraPosition, CameraTargetBounds(cityBounds));
  }

  listenChangeCurrentLocation() async {
    location.onLocationChanged.listen(
      (newLoc) {
        _currentLocation = newLoc;
        if (mounted) {
          print(newLoc);
          if (_markerStates.isNotEmpty) {
            _markers[0]
                .setNewCoordinates(LatLng(newLoc.latitude!, newLoc.longitude!));
            if (mounted) {
              _mapController.toScreenLocationBatch(
                  [LatLng(newLoc.latitude!, newLoc.longitude!)]).then((value) {
                var point =
                    Point<double>(value[0].x as double, value[0].y as double);
                _markerStates[0].updatePosition(point);
              });
            }
          }
        }
      },
    );
  }

  Future<void> getCurrentLocation() async {
    Location location = Location();
    _currentLocation = await location.getLocation();
    setState(() {});
/*
    location.getLocation().then(
      (location) {
        _currentLocation = location;
        setState(() {});
      },
    );*/
  }

  void _extractMapInfo() {
    if (mounted) {
      _position = _mapController.cameraPosition!;
    }
  }

  void _addMarkerStates(_MarkerState markerState) {
    _markerStates.add(markerState);
  }

  Future<void> _onMapCreated(MapboxMapController controller) async {
    await getCurrentLocation();
    _mapController = controller;
    initPlaceMarkers();
    listenChangeCurrentLocation();
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

  void _onMapLongClickCallback(
      Point<double> point, LatLng coordinates, PlaceModel place, index) {
    _addMarker(point, coordinates, place, index);
  }

  void _onCameraIdleCallback() {
    _updateMarkerPosition();
  }

  void _updateMarkerPosition() {
    final coordinates = <LatLng>[];

    for (final markerState in _markerStates) {
      coordinates.add(markerState.getCoordinate());
    }

    if (mounted) {
      _mapController.toScreenLocationBatch(coordinates).then((points) {
        _markerStates.asMap().forEach((i, value) {
          _markerStates[i].updatePosition(points[i]);
        });
      });
    }
  }

  void _addMarker(
      Point<double> point, LatLng coordinates, PlaceModel? place, int index) {
    if (place == null) {
      _markers.add(Marker(
          _rnd.nextInt(100000).toString(),
          coordinates,
          point,
          _addMarkerStates,
          PlaceModel(),
          _animationController,
          index,
          setIndexPlaceSelected,
          addToSelectedPlaces,
          selectedPlaces,
          setSelectMode));
    } else {
      _markers.add(Marker(
          _rnd.nextInt(100000).toString(),
          coordinates,
          point,
          _addMarkerStates,
          place!,
          _animationController,
          index,
          setIndexPlaceSelected,
          addToSelectedPlaces,
          selectedPlaces,
          setSelectMode));
    }
    setState(() {});
  }

  Widget _getFAB() {
    if (isSelectedMode) {
      return FloatingActionButton.extended(
        backgroundColor: AppColor.primaryColorOpacity,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RouteMapMultiplePlaces(
                        recursos: selectedPlaces,
                      )));
        },
        label: Text(
          "Buscar ruta",
          style: TextStyle(color: AppColor.primaryColor),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  Future readLocalPlaces() async {
    List<PlaceModel> recursos = await _placeRepository.getAllPlaces();

    allPlaces = recursos;
    places = recursos;
    List<LatLng> myMarkers = <LatLng>[];

    if (_markers.isNotEmpty && _markers.length < 2) {
      for (PlaceModel place in places) {
        myMarkers.add(
            LatLng(place.coordenadas!.longitud, place.coordenadas!.latitud));
      }
      print(places.length);
      print(myMarkers.length);
      if (mounted) {
        _mapController.toScreenLocationBatch(myMarkers).then((value) {
          for (int i = 0; i < myMarkers.length; i++) {
            var point =
                Point<double>(value[i].x as double, value[i].y as double);
            _addMarker(point, myMarkers[i], places[i], i + 1);
          }
        });
      }
    }
    setState(() {});
  }

  initPlaceMarkers() {
    List<LatLng> myMarkers = <LatLng>[];
    _markers = [];
    _markerStates = [];
    myMarkers
        .add(LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!));

    for (PlaceModel place in places) {
      myMarkers
          .add(LatLng(place.coordenadas!.longitud, place.coordenadas!.latitud));
    }
    if (mounted) {
      _mapController.toScreenLocationBatch(myMarkers).then((value) {
        for (int i = 0; i < myMarkers.length; i++) {
          var point = Point<double>(value[i].x as double, value[i].y as double);
          _addMarker(point, myMarkers[i], i == 0 ? null : places[i - 1], i);
        }
      });
    }
  }

  AppBar selectedModeAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      title: Text('${selectedPlaces.length} lugares seleccionados'),
      actions: [
        IconButton(
            onPressed: () {
              isSelectedMode = false;
              selectedPlaces = [];
              for (int i = 0; i < _markers.length; i++) {
                _markerStates[i].setIsSelected(false);
                _markerStates[i].updateSelectMode(false);
              }
              setState(() {});
            },
            icon: const Icon(FontAwesomeIcons.xmark))
      ],
    );
  }

  AppBar defaultModeAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    var aux = MediaQuery.of(context).size.height * 0.8;
    double km = context.watch<KmAroundProvider>().km_around;

    if (km != kmAround) {
      _placeRepository.getAllPlaces().then((value) {
        places = value;
        print(places);

        allPlaces = value;
        initPlaceMarkers();
        kmAround =
            Provider.of<KmAroundProvider>(context, listen: false).km_around;
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: isSelectedMode ? selectedModeAppBar() : defaultModeAppBar(),
      floatingActionButton: _getFAB(),
      endDrawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 80,
              color: Colors.blue[400],
              padding: const EdgeInsets.all(15.0),
              child: const ListTile(
                title: Center(
                  child: Text(
                    'Ranking de lugares',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: builRanking(places)),
          ],
        ),
      ),
      body: Stack(children: [
        MapboxMap(
          accessToken:
              "pk.eyJ1IjoianVhbmtsbDIyOTQiLCJhIjoiY2xkamxpc2lvMHpoeDNwbGxsNnJ0d2QxcSJ9.HBz6_Ry_0l5CPyOmyKfZqw",
          trackCameraPosition: true,
          onMapCreated: _onMapCreated,
          //onMapLongClick: _onMapLongClickCallback,
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
            ignoring: false,
            child: Stack(
              children: _markers,
            )),
        Positioned(
            left: 0,
            right: 0,
            bottom: 50,
            height: isPlaceSelected && isSelectedMode == false
                ? MediaQuery.of(context).size.height * 0.25
                : 0,
            child: PageView.builder(
                scrollBehavior: CupertinoScrollBehavior(),
                controller: _pageController,
                itemCount: places.length,
                itemBuilder: (context, index) {
                  final item = places[index];

                  return MapPlaceDetails(
                    offline: true,
                    recurso: item,
                    index: index,
                    currentLocation: latLng.LatLng(
                        _currentLocation == null
                            ? -2.899729
                            : _currentLocation!.latitude!,
                        _currentLocation == null
                            ? -78.999242
                            : _currentLocation!.longitude!),
                  );
                })),
        /*IgnorePointer(
              child: MyLocationMarker(_animationController),
            )*/
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).size.height * 0.76,
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(height: 80, child: _CrearBotonesCabecera())),
        )
      ]),
    );
  }

  Widget builRanking(List<PlaceModel> places) => ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return Card(
              child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: ListTile(
              leading: SizedBox(
                width: 80,
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: FadeInImage(
                    placeholder: const AssetImage('assets/jar-loading.gif'),
                    image: NetworkImage(place.imagenesPaths![0]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text((place.nombre).toString()),
              // ignore: prefer_interpolation_to_compose_strings
              subtitle: place.rate! > 5
                  ? Text(
                      'Categoria: ${place.categoria}\nPuntuacion: sin puntuar')
                  : Text(
                      'Categoria: ${place.categoria}\nPuntuacion: ${place.rate}'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/onePlace',
                  arguments: {'place': place, 'index': index},
                ).then((value) {
                  setState(() {});
                });
              },
            ),
          ));
        },
      );
}

class Marker extends StatefulWidget {
  final Point _initialPosition;
  final AnimationController _animationController;
  LatLng _coordinate;
  final void Function(_MarkerState) _addMarkerState;
  final PlaceModel _place;
  final _myFunction;
  final _setToSelectedPlaces;
  final int _index;
  final _selectedPlaces;
  final setSelectMode;

  Marker(
      String key,
      this._coordinate,
      this._initialPosition,
      this._addMarkerState,
      this._place,
      this._animationController,
      this._index,
      this._myFunction,
      this._setToSelectedPlaces,
      this._selectedPlaces,
      this.setSelectMode)
      : super(key: Key(key));

  void setNewCoordinates(LatLng newLocation) {
    _coordinate = newLocation;
  }

  @override
  State<StatefulWidget> createState() {
    final state = _MarkerState(
        _initialPosition,
        _place,
        _animationController,
        _index,
        _myFunction,
        _setToSelectedPlaces,
        _selectedPlaces,
        setSelectMode);
    _addMarkerState(state);
    return state;
  }
}

class _MarkerState extends State {
  final _iconSize = 20.0;
  AnimationController _animationController;
  Point _position;
  PlaceModel _place;
  int _index;
  var _myFunction;
  var _toSelectedList;
  List<PlaceModel> _selectedPlaces;
  bool _isSelected = false;
  bool _isSelectedMode = false;
  var setSelectMode;

  _MarkerState(
      this._position,
      this._place,
      this._animationController,
      this._index,
      this._myFunction,
      this._toSelectedList,
      this._selectedPlaces,
      this.setSelectMode);

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

    if (_place.id == null) {
      return Positioned(
          left: _position.x / ratio,
          top: _position.y / ratio,
          child: FractionalTranslation(
              translation: Offset(-0.5, -0.5),
              child: MyLocationMarker(_animationController)));
    } else {
      return Positioned(
          left: _position.x / ratio - _iconSize / 2,
          top: _position.y / ratio - _iconSize / 2,
          child: GestureDetector(
            onLongPress: () {
              if (_isSelectedMode == false) {
                setSelectMode();
              }
              _toSelectedList(_place, _index);

              HapticFeedback.mediumImpact();
              print("longs presss");
            },
            onTap: () {
              _isSelectedMode
                  ? _toSelectedList(_place, _index)
                  : _myFunction(_index);
            },
            child: Container(
              color: Colors.transparent,
              child: ClipRect(
                clipBehavior: Clip.hardEdge,
                child: Stack(children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      top: 0,
                    ),
                    child: Column(
                      children: [
                        Container(
                            height: 40,
                            width: 32,
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(50)),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: FutureBuilder<bool>(
                                  future: ConnectivityUtils.hasConnection(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container(
                                        color: Colors.white,
                                      );
                                    } else if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.data!) {
                                        return Image.network(
                                            _place.imagenesPaths![0],
                                            fit: BoxFit.cover);
                                      } else {
                                        return Image.file(
                                          File(_place.localImages![0]),
                                          fit: BoxFit.cover,
                                        );
                                      }
                                    } else {
                                      return Image.asset(
                                          "assets/imageNotFound.jpg");
                                    }
                                  },
                                ) /*Image.asset(
                                "assets/imageNotFound.jpg",
                                fit: BoxFit.cover,
                              )*/

                                ))
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    child: Center(
                      child: Image(
                        image: _isSelected
                            ? AssetImage("assets/place_selected.png")
                            : AssetImage("assets/place.png"),
                      ),
                    ),
                  )
                ]),
              ),
            ),
          ));
    }
  }

  void updatePosition(Point<num> point) {
    setState(() {
      _position = point;
    });
  }

  void updateSelectedPlaces(List<PlaceModel> placesSelected) {
    _selectedPlaces = placesSelected;
  }

  void updateSelectMode(bool newStatus) {
    _isSelectedMode = newStatus;
  }

  void setIsSelected(bool newStatus) {
    setState(() {
      _isSelected = newStatus;
    });
  }

  LatLng getCoordinate() {
    return (widget as Marker)._coordinate;
  }
}
