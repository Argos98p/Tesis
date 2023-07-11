// ignore: file_names
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:turismup/src/model/place_model.dart';
import 'package:turismup/src/repository/place_api_repository.dart';
import 'package:turismup/src/repository/place_repository.dart';
import 'package:turismup/src/utils/AppColor.dart';
import 'package:turismup/src/widgets/load_screen.dart';

import '../../api/AppApi.dart';
import '../../model/user_data.dart';
import '../../providers/km_around_provider.dart';
import '../../service/api_provider.dart';

class ExplorePage extends StatefulWidget {
  final String category;
  final bool updatePlaces;
  const ExplorePage(
      {super.key, required this.category, required this.updatePlaces});

  @override
  State<ExplorePage> createState() => ExplorePageState();
}

class ExplorePageState extends State<ExplorePage>
    with AutomaticKeepAliveClientMixin {
  final ApiPlaceRepository _placeRepository = ApiPlaceRepository();
  bool selectMode = false;
  List<String> placesSelected = [];
  Future<List<PlaceModel>>? placesFuture;
  Future<String>? _futureAgregarLugar;
  LocationData? _currentLocation;
  double kmAround = 80.0;

  @override
  void initState() {
    super.initState();
    placesFuture = getPlaces();
    kmAround = Provider.of<KmAroundProvider>(context, listen: false).km_around;
  }

  Future<List<PlaceModel>> getPlaces() async {
    Location location = Location();
    location.getLocation().then((value) => print('value ${value}'));

    List<PlaceModel> places = await _placeRepository.getAllPlaces();
    return places;
  }

  Future<LocationData> getCurrentLocation() async {
    Location location = Location();

    LocationData _myLocation = await location.getLocation();
    return _myLocation;
    /*location.onLocationChanged.listen(
          (newLoc) {
        _currentLocation = newLoc;
        if(mounted){
          setState(() {});
        }

      },
    );*/
  }

  List<PlaceModel> filtroDatos(List<PlaceModel> datos) {
    List<PlaceModel> placesFinal = [];

    if (widget.category.toLowerCase().contains("todo") ||
        "todo".contains(widget.category.toLowerCase())) {
      return datos;
    }

    String widgetCategory = widget.category.toLowerCase().split(" ")[2];
    widgetCategory=widgetCategory.trim();

    placesFinal =  datos.where((place) => place.categoria!.toLowerCase().split(",").contains(widgetCategory)).toList();

    /*
    print(widget.category.toLowerCase());

    placesFinal = datos
        .where((place) =>
            place.categoria!
                .toLowerCase()
                .contains(widget.category.toLowerCase()) ||
            widget.category
                .toLowerCase()
                .contains(place.categoria!.toLowerCase()))
        .toList();
*/
    return placesFinal;
  }

  Future<void> _pullRefresh() async {
    List<PlaceModel> places = await getPlaces();
    List<PlaceModel> datosFiltro = filtroDatos(places);
    setState(() {
      placesFuture = Future.value(datosFiltro);
    });
  }

  @override
  Widget build(BuildContext context) {
    double km = context.watch<KmAroundProvider>().km_around;

    if (km != kmAround) {
      print('entraaaaaaaaaaaaa');

      _pullRefresh();
      kmAround =
          Provider.of<KmAroundProvider>(context, listen: false).km_around;
    }

    if (widget.updatePlaces == true) {
      _pullRefresh();
      print('entra');
    }
    super.build(context);
    return Expanded(
      child: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                (selectMode == true)
                    ? Container(
                        color: const Color(0xFFE5E8E8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectMode = false;
                                          placesSelected = [];
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        height: 50,
                                        width: 50,
                                        child: Icon(Icons.cancel),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        print(placesSelected);
                                        _futureAgregarLugar = null;
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return StatefulBuilder(builder:
                                                  (BuildContext context,
                                                      mySetState) {
                                                return ModalMyRoutes(
                                                    context, mySetState);
                                              });
                                            });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        height: 50,
                                        width: 50,
                                        child: Icon(Icons.check),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(),
                Expanded(
                  child: SingleChildScrollView(
                    child: FutureBuilder<List<PlaceModel>>(
                        future: placesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final recursos = snapshot.data!;

                            return CardPlace(recursos);
                          } else {
                            return LoadScreen("Cargando...");
                          }
                        }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List urlimagen = [];

  // ignore: non_constant_identifier_names
  Widget CardPlace(List<PlaceModel> datos) {
    List<PlaceModel> places = filtroDatos(datos);
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
            onLongPress: () {
              setState(() {
                if (selectMode == false) {
                  selectMode = true;
                  Fluttertoast.showToast(
                      msg: "Selecione los lugares para agregar a una ruta",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 2,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  placesSelected.add(place.id!);
                }
              });
            },
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
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              (place.imagenesPaths![0]),
                              fit: BoxFit.cover,
                              height: 180,
                            ),
                          ),
                          Positioned(
                              top: 5,
                              right: 5,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Color(0xFFECEBE9),
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
                                    place.rate! <= 5 && place.rate! > 0
                                        ? Text(
                                            "${place.rate!}",
                                            style: TextStyle(
                                                color: AppColor.primaryColor),
                                          )
                                        : Text("-",
                                            style: TextStyle(
                                                color: AppColor.primaryColor))
                                  ],
                                ),
                              ))
                        ],
                      ),
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
                      place.distancia != null
                          ? Text(
                              "${place.distancia?.toInt()} km",
                              style: TextStyle(color: Colors.blueAccent),
                            )
                          : const Text(
                              "-",
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                      IconButton(
                          onPressed: () {
                            if (place.esFavorito == true) {
                              removeFromFavorite(place, index);
                            } else if (place.esFavorito == false) {
                              addToFavorite(place, index);
                            }
                          },
                          icon: place.esFavorito!
                              ? const Icon(
                                  color: AppColor.primaryColor, Icons.favorite)
                              : const Icon(
                                  Icons.favorite_border_outlined,
                                  color: Colors.blueAccent,
                                ))
                    ],
                  )
                ],
              ),
            ),
            onTap: () async {
              {
                if (selectMode) {
                  if (placesSelected.contains(place.id)) {
                    setState(() {
                      placesSelected.remove(place.id);
                    });
                  } else {
                    setState(() {
                      placesSelected.add(place.id!);
                    });
                  }
                } else {
                  await Navigator.pushNamed(
                    context,
                    '/onePlace',
                    arguments: {'place': place, 'index': index},
                  ).then((value) {
                    value as List;
                    print(place.esFavorito);
                    places.removeAt(value![1]!);
                    places.insert(value![1], value[0]);
                    setState(() {});
                  });
                }
              }
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
      setState(() {});
    }
  }

  Future<void> removeFromFavorite(PlaceModel place, int index) async {
    UserData userData = await ApiPlaceRepository.getInjfoUsuario();
    Response response = await _placeRepository.removeFavorite(
        userData.id.toString(), place.id!);
    if (response.statusCode == 200) {
      place.esFavorito = false;
      setState(() {});
    }
  }

  Widget ModalMyRoutes(context, mySetState) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              "Tus Rutas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            height: 200,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 1),
            child: FutureBuilder(
              future: getRequest(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (_futureAgregarLugar == null) {
                    return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              mySetState(() {
                                _futureAgregarLugar = addPlacesToRoute(
                                    rutaId: snapshot.data[index]["rutaId"],
                                    lugares: placesSelected,
                                    mySetState: mySetState);
                              });
                            },
                            child: ListTile(
                                leading: const Icon(Icons.location_on),
                                trailing: const Text(
                                  "GFG",
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 15),
                                ),
                                title: Text(snapshot.data[index]["nombre"])),
                          );
                        });
                  } else {
                    return FutureBuilder(
                      future: _futureAgregarLugar,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          mySetState() {}
                          ;
                          return const Text("Lugares agregados");
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }

                        return const CircularProgressIndicator();
                      },
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String> addPlacesToRoute({rutaId, lugares, mySetState}) async {
    UserData userData = await ApiPlaceRepository.getInjfoUsuario();
    final http.Response response = await http.post(
      Uri.parse(MyApi.agregarLugaresRuta),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, Object>{
        "userId": userData.id.toString(),
        "rutaId": rutaId,
        "lugares": lugares
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      setState(() {
        selectMode = false;
        placesSelected = [];
      });
      return "Lugares agregados";
    } else {
      _futureAgregarLugar = null;
      setState(() {});
      mySetState(() {});
      _futureAgregarLugar = null;
      throw Exception('Failed to create album.');
    }
  }

  Future<List> getRequest() async {
    //
    UserData userData = await ApiPlaceRepository.getInjfoUsuario();
    String url = MyApi.getRoutes(userId: userData.id);
    final response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);
    return responseData;
  }

  @override
  bool get wantKeepAlive => true;
}
