import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turismup/src/api/AppApi.dart';
import 'package:turismup/src/model/place_model.dart';
import 'package:turismup/src/repository/place_api_repository.dart';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import '../../model/user_data.dart';
import '../../utils/AppColor.dart';

class SearchPlaceDelegate extends SearchDelegate {
  Future<List<PlaceModel>>? placesFuture;
  final Dio _dio = Dio();
  final ApiPlaceRepository _placeRepository = ApiPlaceRepository();
  // final ApiPlaceRepository _placeRepository = ApiPlaceRepository();
  // @override
  // String get searchFielLabel => 'Buscar Lugar';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  // @override
  // Widget buildResults(BuildContext context) {
  //   // TODO: implement buildResults
  //   return const Text('asdass');
  // }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return FutureBuilder<List<PlaceModel>>(
        future: getPlace(query),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final recursos = snapshot.data!;
            if (recursos.isEmpty) {
              return const Center(child: Text("No existen coincidencias"));
            } else {
              return SingleChildScrollView(
                child: Column(children: <Widget>[
                  CardPlace(context, recursos),
                ]),
              );
            }
          } else if (snapshot.hasError) {
            return Center(child: Text("No existen resultados"));
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  List<String> placesSelected = [];
  Widget CardPlace(BuildContext context, List<PlaceModel> places) {
    return Container(
      color: Color(0xFFE5E8E8),
      child: GridView.count(
        padding: const EdgeInsets.only(top: 3),
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 4.0,
        childAspectRatio: 0.68,
        mainAxisSpacing: 4.0,
        children: List.generate(places.length, (index) {
          final place = places[index];
          return InkWell(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (placesSelected.contains(place.id))
                    ? Color(0xFF58D68D)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Stack(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            (place.imagenesPaths![0]),
                            fit: BoxFit.fill,
                            height: 180,
                          ),
                        ),
                        Positioned(
                            top: 5,
                            right: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: const Color(0xFFECEBE9),
                                  borderRadius: BorderRadius.circular(20)),
                              height: 27,
                              width: 55,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Icon(
                                    size: 18,
                                    Icons.star,
                                    color: AppColor.ratedStarColor,
                                  ),
                                  place.rate! < 5
                                      ? Text(
                                    "${place.rate!}",
                                    style: const TextStyle(
                                        color: AppColor.primaryColor),
                                  )
                                      : const Text("-",
                                      style: TextStyle(
                                          color: AppColor.primaryColor))
                                ],
                              ),
                            ))
                      ]),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    (place.nombre).toString(),
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    place.region!.nombre!,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
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
                      IconButton(
                          onPressed: () {
                            // if (place.esFavorito == true) {
                            //   removeFromFavorite(place, index);
                            // } else if (place.esFavorito == false) {
                            //   addToFavorite(place, index);
                            // }
                            print('presionado');
                          },
                          icon: const Icon(
                            Icons.favorite_border_outlined,
                            color: Colors.blueAccent,
                          ))
                    ],
                  )
                ],
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/onePlace',
                arguments: {'place': place, 'index': index},
              );
            },
          );
        }),
      ),
    );
  }

  Future<void> addToFavorite(PlaceModel place, int index) async {
    UserData userData = await ApiPlaceRepository.getInjfoUsuario();
    Response response =
    await _placeRepository.addFavorite(userData.id.toString(), place.id!);
    if (response.statusCode == 200) {
      place.esFavorito = true;
      // setState(() {});
    }
  }

  Future<void> removeFromFavorite(PlaceModel place, int index) async {
    UserData userData = await ApiPlaceRepository.getInjfoUsuario();
    Response response = await _placeRepository.removeFavorite(
        userData.id.toString(), place.id!);
    if (response.statusCode == 200) {
      place.esFavorito = false;
      // setState(() {});
    }
  }

  Future<List<PlaceModel>> getPlace(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? id = prefs.getInt('userId');
    print('//////////////////////////');
    print(id);
    List<PlaceModel> places = [];
    if (query != '') {
      try {
        Response response =
        await _dio.get(MyApi.buscarLugar(userId: id) + query);
        response.data
            .forEach((var place) => places.add(PlaceModel.fromJson(place)));
      } catch (error, stacktrace) {
        print("errrrrrrrrrrrrrrrrrrrrrror");
        print("Exception occured: $error stackTrace: $stacktrace");
      }
    }
    return places;
  }

  // Navigator.pushNamed(
  //                   context,
  //                   '/onePlace',
  //                   arguments: {'place': place},
  //                 );

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return const Text('');
  }
}