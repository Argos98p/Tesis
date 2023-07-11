import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:turismup/src/model/user_data.dart';
import 'package:turismup/src/repository/place_api_repository.dart';
import 'package:turismup/src/utils/AppColor.dart';
import '../api/AppApi.dart';
import 'package:http/http.dart' as http;

import '../controller/image_to_bytes.dart';
import '../controller/mapController.dart';

class OneRoutePage extends StatefulWidget {
  const OneRoutePage({Key? key}) : super(key: key);

  @override
  State<OneRoutePage> createState() => _OneRoutePageState();
}

class _OneRoutePageState extends State<OneRoutePage> {
  late GoogleMapController googleMapController;
  var lugares;
  final _controller = MapController();
  bool mapView=true;
  Map<MarkerId,Marker> mapMarkers= Map();
  String google_api_key = "AIzaSyD9m7bZ0SieFUTH7PdJakPdV2cZwIkbXFo";
  List<LatLng> polylineCoordinates = [];
  @override
  void initState() {
    // TODO: implement initState
    var lugares= [];


    super.initState();
    _controller.getCurrentLocation();
    //_controller.getPolyPointsRuta(widget.rutas);
    _controller.addListener(() {
      // setState(() {});
    });

    // _controller.cargarMarkers();
    // _controller.posicionActual();
  }

  Future<Object> getRequest(rutaId) async {
    UserData userData = await ApiPlaceRepository.getInjfoUsuario();
    String url = MyApi.getOneRoute(rutaId:rutaId);
    final response = await http.get(Uri.parse(url),headers: {'Content-Type': 'application/json'});
    print(response.statusCode );
    if (response.statusCode == 200) {
      var data=json.decode(utf8.decode(response.bodyBytes));
      print(data);
      lugares=data['lugares'];

      for(var i = 0 ; i < lugares.length; i++){
        print(lugares[i]['nombre']);
        final id = MarkerId((lugares[i]['id']).toString());
        final icon = await imageToBytes(lugares[i]['imagenes'][0]);
        final marker  = Marker(markerId: id,icon: icon,
        onTap: (){

        },
        position: LatLng(lugares[i]['coordenadas']['longitud'],lugares[i]['coordenadas']['latitud'],));
        mapMarkers[id]=marker;
      }
      for(var i=0; i<lugares.length-1; i++){
        double latIni =lugares[i]['coordenadas']['latitud'] ;
        double longIni =lugares[i]['coordenadas']['longitud'];
        double latFin =lugares[i+1]['coordenadas']['latitud'];
        double longFin =lugares[i+1]['coordenadas']['longitud'];

        print(latIni.toString()+"--"+longIni.toString());
        print(latFin.toString()+"--"+longFin.toString());
        PolylinePoints polylinePoints = PolylinePoints();
        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
            google_api_key,
            PointLatLng(latIni, longIni),
            PointLatLng(latFin, longFin));
        print(result.points);
        if (result.points.isNotEmpty) {
          print('object');
          // ignore: avoid_function_literals_in_foreach_calls
          result.points.forEach((PointLatLng point) =>
              polylineCoordinates.add(LatLng(point.latitude, point.longitude)));
        }

        }
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Products');
    }

  }



  @override
  Widget build(BuildContext context) {
    final recursoId = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;

    return Scaffold(
      backgroundColor: Color(0xFFE5E8E8),
      appBar: AppBar(

        shadowColor: Colors.white,
        title:  Text("Mi ruta",style: TextStyle(color: Color(0xFF000000)),),

      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFFFFFFFF),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(onPressed: (){
                  setState(() {
                    mapView=true;
                  });
                }, icon: Icon(Icons.map_outlined),

                color:mapView? Colors.lightBlue:Colors.black),
                IconButton(onPressed: (){
                  setState(() {
                    mapView=false;
                  });
                }, icon: Icon(Icons.grid_view),
                color: !mapView? Colors.lightBlue:Colors.black,),

              ],

            )
             ),
          FutureBuilder(
            future: getRequest(recursoId['exampleArgument']),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }else if(snapshot.connectionState == ConnectionState.done){
                if(snapshot.hasData){
                  if(mapView) {
                    return Expanded(
                      child: Container(
                          child: crearMapa()),
                    );
                  } else {
                    if(snapshot.data['lugares'].length==0){
                      return Text("Ruta sin recursos");
                    }
                    return CardPlace(snapshot.data['lugares']);
                  }
                }else if(snapshot.hasError){
                  return Text("error en al peticion");
                }
              }
              print(recursoId['exampleArgument']);
              if (snapshot.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              else {

                return Text("Error obteniendo la ruta");

              }
            },

          )
        ],
      ),
    );
  }

  Widget crearMapa() {
    return GoogleMap(
      onMapCreated: (mapController) {
        // _controller.onMapCreated(mapController);
      },

      initialCameraPosition:
      CameraPosition(target: LatLng(-2.899224, -79.010808), zoom: 10),
      markers: Set.of(mapMarkers.values),
      polylines: {
        Polyline(
          polylineId: PolylineId("ruta 5"),
          points: polylineCoordinates,
          color: Colors.blue[400]!,
          width: 10,
        ),
      },

      myLocationEnabled: true,
      // myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      // onTap: _controller.onTap
    );
  }

  Widget CardPlace( places) => GridView.count(
    scrollDirection: Axis.vertical,
    shrinkWrap: true,
    crossAxisCount: 2,
    crossAxisSpacing: 4.0,
    childAspectRatio: 0.68,
    mainAxisSpacing: 4.0,
    children: List.generate(places.length, (index) {
      final place = places[index];
      return GestureDetector(
        onLongPress: (){
          print("soy un long press");

        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    (place['imagenes'][0]),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                (place['nombre']).toString(),
                textAlign: TextAlign.left,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'centro',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Color.fromRGBO(164, 172, 188, 1),
                    fontSize: 12,
                    fontWeight: FontWeight.w100),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '1KM',
                    style: TextStyle(color: Colors.blueAccent),
                  ),

                ],
              )
            ],
          ),
        ),
        onTap: () {
          {
            Navigator.pushNamed(
              context,
              '/onePlaceFetch',
              arguments: {'place': place},
            );
          }
        },
      );
    }),
  );

}
