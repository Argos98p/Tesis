import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turismup/src/api/AppApi.dart';
import 'package:turismup/src/model/user_data.dart';
import 'package:turismup/src/repository/place_api_repository.dart';

import '../../api/google_signin_api.dart';
import '../../service/connectivity_utils.dart';
import '../../widgets/my_divider.dart';
import '../../widgets/title_login_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      color: Color(0xFFFFFFFF),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: height * 0.1, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              logoContainer(width * 0.8, context),
              const SizedBox(
                height: 40,
              ),
              textLogin("Inicia Sesion"),
              const SizedBox(
                height: 40,
              ),
              /*
                  myDivider(""),
                  const Center(child: Text('Tu mejor opción para viajar')),
                  // socialButton('assets/icons/fb.png', "Continuar con Facebook",
                  //     context, '/home'),
                  myDivider(""),*/
              socialButton('assets/icons/google.png', "Continuar con Google",
                  context, '/home'),
              // myDivider("o"),
              // loginEmail(context),
              // noHaveAccount(context)
            ],
          ),
        ),
      ),
    ));
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      checkInit(context);
    });
  }
}

// Future permisos() async {
//   LocationPermission permission;
//   permission = await Geolocator.requestPermission();
// }

Future checkInit(context) async {
  bool online = await ConnectivityUtils.hasConnection();
  LocationPermission permission;
  if (online) {
    permission = await Geolocator.checkPermission();

    if(permission == LocationPermission.deniedForever || permission == LocationPermission.denied ){
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.deniedForever || permission == LocationPermission.denied ){
      exit(0);
    }

    var result = await GoogleSignInApi.checkLogin();
    if (result != null) {
      GoogleSignInAccount? currentUser = GoogleSignInApi.currentUser();
      Fluttertoast.showToast(msg: "Inicio de sesion con ${currentUser?.email}");
      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    }
  } else {
    //no tiene conexxion
    UserData userData = await ApiPlaceRepository.getInjfoUsuario();
    print(userData.toJson());
    if (userData.token == "") {
    } else {
      Fluttertoast.showToast(msg: "accediste como ${userData.email}");
      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    }
  }
}

Widget logoContainer(width, context) {
  return Image.asset(
    'assets/images/logoFinal.png',
    height: width,
  );
}

Widget socialButton(socialLogo, myText, context, myRoute) {
  return Container(
    margin: EdgeInsets.only(top: 16),
    width: double.infinity,
    height: 50,
    color: const Color(0xFFFFFBFB),
    child: OutlinedButton(
        onPressed: () {
          signIn(context);
          /*
          Navigator.pushReplacementNamed(context,
            '/home',);*/
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(0xFF000000),
          textStyle: const TextStyle(color: Color(0xFF000000)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              socialLogo,
              height: 34,
            ),
            const SizedBox(
              width: 40,
            ),
            Text(myText)
          ],
        )),
  );
}

int id = -1;
String token = '';

Future<void> guardarDatos(
    int id, String token, String email, String nombre, String urlPhoto) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('userId', id);
  await prefs.setString('userToken', token);
  await prefs.setString('userEmail', email);
  await prefs.setString('userName', nombre);
  await prefs.setString('userUrlPhoto', urlPhoto);
  print('datos guardados');
}

Future signIn(context) async {
  final user = await GoogleSignInApi.login();
  var aux = user?.authentication;
  if (id != -1) {
    if (id != null) {
      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    }
  } else {
    user?.authentication.then((value) async {
      log('data: ${value.idToken}');
      if (kDebugMode) {
        print('acess token ${value.idToken}');
      }
      final Dio _dio = Dio();
      Map<String, String> data = {"googleIdToken": value.accessToken ?? ""};
      var response = await _dio.post('${MyApi.microUsuarios}auth/google-auth?googleIdToken=${value.idToken}',
          data: data);
      if (response.statusCode == 200) {
        guardarDatos(response.data['userData']['id'], response.data['token'],
            user.email, user.displayName!, user.photoUrl!);
        await Future.delayed(const Duration(seconds: 1));

        Fluttertoast.showToast(
            msg: 'Inicio de sesion con ${response.data["userData"]["email"]}');
        Navigator.pushReplacementNamed(
          context,
          '/home',
        );
      } else {
        Fluttertoast.showToast(
            msg: 'Error iniciando sesion ${response.statusCode}');
      }
      log('response + ${response.data}');
    });
  }
}

Widget loginEmail(context) {
  return Container(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: () {
        Navigator.pushReplacementNamed(
          context,
          '/home',
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF246BFD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text('Ingresar con correo electronico'),
    ),
  );
}

Widget noHaveAccount(context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "No tienes cuenta ?",
        style: TextStyle(color: Color(0xff555555)),
      ),
      TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              '/home',
            );
          },
          child: const Text("Registrarse"))
    ],
  );
}