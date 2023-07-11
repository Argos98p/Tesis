import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turismup/src/model/place_model.dart';
import 'package:turismup/src/model/post_new_comment_model.dart';
import 'package:turismup/src/repository/place_api_repository.dart';
import 'package:turismup/src/repository/place_repository.dart';
import 'package:http/http.dart' as http;
import '../api/AppApi.dart';
import '../model/offline_enqueue_item_model.dart';
import '../model/post_new_place_model.dart';
import '../model/user_data.dart';
import '../service/connectivity_utils.dart';

class SembastPlaceRepository extends PlaceRepository {
  final Database _database = GetIt.I.get();
  final Dio _dio = Dio();
  final StoreRef _store = intMapStoreFactory.store("offline_db");

  @override
  Future<bool> getSavedPlaces() async {
    var record = _store.record(100);
    var aux =  await record.get(_database);
    if(aux== null ){
      return false;
    }
    aux as List;
    if(aux.isEmpty ){
      return false;
    }
    return true;
  }

  @override
  Future<List<PlaceModel>> getAllPlaces() async {
    if (await ConnectivityUtils.hasConnection() == false) {
      var record = _store.record(100);
      var readMap = await record.get(_database);

      if (readMap == null) {
        await _store.record(100).put(_database, []);
        readMap = await record.get(_database);
      }
      readMap as List;
      List<PlaceModel> listaLugares = [];
      for (int i = 0; i < readMap.length; i++) {
        listaLugares.add(PlaceModel.fromJson(readMap[i]));
      }


      return listaLugares;
    } else {
      List<PlaceModel> places = [];
      try {
        UserData userInfo= await ApiPlaceRepository.getInjfoUsuario();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String kmAround="100";
        if (prefs.containsKey('km_around')) {
          kmAround = prefs.getDouble('km_around')!.round().toString();
        }
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        String myUrlPetition =  "${MyApi.getRecursos(userId: userInfo.id)}&distancia=$kmAround&longitud=${position.longitude}&latitud=${position.latitude}";
        Response response =
        await _dio.get(myUrlPetition);
        response.data
            .forEach((var place) => places.add(PlaceModel.fromJson(place)));
        return places;
      } catch (error, stacktrace) {
        print("Exception occured: $error stackTrace: $stacktrace");
        return places;
      }
    }
  }

  @override
  Future<int> insertPlace(PostNewPlaceModel newPlace) async {
    Map<String, String> modelo = <String, String>{
      'usuarioId': newPlace.userId ?? "",
      'latitud': newPlace.coordenadas!.latitud.toString() ?? "",
      'longitud': newPlace.coordenadas!.longitud.toString(),
      'descripcion': newPlace.descripcion!,
      'nombre': newPlace.nombre!,
    };
    String model = json.encode(modelo);
    var request = http.MultipartRequest('POST', Uri.parse(MyApi.nuevoLugar));
    request.headers.addAll({"Content-Type": "multipart/form-data"});
    request.fields['recurso'] = model;
    for (int i = 0; i < newPlace.imagesPaths!.length; i++) {
      request.files.add(
          await http.MultipartFile.fromPath('files', newPlace.imagesPaths![i]));
    }
    var response = await request.send();
    final respStr = await response.stream.bytesToString();

    print(response.statusCode);
    print(respStr);
    return response.statusCode;
  }

  @override
  Future saveAllPlaces(List<PlaceModel> places) async {
    print(places.length);
    List lugares = [];
    for (PlaceModel place in places) {
      //await _store.add(_database, place.toJson());
      lugares.add(place.toJson());
    }

    await _store.record(100).put(_database, lugares);
    return true;
  }

  @override
  Future deleteAllPlaces() async {
     _store.record(100).put(_database, []);
    //await _store.delete(_database);
  }

  @override
  offlineChangeStatus(int index, OfflineEnqueueItemModel item, String s) async {
    // TODO: implement changeStatus
    var readEnqueue = await offlineGetByFilters("");

    List copyEnqueue = [];
    for (int i = 0; i < readEnqueue.length; i++) {
      copyEnqueue.add(readEnqueue[i].toJson());
    }
    copyEnqueue.removeAt(index);
    item.status = s;
    copyEnqueue.insert(index, item.toJson());
    await _store.record(200).put(_database, copyEnqueue);
  }

  @override
  Future<List<OfflineEnqueueItemModel>> offlineGetByFilters(
      String status) async {
    // TODO: implement getByFilters
    //ESta regresando todos para poder tener el index al momento de actualizar

    List<OfflineEnqueueItemModel> pending = [];
    var record = _store.record(200);
    var readEnqueue = await record.get(_database);
    if (readEnqueue == null) {
      await _store.record(200).put(_database, []);
      readEnqueue = await record.get(_database);
    }
    readEnqueue as List;

    for (int i = 0; i < readEnqueue.length; i++) {
      OfflineEnqueueItemModel item =
          OfflineEnqueueItemModel.formJson(readEnqueue[i]);
      pending.add(item);
      /*if(item.status==status){
        pending.add(item);
      }*/
    }
    return pending;
  }

  @override
  Future<int> offlineInsert(OfflineEnqueueItemModel model) async {


    try {
      var record = _store.record(200);

      var readEnqueue = await record.get(_database);
      if (readEnqueue == null) {
        await _store.record(200).put(_database, []);
        readEnqueue = await record.get(_database);
      }
      readEnqueue as List;

      List newRecord = [];
      for (int i = 0; i < readEnqueue.length; i++) {
        newRecord.add(readEnqueue[i]);
      }
      newRecord.add(model.toJson());
      await _store.record(200).put(_database, newRecord);
      return 200;
    } on Exception catch (e) {
      return 500;
    }
  }

  @override
  Future<int> insertComment(PostNewCommentModel newComment) async {
    Map<String, String> modelo = <String, String>{
      'lugarId': newComment.lugarId!,
      'userId': newComment.userId!,
      'comentario': newComment.comentario!,
      'puntaje': newComment.puntaje.toString(),
    };
    String model = json.encode(modelo);
    var request =
        http.MultipartRequest('POST', Uri.parse(MyApi.nuevoComentario));
    request.headers.addAll({"Content-Type": "multipart/form-data"});
    request.fields['comentario'] = model;
    for (int i = 0; i < newComment.imagenes!.length; i++) {
      request.files.add(
          await http.MultipartFile.fromPath('files', newComment.imagenes![i]));
    }
    var response = await request.send();
    print(response.statusCode);
    final respStr = await response.stream.bytesToString();
    print(respStr);
    if (response.statusCode == 200) {
      print('Uploaded!');
    }
    return response.statusCode;
  }
}
