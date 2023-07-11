 import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:turismup/src/pages/map/principal_map.dart';
import 'package:turismup/src/pages/offline_main_pages/offline_explore_page.dart';
import 'package:turismup/src/pages/offline_main_pages/offline_official_routes_page.dart';
import 'package:turismup/src/pages/offline_main_pages/offline_profile_page.dart';
import 'package:turismup/src/pages/profile/profile_page.dart';
import 'package:turismup/src/service/init_database.dart';
import '../service/network_connectivity.dart';
import '../service/offline_enqueue_service.dart';
import 'explore/explorer_page.dart';
import 'map/FlutterMap.dart';
import 'map/mapbox_main_map.dart';
import 'navigation_bar/bottom_navigation.dart';
import 'official_routes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;
  final List<Widget> _onlinePages = [const ExplorerPage(isOffline: false,),principal_map() /*const MapBoxMainMap()OfflineMapPage()*/ ,const OfficialRoutesPage(), const ProfilePage()];
  final List<Widget> _offlinePages = [const OfflineExplorePage() ,principal_map() /*const MapBoxMainMap()  *//*MapWidget()*/,const OfflineOfficialRoutesPage(), const OfflineProfilePage()];
  String string = '';
  int index = 0;
  BtnNavigation? myBnb;
  late List<Widget> _currentPages=_onlinePages;

  var offlineEnqueueService ;


  @override
  void initState() {
    offlineEnqueueService = OfflineEnqueueService();
    _networkConnectivity.initialise();

    _networkConnectivity.myStream.listen((source) {
      print("object");

      var _source= source;
      if(_source.keys.toList()[0] == ConnectivityResult.mobile || _source.keys.toList()[0] ==  ConnectivityResult.wifi){


        if(string =="en linea"){
        setState(() {

        });
        }else{

          setState(() {

            string = "en linea";
            offlineEnqueueService.startService();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  string,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
            _currentPages= _onlinePages;
          });
        }


      }
      if(_source.keys.toList()[0] == ConnectivityResult.none ){
        string = "fuera de linea";
        _currentPages= _offlinePages;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              string,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      }


    });
    //initDatabase();
    myBnb = BtnNavigation(currentIndex: (i) {
      setState(() {

        index = i;
      });
    });
    // TODO: implement initState
    super.initState();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    _networkConnectivity.disposeStream();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Scaffold(
        bottomNavigationBar: myBnb,
        body:  IndexedStack(
            index: index,
            children: _currentPages)
        /*
        FutureBuilder(
          future: _init,
          builder: (context, snapshot){
            if(snapshot.connectionState== ConnectionState.done){
              return
            }else{
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        )*/



    );
  }
}
