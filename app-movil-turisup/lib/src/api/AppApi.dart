class MyApi {
  //static String BASE = "http://34.71.215.168:8083/";
  static String BASE = "http://35.222.144.68:8083/";
  static String microUsuarios= "http://35.222.144.68:8080/";


  // static String getRoutes = "${BASE}api/ruta?userId=14";
  static String getRoutes({userId}) {
    return "${BASE}api/ruta?userId=${userId}";
  }



  static String getPlaceById = "${BASE}api/recurso/todos?lugarId=";


  static String createRuta = "${BASE}api/recurso/nuevaRuta";

  static String agregarLugaresRuta = "${BASE}api/ruta/agregarLugares";


  static eliminarRuta({userId, rutaId}) {
    return '${BASE}api/ruta/eliminarRuta?rutaId=${rutaId}&userId=${userId}';
  }
  static String getOneRoute({rutaId, userId}){
    return "${BASE}api/ruta/id?rutaId=${rutaId}&userId=${userId}";
  }


  static String nuevoComentario = "${BASE}api/comentario/nuevo";


  static String getRecursos({userId}) {

    return "${BASE}api/recurso/todos?estadoLugar=aceptado&userId=9";
  }

  static String nuevoLugar = '${BASE}api/recurso/nuevo';
  static String buscarLugar({userId}) {
    return "${BASE}api/recurso/todos?estadoLugar=aceptado&userId=9&buscar=";
  }

  static getFavoritesUrl(String userId) {
    print("entra");
    print(userId);
    return '${BASE}api/favorito?userId=${userId}';
  }

  static getCommentsUrl (String placeId){
    return '${BASE}api/comentario?lugarId=${placeId}';
  }


  static String insertFavorite = '${BASE}api/favorito';
  static String deleteFavorite = '${BASE}api/favorito/eliminar';
  static String getHistory ({required String userId, required String fechaInicio, required String fechaFin}){
    return "${BASE}api/recurso/historial?userId=${userId}&fechaInicio=${fechaInicio}&fechaFin=${fechaFin}";
  }
}