import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turismup/src/api/AppApi.dart';
import 'package:turismup/src/model/datos_comment.dart';
import 'package:turismup/src/model/place_model.dart';
import 'package:turismup/src/model/post_new_comment_model.dart';
import 'package:turismup/src/model/post_new_place_model.dart';
import 'package:turismup/src/repository/place_repository.dart';
import 'package:turismup/src/service/connectivity_utils.dart';

import '../model/history_model.dart';
import '../model/offline_enqueue_item_model.dart';
import '../model/one_route_model.dart';
import '../model/post_new_route.dart';
import '../model/user_data.dart';
import '../service/offline_enqueue_service.dart';

class ApiPlaceRepository extends PlaceRepository {
  final Dio _dio = Dio();
  var offlineEnqueueService = OfflineEnqueueService();

  Future<int?> createRoute(PostNewRoute newRoute) async {
    try {
      Response response =
          await _dio.post(MyApi.createRuta, data: newRoute.toJson());
      return response.statusCode;
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return 400;
    }
  }

  @override
  Future<List<PlaceModel>> getAllPlaces() async {
    List<PlaceModel> places = [];
    try {
      UserData userInfo = await getInjfoUsuario();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String kmAround = "100";
      if (prefs.containsKey('km_around')) {
        kmAround = prefs.getDouble('km_around')!.round().toString();
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String myUrlPetition =
          "${MyApi.getRecursos(userId: userInfo.id)}&distancia=$kmAround&longitud=${position.longitude}&latitud=${position.latitude}";
      print(myUrlPetition);
      Response response = await _dio.get(myUrlPetition);
      response.data
          .forEach((var place) => places.add(PlaceModel.fromJson(place)));
      return places;
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return places;
    }
  }

  Future<List<PlaceModel>> getPlacesRoute() async {
    List<PlaceModel> places = [];
    try {
      UserData userInfo = await getInjfoUsuario();
      String myUrlPetition = "${MyApi.getRecursos(userId: userInfo.id)}";
      Response response = await _dio.get(myUrlPetition);
      response.data
          .forEach((var place) => places.add(PlaceModel.fromJson(place)));
      return places;
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return places;
    }
  }

  static Future<UserData> getInjfoUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int id = prefs.getInt('userId') ?? -1;
    final String token = prefs.getString('userToken') ?? '';
    final String email = prefs.getString('userEmail') ?? '';
    final String nombre = prefs.getString('userName') ?? '';
    final String img = prefs.getString('userUrlPhoto') ?? '';
    return UserData(
        id: id, token: token, email: email, nombre: nombre, urlPhoto: img);
  }

  @override
  Future<int> insertPlace(PostNewPlaceModel newPlace) async {
    if (await ConnectivityUtils.hasConnection() == false) {
      Fluttertoast.showToast(
          msg: "El recurso se subira cuando tengas conexion");
      var result =
          await offlineEnqueueService.addToQueue(OfflineEnqueueItemModel(
        type: "INSERT_PLACE",
        data: newPlace.toJson(),
        status: "PENDING",
      ));
      print(result);
      return result;
    } else {
      print("entra en el api normal");
      Map<String, String> modelo = <String, String>{
        'usuarioId': newPlace.userId ?? "",
        'latitud': newPlace.coordenadas!.latitud.toString() ?? "",
        'longitud': newPlace.coordenadas!.longitud.toString(),
        'descripcion': newPlace.descripcion!,
        'nombre': newPlace.nombre!,
        'categoria': newPlace.categoria!
      };
      String model = json.encode(modelo);
      var request = http.MultipartRequest('POST', Uri.parse(MyApi.nuevoLugar));
      request.headers.addAll({"Content-Type": "multipart/form-data"});
      request.fields['recurso'] = model;
      for (int i = 0; i < newPlace.imagesPaths!.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
            'files', newPlace.imagesPaths![i]));
      }
      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      print(response.statusCode);
      print(respStr);
      return response.statusCode;
    }
  }

  @override
  Future saveAllPlaces(List<PlaceModel> places) {
    // TODO: implement saveAllPlaces
    throw UnimplementedError();
  }

  Future<List<PlaceModel>> getFavorites(String userId) async {
    UserData userData = await getInjfoUsuario();
    List<PlaceModel> places = [];
    try {
      print(MyApi.getFavoritesUrl(userData.id.toString()));
      Response response =
          await _dio.get(MyApi.getFavoritesUrl(userData.id.toString()));
      response.data
          .forEach((var place) => places.add(PlaceModel.fromJson(place)));

      print(places);
      return places;
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return places;
    }
  }

  @override
  Future deleteAllPlaces() {
    // TODO: implement deleteAllPlaces
    throw UnimplementedError();
  }

  @override
  offlineChangeStatus(int index, OfflineEnqueueItemModel item, String s) {
    // TODO: implement offlineChangeStatus
    throw UnimplementedError();
  }

  @override
  Future<List<OfflineEnqueueItemModel>> offlineGetByFilters(String status) {
    // TODO: implement offlineGetByFilters
    throw UnimplementedError();
  }

  @override
  offlineInsert(OfflineEnqueueItemModel model) {
    // TODO: implement offlineInsert
    print("entra en el api normal");
    throw UnimplementedError();
  }

  @override
  Future<int> insertComment(PostNewCommentModel newComment) async {
    if (await ConnectivityUtils.hasConnection() == false) {
      Fluttertoast.showToast(
          msg: "El comentario se subira cuando tengas conexion");

      var result =
          await offlineEnqueueService.addToQueue(OfflineEnqueueItemModel(
        type: "INSERT_COMMENT",
        data: newComment.toJson(),
        status: "PENDING",
      ));
      print(result);
      return result;
    } else {
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
        request.files.add(await http.MultipartFile.fromPath(
            'files', newComment.imagenes![i]));
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

  Future<Response> addFavorite(String userId, String placeId) async {
    print("----------------------------");
    print(userId);
    print(placeId);
    Response response = await _dio.post(MyApi.insertFavorite,
        data: {"userId": userId, "placeId": placeId});
    print(response.statusCode);
    return response;
  }

  Future<Response> removeFavorite(String userId, String placeId) async {
    Response response = await _dio.post(MyApi.deleteFavorite,
        data: {"userId": userId, "placeId": placeId});
    return response;
  }

  Future<List<Datos_Comment>> getComments(String placeId) async {
    Response response = await _dio.get(MyApi.getCommentsUrl(placeId));
    print(response.data);
    List<Datos_Comment> comentarios = [];
    if (response.statusCode == 200) {
      response.data as List;
      response.data.forEach(
          (var place) => comentarios.add(Datos_Comment.formJson(place)));
    }

    return comentarios;
  }

  Future<List<HistoryModel>> getHistoryModel(
      DateTime fechaInicio, DateTime fechaFin) async {
    List<HistoryModel> historial = [];
    UserData userData = await ApiPlaceRepository.getInjfoUsuario();
    Response response;
    DateTime initDate;
    DateTime endDate;
    if (fechaInicio.compareTo(fechaFin) == 0) {
      print("es igual");
      initDate =
          DateTime.utc(fechaFin.year, fechaFin.month, fechaFin.day, 0, 0, 0);
      endDate = DateTime.utc(
          fechaInicio.year, fechaInicio.month, fechaInicio.day, 23, 59, 59);
    } else {
      endDate = DateTime.utc(fechaFin.year, fechaFin.month, fechaFin.day,
          fechaFin.hour, fechaFin.minute, fechaFin.second);
      initDate = DateTime.utc(
          fechaInicio.year,
          fechaInicio.month,
          fechaInicio.day,
          fechaInicio.hour,
          fechaInicio.minute,
          fechaInicio.second);
    }

    print("end data ${endDate}");
    print("initn  data ${initDate}");
    response = await _dio.get(MyApi.getHistory(
        userId: userData.id.toString(),
        fechaInicio: initDate.toIso8601String(),
        fechaFin: endDate.toIso8601String()));

    Map<String, dynamic> aux = {};

    if (response.statusCode == 200) {
      response.data as List;
      response.data.forEach((var element) {
        HistoryModel historyModel = HistoryModel.fromJson(element);
        aux[historyModel.placeId!] = historyModel;
        //historial.add(HistoryModel.fromJson(element));
      });
    }
    aux.forEach((k, v) => historial.add(v));

    return historial;
  }

  Future<OneRouteModel> getOneRoute(String rutaId) async {
    UserData userData = await getInjfoUsuario();
    String aux = MyApi.getOneRoute(rutaId: rutaId, userId: userData.id);
    print('//////////////////////////');
    print(aux);
    Response response =
        await _dio.get(MyApi.getOneRoute(rutaId: rutaId, userId: userData.id));
    return OneRouteModel.fromJson(response.data);
  }

  @override
  Future<bool> getSavedPlaces() {
    // TODO: implement getSavedPlaces
    throw UnimplementedError();
  }
}
