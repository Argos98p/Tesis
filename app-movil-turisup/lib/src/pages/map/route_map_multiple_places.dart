import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:turismup/src/pages/new_route.dart';

import '../../controller/image_to_bytes.dart';
import '../../model/place_model.dart';
import '../../utils/AppColor.dart';
import '../../utils/map_style.dart';

class RouteMapMultiplePlaces extends StatefulWidget {
  const RouteMapMultiplePlaces({Key? key, required this.recursos})
      : super(key: key);

  final List<PlaceModel> recursos;
  @override
  State<RouteMapMultiplePlaces> createState() => _RouteMapMultiplePlacesState();
}

class _RouteMapMultiplePlacesState extends State<RouteMapMultiplePlaces> {
  CameraPosition? _initialLocation;
  late GoogleMapController mapController;
  LocationData? _currentLocation;
  late PolylinePoints polylinePoints;
  int _travelModeSelected = 0;
  Map<TravelMode, List<LatLng>> myRoutes = {};
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  late List<PlaceModel> recursosCopiaBottomPage;
  late List<PlaceModel> recursosCopia;
  Set<Marker> markers = {};

  @override
  void initState() {
    _initialLocation =
    const CameraPosition(tilt: 90.0, zoom: 14.5, target: LatLng(-2.901405, -78.997847));
    getCurrentLocation();
    recursosCopia = widget.recursos;
    recursosCopiaBottomPage = widget.recursos;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    mapController.dispose();
    super.dispose();
  }

  Future<void> searchRoute(
      LocationData location, List<PlaceModel> recursos) async {
    polylinePoints = PolylinePoints();
    List<TravelMode> travelmodes = [
      TravelMode.driving,
      TravelMode.walking,
      TravelMode.bicycling
    ];

    for (TravelMode travelMode in travelmodes) {
      myRoutes[travelMode] = [];
      for (int j = -1; j < recursos.length - 1; j++) {
        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          "AIzaSyD9m7bZ0SieFUTH7PdJakPdV2cZwIkbXFo", // Google Maps API Key
          j == -1
              ? PointLatLng(location.latitude!, location.longitude!)
              : PointLatLng(recursos[j].coordenadas!.longitud,
              recursos[j].coordenadas!.latitud),
          PointLatLng(recursos[j + 1].coordenadas!.longitud,
              recursos[j + 1].coordenadas!.latitud),
          travelMode: travelMode,
        );
        List<LatLng> aux = [];
        if (result.points.isNotEmpty) {
          result.points.forEach((PointLatLng point) {
            //polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            /*_myPointRoute.add(latLng.LatLng(point.latitude, point.longitude));*/
            aux.add(LatLng(point.latitude, point.longitude));
          });
        }
        myRoutes[travelMode] = List.from(myRoutes[travelMode]!)..addAll(aux);
      }
    }
    for (PlaceModel recurso in recursos) {
      markers.add(Marker(
        markerId: MarkerId(recurso.id ?? ""),
        position:
        LatLng(recurso.coordenadas!.longitud, recurso.coordenadas!.latitud),
        infoWindow: InfoWindow(
          title: '${recurso.nombre}',
          //snippet: _startAddress,
        ),
        icon: await imageToBytes(recurso.imagenesPaths![0]),
      ));
    }
    markers.add(Marker(
      markerId: MarkerId("origen"),
      position: LatLng(location.latitude!, location.longitude!),
      infoWindow: InfoWindow(
        title: 'origen',
        //snippet: _startAddress,
      ),
      icon: BitmapDescriptor.defaultMarker,
    ));
    recursosCopia = recursosCopiaBottomPage;
    if (mounted) {
      setState(() {});
    }
  }

  Set<Polyline> _getPolyline(int routeSelected) {
    List<LatLng> polylineCoordinates = [];
    if (routeSelected == 0) {
      polylineCoordinates = myRoutes[TravelMode.driving] ?? [];
    } else if (routeSelected == 1) {
      polylineCoordinates = myRoutes[TravelMode.walking] ?? [];
    } else if (routeSelected == 2) {
      polylineCoordinates = myRoutes[TravelMode.bicycling] ?? [];
    } else {
      polylineCoordinates = [];
    }
    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: AppColor.primaryColor,
      points: polylineCoordinates,
      width: 5,
    );
    Map<PolylineId, Polyline> polylines = {};
    polylines[id] = polyline;
    return Set<Polyline>.of(polylines.values);
  }

  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
          (location) {
        _currentLocation = location;
        searchRoute(location, widget.recursos);

        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              tilt: 90.0,
              target: LatLng(location.latitude!, location.longitude!),
              zoom: 18.0,
            ),
          ),
        );
      },
    );
    if (!mounted) return;

    setState(() {});
    location.onLocationChanged.listen(
          (newLoc) {
        _currentLocation = newLoc;
        //Descomentar para que la camara siga al usuario
        /*
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              tilt: 90.0,
              target: LatLng(newLoc.latitude!,newLoc.longitude!),
              zoom: 18.0,
            ),
          ),
        );*/
        if (!mounted) return;

        setState(() {});
      },
    );
  }

  Widget RoutesAvaliables() {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 103),
        child: FlutterToggleTab(
          unSelectedBackgroundColors: [AppColor.dividerColor],
          selectedBackgroundColors: [AppColor.primaryColor],
          width: 50,
          borderRadius: 15,
          selectedTextStyle: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          unSelectedTextStyle: const TextStyle(
              color: AppColor.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w400),
          labels: ["", "", ""],
          icons: const [
            FontAwesomeIcons.car,
            FontAwesomeIcons.personWalking,
            FontAwesomeIcons.bicycle
          ],
          selectedIndex: _travelModeSelected,
          selectedLabelIndex: (index) {
            setState(() {
              _travelModeSelected = index;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: _initialLocation!,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                controller.setMapStyle(mapStyle);
              },
              polylines: _getPolyline(_travelModeSelected),
              markers: Set<Marker>.from(markers),

              // ...
            ),
            RoutesAvaliables(),
            SizedBox.expand(
              child: DraggableScrollableSheet(
                initialChildSize: 0.08,
                minChildSize: 0.08,
                builder: (BuildContext context, ScrollController scrollController) {
                  return Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          child: Column(
                            children: [
                              Container(
                                height: 5,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Ordenar recursos",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              ReorderableListView(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                scrollController: scrollController,
                                onReorder: reorderData,
                                children: <Widget>[
                                  for (final recurso in recursosCopiaBottomPage)
                                    Container(
                                      height: 80,
                                      width: 80,
                                      key: ValueKey(recurso),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        color: AppColor.primaryColorOpacity,
                                        child: SizedBox(
                                          height: 80,
                                          width: 80,
                                          child: ListTile(
                                            dense: false,
                                            title: Text(recurso.nombre ?? ""),
                                            leading: AspectRatio(
                                              aspectRatio: 1,
                                              child: ClipRRect(
                                                borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(4.0)),
                                                child: Image.network(
                                                  recurso.imagenesPaths![0],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            trailing: Icon(
                                              FontAwesomeIcons.sort,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  searchRoute(
                                      _currentLocation!, recursosCopiaBottomPage);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.primaryColor,
                                    shadowColor: Colors.transparent,
                                    shape: StadiumBorder()),
                                child: const Text('Volver a generar la ruta'),
                              ),

                            ],
                          ),
                        ),
                      ));
                },
              ),
            ),
            Positioned(
                right: 20,
                top: 50,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColor.primaryColorOpacity, //<-- SEE HERE
                  child: IconButton(
                    color: AppColor.primaryColor,
                    icon: Icon(FontAwesomeIcons.floppyDisk),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewRoute(recursos: recursosCopiaBottomPage)),
                      );
                    },
                  ),
                )
            )
          ],
        ));
  }

  void reorderData(int oldindex, int newindex) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final items = widget.recursos.removeAt(oldindex);
      widget.recursos.insert(newindex, items);
    });
  }
}
