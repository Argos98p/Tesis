import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turismup/src/model/user_data.dart';
import 'package:turismup/src/pages/profile/download_resources/download_resources_page.dart';
import 'package:turismup/src/pages/profile/my_routes.dart';
import 'package:turismup/src/pages/profile/profile_my_favorites_page.dart';
import 'package:turismup/src/repository/place_api_repository.dart';

import '../../api/google_signin_api.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController dateInput = TextEditingController();
  TextEditingController nombreInput = TextEditingController();
  TextEditingController emailInput = TextEditingController();
  TextEditingController nickInput = TextEditingController();
  TextEditingController searchInput = TextEditingController();

  var data = {
    "nombre": "Ricardo Jarro",
    "nick": "rick619",
    "email": "ricardo.jarro98@gmail.com",
    "birthday": "2023-02-16",
    "img": ""
  };
  String userImage =
      "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png";
  UserData? userData;

  @override
  initState() {
    //_cargarDatos();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userData = await _cargarDatos();
      await Future.delayed(const Duration(seconds: 2));
      print("datos sssssssssss ${userData?.toJson()}");
      nombreInput.text = userData!.nombre;
      nickInput.text = userData!.urlPhoto;
      emailInput.text = userData!.email;
      userImage = userData!.urlPhoto;
    });
    setState(() {});
    super.initState();

    // nombreInput.text = data["nombre"]!;
    // nickInput.text = data["nick"]!;
    // emailInput.text = data["email"]!;
  }

  Widget editWidget(dateInput, context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 30),
          myTextField(Icons.person, nombreInput),
          const SizedBox(height: 10),
          //myTextField(Icons.dashboard, nickInput),
          //const SizedBox(height: 10),
          myTextField(Icons.email_outlined, emailInput),
          const SizedBox(height: 10),
          //dateTextField(dateInput, context),
          const SizedBox(height: 30),
          btnRegistrar(),
        ],
      ),
    );
  }

  Future<void> eliminarDatos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Widget btnRegistrar() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          await GoogleSignInApi.logout();
          // await GoogleSignInApi.disconnect();
          await eliminarDatos();
          Navigator.pushReplacementNamed(context, '/');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF246BFD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text('Cerrar sesion'),
      ),
    );
  }

  Widget myTextField(myIcon, myController,
      {myHintText = "", myBorderRadius = 12.0}) {
    return TextField(
        enabled: false,
        controller: myController,
        decoration: InputDecoration(
          suffixIcon: Icon(myIcon),
          fillColor: const Color(0xFFFAFAFA),
          hintText: myHintText,
          filled: true,
          border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(myBorderRadius))),
        ));
  }

  Widget dateTextField(dateInput, context) {
    return TextField(
      enabled: false,
      controller: dateInput,
      //editing controller of this TextField
      decoration: const InputDecoration(
        suffixIcon: Icon(Icons.calendar_today_outlined),
        fillColor: Color(0xFFFAFAFA),
        hintText: "",
        filled: true,
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      readOnly: true,
      //set it true, so that user will not able to edit text
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1950),
            //DateTime.now() - not to allow to choose before today.
            lastDate: DateTime(2100));

        if (pickedDate != null) {
          print(
              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          print(formattedDate);
          setState(() {
            dateInput.text = formattedDate;
          });
        } else {}
      },
    );
  }

  Future<UserData> _cargarDatos() async {
    UserData infoUsuario = await getInfoUser();

    return infoUsuario;
  }

  Future<UserData> getInfoUser() async {
    UserData datosUsuario = await ApiPlaceRepository.getInjfoUsuario();
    await Future.delayed(const Duration(seconds: 3));
    print(datosUsuario.toJson());
    return datosUsuario;
  }

  @override
  Widget build(BuildContext context) {
    Color myTextColor = Color(0xFF000000);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        shadowColor: Colors.transparent,
        title: Text(
          'Mi Perfil',
          style: TextStyle(color: myTextColor),
        ),
        actions: const [
          Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Stack(
              fit: StackFit.loose,
              children: [
                Positioned(
                  child: SizedBox(
                    height: 150,
                    child: CircularProfileAvatar('',
                        borderColor: Colors.transparent,
                        borderWidth: 0,
                        elevation: 3,
                        radius: 75,
                        child: Image.network(
                          userImage,
                          fit: BoxFit.cover,
                        )),
                  ),
                ),
                /*Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 35,
                    width: 35,
                    decoration: const ShapeDecoration(
                      color: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                            bottomLeft: Radius.zero),
                      ),
                    ),
                    child: IconButton(
                      iconSize: 20,
                      icon: const Icon(Icons.edit),
                      color: Colors.white,
                      onPressed: () {
                        print("");
                      },
                    ),
                  ),
                ),*/
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: DefaultTabController(
                  length: 4, // length of tabs
                  initialIndex: 0,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const TabBar(
                          labelColor: Color(0xFF246BFD),
                          unselectedLabelColor: Colors.black38,
                          tabs: [
                            Tab(text: 'Editar'),
                            Tab(text: 'Favoritos'),
                            Tab(text: 'Mi lista'),
                            Tab(
                              text: "Offline",
                            )
                          ],
                        ),
                        Expanded(
                            //height of TabBarView

                            child: TabBarView(children: <Widget>[
                          editWidget(dateInput, context),
                          ProfileMyFavoritesPage(),
                          MyRoutes(),
                          DownloadReourcesPage(),
                        ]))
                      ])),
            ),
          ],
        ),
      ),
    );
  }
}
