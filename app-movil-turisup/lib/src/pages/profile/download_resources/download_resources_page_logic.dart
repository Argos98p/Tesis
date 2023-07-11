import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

import '../../../model/place_model.dart';
import '../../../repository/place_api_repository.dart';
import '../../../repository/place_repository.dart';

class DownloadResourcesPageManager{
  final progressNotifier = ValueNotifier<double?>(0);
  var placesStateNotifier = ValueNotifier<PlacesOfflineState>(PlacesOfflineState.checking);
  final PlaceRepository _placeRepositoryRepository = GetIt.I.get();
  final ApiPlaceRepository _placeApiRepository = ApiPlaceRepository();

  void check(){

    placesStateNotifier.value = PlacesOfflineState.checking;

    _placeRepositoryRepository.getSavedPlaces().then((value) {

      if(value){
        placesStateNotifier.value = PlacesOfflineState.saved;
      }else{
        placesStateNotifier.value = PlacesOfflineState.notSaved;
      }
    });

  }

  void download(){
    progressNotifier.value=null;
    placesStateNotifier.value=PlacesOfflineState.downloading;
    _placeApiRepository.getAllPlaces().then((places) async {

      progressNotifier.value=0.0;
      for(PlaceModel place in places){
        place.localImages=[];
      }
      int i = 0;
      for(PlaceModel place in places ){

        String pathImage = await saveImage(place);
        print(pathImage);
        place.localImages!.add(pathImage);
        progressNotifier.value=i/(places.length-1);
        i++;



      }
      _placeRepositoryRepository.saveAllPlaces(places).then((value) {
        placesStateNotifier.value=PlacesOfflineState.saved;
      });

    });


  }

  void deleteSavedPlaces(){
    placesStateNotifier.value=PlacesOfflineState.checking;
     _placeRepositoryRepository.deleteAllPlaces().then((value) {
       placesStateNotifier.value=PlacesOfflineState.notSaved;

     });
     Fluttertoast.showToast(msg: 'Recursos borrados');
  }


  Future<String> saveImage(PlaceModel recurso)async {
    final dir = recurso.imagenesPaths![0];
    var url = Uri.parse(dir);

    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = "${documentDirectory.path}/images";
    var filePathAndName = '${documentDirectory.path}/images/${recurso.id!}.jpg';
    var response = await get(url);
    await Directory(firstPath).create(recursive: true); // <-- 1
    File file2 = File(filePathAndName);             // <-- 2
    file2.writeAsBytesSync(response.bodyBytes);
    return filePathAndName;

  }


}


enum PlacesOfflineState {
  checking,
  downloading,
  saved,
  notSaved,
}