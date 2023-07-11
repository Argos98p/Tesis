import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:turismup/src/pages/home_page.dart';
import 'package:turismup/src/pages/map/mapbox_main_map.dart';
import 'package:turismup/src/pages/map/principal_map.dart';
import 'package:turismup/src/pages/new_place_page.dart';
import 'package:turismup/src/pages/login_signup/login_email.dart';
import 'package:turismup/src/pages/login_signup/login_page.dart';
import 'package:turismup/src/pages/login_signup/new_account_page.dart';
import 'package:turismup/src/pages/one_place_page.dart';
import 'package:turismup/src/pages/one_route_page.dart';
import 'package:turismup/src/pages/settings_page.dart';
import 'package:turismup/src/providers/km_around_provider.dart';
import 'package:turismup/src/service/init_database.dart';
import 'package:turismup/src/service/network_connectivity.dart';
import 'package:turismup/src/service/offline_enqueue_service.dart';
import 'package:turismup/src/utils/AppColor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;
  var offlineEnqueueService;
  String string = '';
  Future initDatabase() async {
    await InitDatabaseSembast.initialize();
  }

  @override
  void initState() {
    () async {
      final Directory docDir = await getApplicationDocumentsDirectory();
      final String localPath = docDir.path;
      File file = File('$localPath/${'assets/ecuador.map'.split('/').last}');
      if (!file.existsSync()) {
        final imageBytes = await rootBundle.load('assets/ecuador.map');
        final buffer = imageBytes.buffer;
        await file.writeAsBytes(buffer.asUint8List(
            imageBytes.offsetInBytes, imageBytes.lengthInBytes));
      }
    }();

    InitDatabaseSembast.initialize().whenComplete(() {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return ChangeNotifierProvider(
      create: (context) => KmAroundProvider(),
      child: Consumer<KmAroundProvider>(
          builder: (context, themeProvider, child) =>
              MaterialApp(
                theme: ThemeData().copyWith(
                  scaffoldBackgroundColor: Colors.white,
                  colorScheme:
                  ThemeData().colorScheme.copyWith(
                      primary: AppColor.primaryColor),
                ),
                title: 'TurismUp App',
                initialRoute: '/',
                debugShowCheckedModeBanner: false,
                // home: HomePage());
                routes: {
                  '/': (context) => const LoginPage(),
                  '/emailLogin': (context) => const LoginEmail(),
                  '/singnup': (context) => const NewAccountPage(),
                  '/home': (context) => const HomePage(),
                  '/addPlace': (context) => const NewPlacePage(),
                  '/oneRoute': (context) => const OneRoutePage(),
                  '/onePlace': (context) => const OnePlacePage(),
                  '/settings': (context) => const SettingsPage(),
                  '/offline': (context) => principal_map(),
                  // '/mapa': (context) => MapPage(),
                  // '/mapaRutas': (context) => const MapRoutesPage(),
                },
              )
      ),

    );
  }
}
