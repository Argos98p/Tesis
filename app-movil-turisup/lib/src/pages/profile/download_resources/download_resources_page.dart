import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:turismup/src/repository/place_repository.dart';
import 'package:turismup/src/utils/AppColor.dart';

import '../../../model/place_model.dart';
import '../../../repository/place_api_repository.dart';
import 'download_resources_page_logic.dart';
class DownloadReourcesPage extends StatefulWidget {
  const DownloadReourcesPage({Key? key}) : super(key: key);

  @override
  State<DownloadReourcesPage> createState() => _DownloadReourcesPageState();
}

class _DownloadReourcesPageState extends State<DownloadReourcesPage> {




  Future<List<PlaceModel>>? placesFuture;

  final downloadManager = DownloadResourcesPageManager();
  //bool _placesIsInDB = false;
  var _placesInStorage = OfflinePlacesStatus.checking;
  bool _myRoutesInDB =false;
  bool _officialRoutesInDB = false;


  String? fileName;
  String imageData = '';
  bool dataLoaded = false;
  late double _progressValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadManager.check();
    //_checkPlacesInDatabase();
  }

  Widget myIcon(IconData myIcon){
    return Container(
      decoration:  const BoxDecoration(
        color: AppColor.primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      height: 60,
      width: 60,
      child: Icon(myIcon, color: Colors.white,),
    );
  }

  Widget myObjectDownloadContainer(IconData myIconData, String mensaje,myFunction){
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: InkWell(
        onTap: (){
          myFunction();
        },
        child: Ink(
          decoration: const BoxDecoration(
            color: AppColor.primaryColorOpacity,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),

          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              myIcon(myIconData),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(mensaje, style: const TextStyle(fontSize: 16),),
                    ),

                    ValueListenableBuilder<PlacesOfflineState?>(
                      valueListenable: downloadManager.placesStateNotifier,
                      builder: (context, status, child) {
                        if (status == PlacesOfflineState.checking){
                          return  const CircularProgressIndicator( );
                        }
                        else if((status == PlacesOfflineState.saved)){
                          return const Icon(Icons.check,size: 30,color: AppColor.primaryColor,);
                        }else {
                          return const Icon(Icons.download_rounded,size: 30,color: AppColor.primaryColor,);
                        }


                      },
                    )

                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        myObjectDownloadContainer(
            FontAwesomeIcons.locationDot, "Decargar lugares",()=>placesOfflineFunction(context)),
       /* myObjectDownloadContainer(
            FontAwesomeIcons.route, "Decargar rutas oficiales",_officialRoutesInDB,officialRoutesOfflineFunction),
        myObjectDownloadContainer(
            FontAwesomeIcons.user, "Decargar mis rutas", _myRoutesInDB,myRoutesOfflineFunction),*/
      ],
    );
  }



void savePlaces(){
  downloadManager.download();
  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(

        title: Text("Descargando archivos"),
        content:  ValueListenableBuilder<double?>(
          valueListenable: downloadManager.progressNotifier,
          builder: (context, percentage, child) {
            print(percentage);
            if(percentage==1){
              Navigator.pop(context);
              Fluttertoast.showToast(msg: "Recursos turisticos guardados");
            }
            return  LinearProgressIndicator(
              backgroundColor: AppColor.primaryColorOpacity,
              color: AppColor.primaryColor,
              minHeight: 15,
              value: percentage,
            );
          },
        ),

      );
    },
  );

}

  placesOfflineFunction(context){
    if(downloadManager.placesStateNotifier.value == PlacesOfflineState.saved){
      showAlertDialog(context);
    }if(downloadManager.placesStateNotifier.value == PlacesOfflineState.notSaved){
      savePlaces();

    }
    else{

    }
  }

  /*
  showAlertDialogProgress(context){

    Widget OkButton = TextButton(
      child: Text("Actualizar"),
      onPressed:  () {
        //
        Navigator.pop(context);
      },
    );
    AlertDialog alert = const AlertDialog(
      title: Text("Descargando..."),
      content: LinearProgressIndicator(
        backgroundColor: AppColor.primaryColorOpacity,
        color: AppColor.primaryColor,
        minHeight: 15,
        //value: _progressValue,
      ),

    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    //_savePlaces();
  }

*/

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget remindButton = TextButton(
      child: Text("Borrar datos"),
      onPressed:  () {
        //_deleteAllPlaces();
        downloadManager.deleteSavedPlaces();
        Navigator.pop(context);
      },
    );
    Widget cancelButton = TextButton(
      child: Text("Cancelar"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget launchButton = TextButton(
      child: Text("Actualizar"),
      onPressed:  () {

        Navigator.pop(context);
        savePlaces();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Notice"),
      content: Text("Los recursos ya se encuentran descargados en el telefono que desea hacer?"),
      actions: [
        remindButton,
        cancelButton,
        launchButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}

enum OfflinePlacesStatus { checking, saved, notSaved  }
