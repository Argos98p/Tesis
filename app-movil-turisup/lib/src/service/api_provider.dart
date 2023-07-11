import '../model/place_model.dart';
import 'api_repository.dart';

class ApiRepository{
  final _provider = ApiProvider();
  Future<DatosModel> fetchPlaces(){
    return _provider.fetchPlaces();
  }
}

class NetworkError extends Error {}