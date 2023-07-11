import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:turismup/src/api/AppApi.dart';
import 'package:turismup/src/model/one_route_model.dart';
import 'package:turismup/src/repository/place_api_repository.dart';

import '../../model/place_model.dart';
import '../../model/user_data.dart';
import '../map/route_map_multiple_places.dart';

class MyRoutes extends StatefulWidget {
  const MyRoutes({Key? key}) : super(key: key);

  @override
  State<MyRoutes> createState() => _MyRoutesState();
}

class _MyRoutesState extends State<MyRoutes> {
  TextEditingController nombreInputController = TextEditingController();
  TextEditingController descripcionInputController = TextEditingController();
  Future<String>? _futureRoute;
  Future<String>? _futureDeleteRoute;
  UserData? userData;
  String id = '';
  ApiPlaceRepository apiPlaceRepository = ApiPlaceRepository();

  @override
  void initState() {
    super.initState();
    loasUserData();
  }

  Future loasUserData() async {
    userData = await ApiPlaceRepository.getInjfoUsuario();
    id = (userData!.id).toString();
    setState(() {});
  }

  Future<List> getRequest() async {
    //replace your restFull API here.
    UserData userData = await ApiPlaceRepository.getInjfoUsuario();
    String url = MyApi.getRoutes(userId: userData.id);
    print(url);
    final response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);
    return responseData;
  }

  @override
  void dispose() {
    nombreInputController.dispose();
    descripcionInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          OutlinedButton(
              onPressed: () {
                setState(() {
                  nombreInputController.text = "";
                  descripcionInputController.text = "";
                  _futureRoute = null;
                });
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                          builder: (BuildContext context, mySetState) {
                        return SingleChildScrollView(
                            child: Container(
                                color: const Color(0xFFFFFFFF),
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      20.0, 20.0, 20.0, 0.0), // content padding
                                  child: (_futureRoute == null)
                                      ? Column(
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Text(
                                              "Nueva Ruta",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            myTextField(
                                              mySetState,
                                              Icons.drive_file_rename_outline,
                                              nombreInputController,
                                              myHintText: "Nombre",
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            myTextField(
                                              mySetState,
                                              Icons.description,
                                              descripcionInputController,
                                              myHintText: "descripcion",
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            btnCrearRuta(mySetState),
                                            SizedBox(
                                              height: 30,
                                            )
                                          ],
                                        )
                                      : FutureBuilder(
                                          future: _futureRoute,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              setState() {}
                                              ;
                                              return Text("Ruta creada");
                                            } else if (snapshot.hasError) {
                                              return Text("${snapshot.error}");
                                            }

                                            return const CircularProgressIndicator();
                                          },
                                        ),
                                )));
                      }); // From with TextField inside
                    });
              },
              child: Text("Crear nueva ruta")),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 1),
              child: FutureBuilder(
                future: getRequest(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.data == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return GridView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                childAspectRatio: 3 / 2,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20),
                        itemCount: snapshot.data.length,
                        itemBuilder: (ctx, index) => GestureDetector(
                              onLongPress: () {
                                _futureDeleteRoute = null;
                                HapticFeedback.vibrate();
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(builder:
                                          (BuildContext context, mySetState) {
                                        return Container(
                                          height: 80,
                                          child: (_futureDeleteRoute == null)
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          100, // <-- Your width
                                                      height: 50,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          print(snapshot
                                                                  .data[index]
                                                              ["rutaId"]);
                                                          _futureDeleteRoute =
                                                              deletRoute(
                                                                  snapshot.data[
                                                                          index]
                                                                      [
                                                                      "rutaId"],
                                                                  mySetState);
                                                        },
                                                        child: Text('Eliminar'),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.redAccent,
                                                          shadowColor:
                                                              Colors.green,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          100, // <-- Your width
                                                      height: 50,
                                                      child: OutlinedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text('Cancelar'),
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          foregroundColor:
                                                              Colors.blueGrey,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : FutureBuilder(
                                                  future: _futureDeleteRoute,
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      setState() {}
                                                      return Text(
                                                          "Ruta eliminada");
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return Text(
                                                          "${snapshot.error}");
                                                    }

                                                    return const CircularProgressIndicator();
                                                  },
                                                ),
                                        );
                                      });
                                    });
                              },
                              onTap: () async {
                                Fluttertoast.showToast(
                                    msg: 'Obteniendo informacion de la ruta ...');
                                OneRouteModel routeModel =
                                    await apiPlaceRepository.getOneRoute(
                                        snapshot.data[index]["rutaId"]);
                                print(routeModel.lugares!);
                                if (routeModel.lugares!.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg: 'Esta ruta no posee lugares');
                                } else {
                                  // ignore: use_build_context_synchronously
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RouteMapMultiplePlaces(
                                                recursos: routeModel.lugares!,
                                              )));
                                }

                                /*Navigator.pushNamed(
                                  context,
                                  '/oneRoute',
                                  arguments: {
                                    'exampleArgument': snapshot.data[index]
                                        ["rutaId"]
                                  },
                                );*/
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.lightBlue,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Text(
                                  snapshot.data[index]["nombre"],
                                  style:
                                      const TextStyle(color: Color(0xFFFFFFFF)),
                                ),
                              ),
                            ));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget btnCrearRuta(mySetState) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (_errorText == null) {
            print("entra");
            // notify the parent widget via the onSubmit callback
            mySetState(() {
              _futureRoute = createRoute(nombreInputController.value.text,
                  descripcionInputController.value.text, mySetState);
            });
          } else {}
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF246BFD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text('Crear'),
      ),
    );
  }

  Future<String> deletRoute(String rutaId, myState) async {
    UserData userData = await ApiPlaceRepository.getInjfoUsuario();
    final http.Response response = await http.post(
      Uri.parse(
          MyApi.eliminarRuta(userId: userData.id.toString(), rutaId: rutaId)),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      myState(() {});
      setState(() {});
      return "Todo ok";
    } else {
      return response.statusCode.toString();
    }
  }

  Future<String> createRoute(
      String nombre, String descripcion, mySetState) async {
    UserData userData = await ApiPlaceRepository.getInjfoUsuario();
    final http.Response response = await http.post(
      Uri.parse(MyApi.createRuta),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, Object>{
        "userId": userData.id.toString(),
        "nombre": nombre,
        "descripcion": descripcion,
        "lugares": []
      }),
    );
    if (response.statusCode == 200) {
      setState(() {});
      return response.body.toString();
    } else {
      _futureRoute = null;
      setState(() {});
      mySetState(() {});
      _futureRoute = null;
      throw Exception('Failed to create album.');
    }
  }

  Widget myTextField(mySetState, myIcon, myController,
      {myHintText = "", myBorderRadius = 12.0}) {
    return TextField(
        onChanged: (_) => mySetState(() {}),
        controller: myController,
        decoration: InputDecoration(
          errorText: _errorText,
          suffixIcon: Icon(myIcon),
          fillColor: const Color(0xFFFAFAFA),
          hintText: myHintText,
          filled: true,
          border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(myBorderRadius))),
        ));
  }

  String? get _errorText {
    // at any time, we can get the text from _controller.value.text
    final text = nombreInputController.value.text;
    // Note: you can do your own custom validation here
    // Move this logic this outside the widget for more testable code
    if (text.isEmpty) {
      return 'Can\'t be empty';
    }
    if (text.length < 4) {
      return 'Too short';
    }
    // return null if the text is valid
    return null;
  }
}
