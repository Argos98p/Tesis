
import 'package:dio/dio.dart';

import '../model/place_model.dart';


class ApiProvider{
  final Dio _dio = Dio();
  static const BASE = "http://35.222.144.68:8083/";
  static const getRoutes = BASE+"api/ruta?userId=";
  static const getRoute= BASE+"api/ruta/id?rutaId=";
  static const getPlaceById=BASE+"api/recurso/todos?lugarId=";
  static const createRuta = BASE+"api/recurso/nuevaRuta";
  static const agregarLugaresRuta = BASE+"api/ruta/agregarLugares";
  static const nuevoComentario= BASE+"api/comentario/nuevo";
  static const getRecursos = BASE +"api/recurso/todos?estadoLugar=aceptado";

  Future<DatosModel>fetchPlaces() async{
    List<PlaceModel> places = [];
    try{
      Response response = await _dio.get(getRecursos);
      //response.data.forEach((var place) => places.add(PlaceModel.formJson(place)));
      return DatosModel(datos: places);
    }catch(error,stacktrace){
      print("Exception occured: $error stackTrace: $stacktrace");
      return DatosModel.withError("Data not found / Connection issue");
      //return PlaceModel.withError("Data not found / Connection issue");
    }
  }

}