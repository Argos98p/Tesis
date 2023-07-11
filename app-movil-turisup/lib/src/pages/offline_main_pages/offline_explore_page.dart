import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readmore/readmore.dart';
import 'package:turismup/src/model/place_model.dart';
import 'package:turismup/src/pages/one_place_page.dart';
import 'package:turismup/src/repository/place_repository.dart';
import 'package:turismup/src/utils/AppColor.dart';

import '../new_place_page.dart';

class OfflineExplorePage extends StatefulWidget {
  const OfflineExplorePage({super.key});

  @override
  State<OfflineExplorePage> createState() => _OfflineExplorePageState();
}

class _OfflineExplorePageState extends State<OfflineExplorePage> {
  var aux;
  var coment;
  dynamic vacio = [];
  Color myTextColor = const Color(0xFF000000);
  TextEditingController commentController = TextEditingController();
  final ImagePicker imgpicker = ImagePicker();
  List<XFile>? imagefiles;
  Future<int>? _futureNewComment;
  int rate = 3;
  final _storageKey = 'storedData';
  PlaceRepository _placeRepository = GetIt.I.get();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE5E8E8),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        shadowColor: Colors.transparent,
        title: Text(
          'Recursos',
          style: TextStyle(color: myTextColor),
        ),
        // ignore: prefer_const_literals_to_create_immutables
        actions: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
        ],
      ),
      floatingActionButton: _crearBoton(),
      body: FutureBuilder<List<PlaceModel>>(
        future: readLocalPlaces(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            print("dataaaaaaaaaaaa" +snapshot.data.toString());
            return buildPlaces(snapshot.data);
          }

          else {
            if (snapshot.hasError) {
              return Text('Error al leer el archivo');
            } else {
              return Text('Error al leer el archivo');
            }
          }
        },
      ),
    );
  }

  Widget _crearBoton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        const SizedBox(
          width: 30.0,
        ),
        FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                // MaterialPageRoute(builder: (context) => CrearRecursoPage()),
                MaterialPageRoute(builder: (context) => const NewPlacePage()),
              );
            }),
        const SizedBox(
          width: 10.0,
        ),
      ],
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }


  Future<List<PlaceModel>> readLocalPlaces() async {
    List<PlaceModel> recursos = await _placeRepository.getAllPlaces();
    return recursos;
  }

  Widget buildPlaces(List<PlaceModel> datos) =>
      GridView.count(
        // Crea una grid con 2 columnas. Si cambias el scrollDirection a
        // horizontal, esto produciría 2 filas.
        crossAxisCount: 2,
        crossAxisSpacing: 4.0,
        childAspectRatio: 0.63,
        mainAxisSpacing: 4.0,
        // Genera 100 Widgets que muestran su índice en la lista
        children: List.generate(datos.length, (index) {
          final place = datos[index];
          return InkWell(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),

                        child: FutureBuilder<Widget>(
                          future: showLocalImage(place.localImages![0]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return snapshot.data!;
                            } else {
                              return Image.asset("assets/imageNotFound.jpg");
                            }
                          },
                        )
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
                  const Text(
                    'centro',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Color.fromRGBO(164, 172, 188, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w100),
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/onePlace',
                arguments: {'place': place, 'index':index, 'offline':true},
              );
            },
          );
        }),
      );

  Future<Widget> showLocalImage(String imagePath) async {
    File localImage = File(imagePath);

    if (await localImage.exists()) {
      return Image.file(localImage);
    } else {
      return Image.asset("assets/imageNotFound.jpg");
    }
  }

}