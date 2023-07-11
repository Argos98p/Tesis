import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readmore/readmore.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:turismup/src/pages/map/route_map.dart';
import 'package:turismup/src/service/connectivity_utils.dart';
import '../../model/place_model.dart';
import '../../utils/AppColor.dart';

class MapPlaceDetails extends StatelessWidget {
  const MapPlaceDetails({Key? key,required bool this.offline, required this.index, required PlaceModel this.recurso, required this.currentLocation})
      : super(key: key);
  final PlaceModel recurso;
  final bool offline;
  final int index;
  final latLng.LatLng currentLocation;


  @override
  Widget build(BuildContext context) {

    return FutureBuilder<bool>(
      future: ConnectivityUtils.hasConnection(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3), BlendMode.srcOver),
                    image: !snapshot.data!  ? FileImage(File(recurso.localImages![0])) as ImageProvider: NetworkImage(recurso.imagenesPaths![0]),
                    fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    recurso.nombre ?? "",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),

                  ReadMoreText(recurso.descripcion!,
                      trimLength: 150,
                      trimCollapsedText: '',
                      trimExpandedText: 'Leer menos',
                      style:
                      const TextStyle(fontSize: 14.0, color: Colors.white)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {

                          if(snapshot.data!) {
                            //tiene internet
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) =>
                                MapRoute(
                                  origen: currentLocation,
                                  destino: latLng.LatLng(
                                    recurso.coordenadas!.longitud,
                                    recurso.coordenadas!.latitud,),
                                  recurso: recurso,)

                            ));
                          }else{
                            Fluttertoast.showToast(msg: "No disponible en offline");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryColorOpacity,
                            shadowColor: Colors.transparent,
                            shape: StadiumBorder()),
                        child: const Text("Buscar ruta",style: TextStyle(color: AppColor.primaryColor),),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/onePlace',
                              arguments: {'place': recurso, 'index':index},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3062C9),
                              shadowColor: Colors.transparent,
                              shape: StadiumBorder()),
                          child: const Text("Ver Lugar"))
                    ],
                  )
                ],
              ),
            ),
          );

        }else{
          return const  CircularProgressIndicator();
        }
      }
    );
  }
}
