import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart' ;
import 'package:latlong2/latlong.dart' as latLng;
import 'package:location/location.dart';
import 'package:readmore/readmore.dart';
import 'package:turismup/src/pages/map/route_map.dart';
import 'package:turismup/src/pages/map/route_map_multiple_places.dart';
import 'package:turismup/src/utils/AppColor.dart';
import 'package:turismup/src/widgets/load_screen.dart';

import '../../model/place_model.dart';
import '../../repository/place_api_repository.dart';
import '../../service/api_provider.dart';
import 'map_place_details.dart';
import 'my_location_marker.dart';

class MapBoxMainMap extends StatefulWidget {
  const MapBoxMainMap({Key? key}) : super(key: key);

  @override
  State<MapBoxMainMap> createState() => _MapBoxMainMapState();
}

class _MapBoxMainMapState extends State<MapBoxMainMap> with SingleTickerProviderStateMixin,  AutomaticKeepAliveClientMixin{
  late final AnimationController _animationController;
  final ApiPlaceRepository _placeRepository = ApiPlaceRepository();
  LocationData? _currentLocation ;
  final _pageController = PageController();
  var MAPPBOX_ACCESS_TOKEN =
      "pk.eyJ1IjoicmljazYxOSIsImEiOiJjbGVxZ3pmYm0wbWp4M3NwbmJiNml6NHo4In0.UyW8_r0R5w9QpcwNP8sfbQ";
  var _myLocation = latLng.LatLng(-2.902882, -79.018638);
  var MAPBOX_STYLE = "mapbox/streets-v12";
  var MARKER_COLOR = Color(0xFF3DC5A7);
  var MARKER_SIZE_SELECTED = 85.0;
  var MARKER_SIZE_DEFAULT = 70.0;
  var MARKER_IMAGE_SELECTED = 55.0;
  var MARKER_IMAGE_DEFAULT = 47.0;
  Future<List<PlaceModel>>? placesFuture;
  bool _isSelected = false;
  int? selectedIndex;
  bool _isMultiselectMode=false;
  List<PlaceModel> selectedPlaces = [];



  @override
  void initState() {
    placesFuture = getPlaces();
    getCurrentLocation();
    _animationController = AnimationController(vsync: this,duration: const Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    super.initState();

  }
  @override
  void dispose(){
    _animationController.dispose();
    super.dispose();
  }

  Widget _getFAB(){
    if(_isMultiselectMode){
      return FloatingActionButton.extended(
        backgroundColor: AppColor.primaryColorOpacity,
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => RouteMapMultiplePlaces(
            recursos: selectedPlaces,
            )));
        }, label: Text("Buscar ruta", style: TextStyle(color: AppColor.primaryColor),),
      );
    }else{
      return SizedBox();

    }
  }

  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
          (location) {
        _currentLocation = location;
        setState(() {

        });
      },
    );
    location.onLocationChanged.listen(
          (newLoc) {
        _currentLocation = newLoc;
        if(mounted){
          setState(() {});
        }

      },
    );
  }

    Future<List<PlaceModel>> getPlaces() async {
      List<PlaceModel> places = await _placeRepository.getAllPlaces();
      return places;
  }

  AppBar selectedModeAppBar (){
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      title: Text('${selectedPlaces.length} lugares seleccionados'),
      actions: [
        IconButton(onPressed: (){
          _isMultiselectMode= false;
          selectedPlaces = [];
          setState(() {

          });
        }, icon: const Icon(FontAwesomeIcons.xmark))
      ],
    );
  }
  AppBar defaultModeAppBar (){
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: _isMultiselectMode ? selectedModeAppBar() : defaultModeAppBar() ,
      floatingActionButton: _getFAB(),
      body: FutureBuilder<List<PlaceModel>>(
        future: placesFuture,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<PlaceModel>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadScreen("Cargando...");
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Text('Error');
            } else if (snapshot.hasData) {
              List<PlaceModel> recursos = snapshot.data!;
              return Stack(
                children: [
                  mapa(recursos),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 50,
                    height: _isSelected
                        ? MediaQuery.of(context).size.height * 0.25
                        : 0,
                    child: PageView.builder(
                        controller: _pageController,
                        itemCount: recursos.length,
                        itemBuilder: (context, index) {
                          final item = recursos[index];

                          return MapPlaceDetails(offline:false,index:index , recurso: item, currentLocation: latLng.LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),);
                        }),
                  )
                ],
              );
            } else {
              return const Text('Empty data');
            }
          } else {
            return Text('State: ${snapshot.connectionState}');
          }
        },
      ),
    );
  }

  Widget mapa(List<PlaceModel> recursos) {
    return FlutterMap(
      options: MapOptions(

        onPositionChanged: (aux1, aux2) {
          setState(() {
            _isSelected = false;
            selectedIndex=null;
          });
        },
        onTap: (aux, aux2) {
          _isSelected = false;
          selectedIndex=null;
          setState(() {});
        },
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
            for (int i = 0; i < recursos.length; i++)
              Marker(
                  width: 80,
                  height:80,
                  point: latLng.LatLng(recursos[i].coordenadas!.longitud,
                      recursos[i].coordenadas!.latitud),
                  builder: (_) {
                    return itemMap(
                      recursos[i],
                      i,
                    );
                  })
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              height: MediaQuery.of(context).size.width*0.7,
                width: MediaQuery.of(context).size.width*0.7,
                point: _currentLocation != null ? latLng.LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!) : _myLocation,
                builder: (_) {
                  return MyLocationMarker(_animationController);
                })
          ],
        )
      ],
    );
  }

  Widget itemMap(PlaceModel recurso, int i) {
    return GestureDetector(
      onLongPress:(){
        _isSelected =false;
        _isMultiselectMode=true;
        selectedPlaces.add(recurso);
        setState(() {

        });
        Fluttertoast.showToast(msg: "Seleccione lugares para generar una ruta");
      } ,
      onTap: () {

        if(!_isMultiselectMode){
          _isSelected = true;
          selectedIndex = i;
          setState(() {});
          _pageController.animateToPage(i,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.elasticOut);
        }else{
          if(selectedPlaces.contains(recurso)){
            selectedPlaces.remove(recurso);
          }else{
            selectedPlaces.add(recurso);
          }
          setState(() {

          });

        }

      },
      child: Container(
        color: Colors.transparent,
        child: ClipRect(
          clipBehavior: Clip.hardEdge,
          child: Stack(children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 11,
                top: 2,
              ),
              child: Column(
                children: [
                  AnimatedContainer(
                    
                      height: i==selectedIndex ? MARKER_IMAGE_SELECTED:MARKER_IMAGE_DEFAULT,
                      width: i==selectedIndex ? MARKER_IMAGE_SELECTED:MARKER_IMAGE_DEFAULT,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(50)),
                      duration: const Duration(milliseconds: 400),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: Image.network(
                            recurso.imagenesPaths![0],
                            fit: BoxFit.cover,
                          )))
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width:i==selectedIndex ? MARKER_SIZE_SELECTED:MARKER_SIZE_DEFAULT ,
              height: i==selectedIndex ? MARKER_SIZE_SELECTED:MARKER_SIZE_DEFAULT,
              child:  Center(
                child: Image(
                  image: (selectedPlaces.contains(recurso) && _isMultiselectMode)? AssetImage("assets/place_selected.png") : AssetImage("assets/place.png"),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;


}


