import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as mapBox;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart' ;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:location/location.dart';
import 'package:turismup/src/model/place_model.dart';
import 'package:turismup/src/utils/AppColor.dart';

import '../../controller/image_to_bytes.dart';
import '../../utils/map_style.dart';

class MapRoute extends StatefulWidget {
  const MapRoute({Key? key, required this.origen, required this.destino, required this.recurso }) : super(key: key);
  final latLng.LatLng origen;
  final latLng.LatLng destino;
  final PlaceModel recurso;

  @override
  State<MapRoute> createState() => _MapRouteState();
}

class _MapRouteState extends State<MapRoute> {
  var MAPPBOX_ACCESS_TOKEN =
      "pk.eyJ1IjoicmljazYxOSIsImEiOiJjbGVxZ3pmYm0wbWp4M3NwbmJiNml6NHo4In0.UyW8_r0R5w9QpcwNP8sfbQ";
  var MAPBOX_STYLE = "mapbox/streets-v12";
  CameraPosition? _initialLocation ;
  late GoogleMapController mapController;
  LocationData? _currentLocation;
  late PolylinePoints polylinePoints;
  int _travelModeSelected = 0;
  Map<TravelMode,List<LatLng>> myRoutes = {};
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  Set<Marker> markers = {};



  @override
  void initState() {
    getCurrentLocation();
    _initialLocation=CameraPosition(tilt:90.0 ,zoom:16.5,target: LatLng(widget.origen.latitude,widget.origen.longitude));
    searchRoute();
    super.initState();

  }


  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
          (location) {
        _currentLocation = location;
      },
    );
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
        if(!mounted)return;

        setState(() {});
      },
    );
  }


  Future<void> searchRoute() async {
    polylinePoints = PolylinePoints();
    int i=0;
    List<TravelMode>  travelmodes= [TravelMode.driving,TravelMode.walking,TravelMode.bicycling];
    for(TravelMode travelMode in travelmodes){
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyD9m7bZ0SieFUTH7PdJakPdV2cZwIkbXFo", // Google Maps API Key
        PointLatLng(widget.origen.latitude, widget.origen.longitude),
        PointLatLng(widget.destino.latitude, widget.destino.longitude),
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
      markers.add(Marker(
        markerId: MarkerId("origen"),
        position: LatLng(widget.origen.latitude, widget.origen.longitude,),
        infoWindow: InfoWindow(
          title: 'origen',
          //snippet: _startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
      markers.add(Marker(
        markerId: MarkerId("destino"),
        position: LatLng(widget.destino.latitude,widget.destino.longitude,),
        infoWindow: InfoWindow(
          title: 'destino',
          //snippet: _startAddress,
        ),
        icon: await imageToBytes(widget.recurso.imagenesPaths![0]),
      ));

      myRoutes[travelMode]=aux;

      i++;
    }
    if(mounted){
      setState(() {

      });
    }

  }

  Set<Polyline> _getPolyline(int routeSelected){
    List<LatLng> polylineCoordinates = [];
    if(routeSelected==0){
      polylineCoordinates= myRoutes[TravelMode.driving] ?? [];

    }else if(routeSelected==1){
      polylineCoordinates= myRoutes[TravelMode.walking] ?? [];
    }else if(routeSelected==2){
      polylineCoordinates= myRoutes[TravelMode.bicycling] ?? [];
    }else{
      polylineCoordinates= [];
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
         /*FlutterMap(
              options: MapOptions(
                rotation: 5.0,
                center: _myLocation,
                zoom: 13.0,
                minZoom: 5,

              ),
              nonRotatedChildren: [
                TileLayer(
                  urlTemplate:
                      "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}",
                  additionalOptions: {
                    "accessToken": MAPPBOX_ACCESS_TOKEN,
                    "id": MAPBOX_STYLE
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                        point: widget.origen,
                        builder: (_){
                          return Container(
                            color: Colors.red,
                          );
                        }),
                    Marker(
                        point: widget.destino,
                        builder: (_){
                          return Container(
                            color: Colors.red,
                          );
                        })
                  ],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      color: AppColor.primaryColor,
                        strokeWidth: 5,
                        points: _myPointRoute
                    )
                  ],
                )
              ])*/
        ],
      ),
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
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600),
          unSelectedTextStyle: const TextStyle(
              color: AppColor.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w400),
          labels: ["","",""],
          icons: const [FontAwesomeIcons.car,FontAwesomeIcons.personWalking,FontAwesomeIcons.bicycle],
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
}
