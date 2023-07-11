import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:turismup/src/model/place_model.dart';
import 'package:turismup/src/pages/map/route_map_multiple_places.dart';
import 'package:turismup/src/utils/AppColor.dart';
import 'package:turismup/src/widgets/load_screen.dart';

import '../repository/place_api_repository.dart';

class OfficialRoutesPage extends StatefulWidget {
  const OfficialRoutesPage({Key? key}) : super(key: key);

  @override
  State<OfficialRoutesPage> createState() => _OfficialRoutesPageState();
}

class _OfficialRoutesPageState extends State<OfficialRoutesPage> {
  final ApiPlaceRepository _placeRepository = ApiPlaceRepository();
  Future<List<PlaceModel>>? placesFuture;

  Future<List<PlaceModel>> getPlaces() async {
    List<PlaceModel> places = await _placeRepository.getPlacesRoute();
    return places;
  }

  @override
  void initState() {
    placesFuture = getPlaces();
    // TODO: implement initState
    super.initState();
  }



  List<PlaceModel> cargarRuta1(List<PlaceModel> lugares) {
    List<PlaceModel> ruta = [];
    for (int i = 0; i < lugares.length; i++) {
      if (lugares[i].id == '90ac15b6-16c6-4b72-acc0-d3dd3c1aa61f') {
        ruta.add(lugares[i]);
      }
      if (lugares[i].id == '5ea25e7d-7f8e-4057-835a-54c0bcfb8811') {
        ruta.add(lugares[i]);
      }
      if (lugares[i].id == '6b11cb8b-ec79-4812-a39c-3d4cab140b45') {
        ruta.add(lugares[i]);
      }
      if (lugares[i].id == '35449d8c-baa3-4cb7-9ee5-40b6f28fa253') {
        ruta.add(lugares[i]);
      }
    }
    return ruta;
  }




  List<String> imagenesMosaico(List<PlaceModel> lugares) {
    List<String> imagenes = [];
    for (int i = 0; i < lugares.length; i++) {
      imagenes.add(lugares[i].imagenesPaths![0]);
    }
    return imagenes;
  }

  List<List<PlaceModel>> rutasT = [];

  Widget cargarRutas(List<PlaceModel> lugares) {
    List<String> imagenes1 = [];
    List<String> imagenes2 = [];
    List<String> imagenes3 = [];
    List<PlaceModel> ruta1 = cargarRuta1(lugares);

    rutasT.add(ruta1);
    imagenes1 = imagenesMosaico(ruta1);
    return GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        children: [
          rutaCard(imagenes1, ruta1),
        ]);
  }



  Widget rutaCard(List<String> imagenes, List<PlaceModel> ruta) {
    return InkWell(
      child: Container(
        height: 300,
        width: 200,
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
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
                child: ClipRRect(
                    //borderRadius: BorderRadius.circular(8.0),
                    child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                      crossAxisCount: 2),
                  itemCount: 4,
                  itemBuilder: (BuildContext context, int index) {
                    return Image.network(
                      (imagenes[index]),
                      fit: BoxFit.cover,
                    );
                  },
                )),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Ruta Centro historico",
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.w900),
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
            /*
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '1KM',
                  style: TextStyle(color: Colors.blueAccent),
                ),

                IconButton(
                    onPressed: () {
                      print('presionado');
                    },
                    icon: const Icon(
                      Icons.favorite_border_outlined,
                      color: Colors.blueAccent,
                    ))
              ],
            )*/
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RouteMapMultiplePlaces(recursos: ruta)),
        );
        print('presionado');
      },
    );
  }

// ignore: non_constant_identifier_names
  Widget _NumResources() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Text(
              "1 Ruta",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
            Row(
              children: [
                /*
                Icon(Icons.view_list_rounded),*/
                SizedBox(
                  width: 15,
                ),
                Icon(
                  Icons.grid_view,
                  color: Colors.blueAccent,
                ),
                SizedBox(
                  width: 15,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE5E8E8),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        shadowColor: Colors.transparent,
        title: const Text(
          'Rutas Oficiales',
          style: TextStyle(color: AppColor.myTextColor),
        ),
        // ignore: prefer_const_literals_to_create_immutables
        actions: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
          // ignore: prefer_const_constructors
          Row(
            children: const [
              /*
              Icon(
                FontAwesomeIcons.search,
                color: AppColor.myTextColor,
              ),
              SizedBox(
                width: 20,
              ),
              Icon(FontAwesomeIcons.sliders, color: AppColor.myTextColor),
              SizedBox(
                width: 20,
              )*/
            ],
          )
        ],
      ),
      body: Column(
        children: [
          _NumResources(),
          Expanded(
            child: SingleChildScrollView(
                child: FutureBuilder<List<PlaceModel>>(
              future: placesFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final recursos = snapshot.data!;
                  return cargarRutas(recursos);
                } else {
                  return LoadScreen("Cargando Rutas...");
                }
              },
            )),
          )
        ],
      ),
    );
  }
}
