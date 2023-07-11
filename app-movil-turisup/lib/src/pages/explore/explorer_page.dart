import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turismup/src/pages/explore/explorer_places_page.dart';
import 'package:turismup/src/pages/new_place_page.dart';
import 'package:turismup/src/pages/explore/search_place.dart';
import '../../providers/km_around_provider.dart';
import '../../utils/AppColor.dart';

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key, required bool isOffline});
  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  Color myTextColor = Color(0xFF000000);
  double? _myKmAround;
  String filter = "todo";
  bool changeSettings = false;

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('km_around')) {
      _myKmAround = prefs.getDouble('km_around');
      print("existe" + _myKmAround.toString());
    } else {
      prefs.setDouble('km_around', 50.0);
      _myKmAround = 50.0;
      print("No existe" + _myKmAround.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getSharedPrefs();
    ExplorePage(
      updatePlaces: false,
      category: filter,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC2c2c2),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        shadowColor: Colors.transparent,
        title: Text(
          'Explorar',
          style: TextStyle(color: myTextColor),
        ),
        actions: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    showSearch(
                        context: context, delegate: SearchPlaceDelegate());
                    print('pressed');
                  },
                  icon: Icon(
                    FontAwesomeIcons.search,
                    color: myTextColor,
                  )),
              const SizedBox(
                width: 20,
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/settings");
                  //  .then((value) => setState(() {
                  //  changeSettings=true;
                  //  }));
                },
                icon: Icon(FontAwesomeIcons.sliders, color: myTextColor),
              ),
              const SizedBox(
                width: 20,
              )
            ],
          )
        ],
      ),
      body: Container(
        color: Color(0xFFE5E8E8),
        child: Column(
          children: <Widget>[
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _CrearBotonesCabecera()),
            Container(color: Colors.white, child: _NumResources()),
            ExplorePage(
              updatePlaces: changeSettings,
              category: filter,
            ),
          ],
        ),
      ),
      floatingActionButton: _crearBoton(),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _NumResources() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Recursos",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
          Row(
            children: [
              // Icon(Icons.view_list_rounded),
              // SizedBox(
              //   width: 15,
              // ),

              IconButton(
                onPressed: () {
                  setState(() {});
                  print('recargado');
                },
                icon: Icon(Icons.dashboard, color: AppColor.primaryColor),
              ),
              // const Icon(
              //   Icons.grid_view,
              //   color: Colors.blueAccent,
              // ),
              const SizedBox(
                width: 15,
              )
            ],
          )
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _ButtonIni(String nombre) {
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4),
        child: OutlinedButton(
          onPressed: () {
            setState(() {

              filter = nombre;
            });
          },
          style: OutlinedButton.styleFrom(
            backgroundColor:
                filter == nombre ? AppColor.primaryColorOpacity : Colors.white,
            shape: StadiumBorder(),
          ),
          child: Text(nombre),
        ));
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

  // ignore: non_constant_identifier_names
  Widget _CrearBotonesCabecera() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        _ButtonIni('✅  Todo'),
        _ButtonIni('🎭  Museo'),
        _ButtonIni('⛪  Iglesia'),
        _ButtonIni('🛶  Laguna'),
        _ButtonIni('🏞  Montaña'),
        _ButtonIni('🛌  Hotel'),
        //_ButtonIni('🏖  Playas'),



      ],
    );
  }
}
