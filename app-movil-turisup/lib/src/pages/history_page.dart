import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:turismup/src/model/history_model.dart';
import 'package:turismup/src/repository/place_api_repository.dart';
import 'package:turismup/src/widgets/title_widget.dart';

import '../model/place_model.dart';
import '../utils/AppColor.dart';
import 'map/route_map_multiple_places.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
// TODO: implement your code here
  }
  DateTime? initDate;
  DateTime? endDate;
  bool selectedDate = false;
  String dateInContainer = "Ingrese el rango de fechas";
  ApiPlaceRepository apiPlaceRepository = ApiPlaceRepository();
  Future? getHistoryUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mi historial"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Busca tus historial mendiante una fecha o un rango de fechas",
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(
              height: 15,
            ),
            Ink(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: AppColor.textFieldBackground,
                  borderRadius: BorderRadius.circular(13)),
              child: InkWell(
                onTap: () {
                  showDialog<Widget>(
                      context: context,
                      builder: (BuildContext context) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical:
                                  MediaQuery.of(context).size.width * 0.4),
                          child: SfDateRangePicker(
                            maxDate: DateTime.now(),
                            onSelectionChanged: _onSelectionChanged,
                            selectionMode: DateRangePickerSelectionMode.range,
                            backgroundColor: Colors.white,
                            showActionButtons: true,
                            onSubmit: (dynamic value) {
                              Navigator.pop(context);
                              value as PickerDateRange;
                              setState(() {
                                initDate = value.startDate;
                                selectedDate = true;
                                endDate = value.endDate;
                                if(value.endDate==null){
                                  endDate=initDate;
                                }
                                if (endDate == initDate || endDate==null) {
                                  dateInContainer =
                                      "${initDate!.day}/${initDate!.month}/${initDate!.year} ";
                                } else {
                                  dateInContainer =
                                      "${initDate!.day}/${initDate!.month}/${initDate!.year} - ${endDate!.day}/${endDate!.month}/${endDate!.year}";
                                }
                              });
                              print("star date${value.startDate}");
                              print("end date ${value.endDate}");
                            },
                            onCancel: () {
                              Navigator.pop(context);
                            },
                          ),
                        );
                      });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        dateInContainer,
                        style: TextStyle(
                            fontSize: 15,
                            color: selectedDate
                                ? AppColor.primaryColor
                                : AppColor.greyDisable),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: 60,
                    width: 125,
                    child: ElevatedButton(
                      onPressed: ()  {
                        if(selectedDate){
                          print(initDate);
                          print(endDate);
                          getHistoryUser = apiPlaceRepository.getHistoryModel(initDate!, endDate!);
                        }else{
                          Fluttertoast.showToast(msg: "Ingrese una fecha o un rango de fechas");
                        }
                        setState(() {
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          shadowColor: Colors.transparent,
                          shape: StadiumBorder()),
                      child: const Text('Buscar'),
                    )),
              ],
            ),
            getHistoryUser ==null? SizedBox() :
            SingleChildScrollView(

              child: FutureBuilder<List<HistoryModel>>(
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {

                    if(snapshot.data!.isNotEmpty){
                      print(snapshot.data);
                      List<HistoryModel> elements = snapshot!.data!;
                      return Column(
                        children: [
                          ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,

                            itemBuilder: (context, index) {
                              List<HistoryModel> elements = snapshot!.data!;
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Ink(

                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColor.primaryColorOpacity,
                                  ),
                                  height: 80,
                                  width: MediaQuery.of(context).size.width,
                                  child: InkWell(
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: Image.network(elements[index].place!.imagenesPaths![0], height: 65, width: 80,fit: BoxFit.cover,)
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            AutoSizeText("Visitaste ${elements[index]!.place!.nombre}", maxLines: 2,),
                                            AutoSizeText(" \"${elements[index].contenido}\"", style: TextStyle(fontStyle: FontStyle.italic, color: AppColor.greyDisable),maxLines: 1,),
                                            AutoSizeText("${elements[index].date}", style: TextStyle(color: AppColor.primaryColor),)
                                          ],
                                        )


                                        //Text("Comentaste un sitio ${elements[index]!.place!.nombre}")
                                      ],
                                    ),
                                  ) ,
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 20,),

                          SizedBox(
                              height: 60,
                              width: 325,
                              child: ElevatedButton(

                                onPressed: ()  {

                                  List<PlaceModel> places = [];
                                  elements.forEach((element) {
                                    places.add(element.place!);
                                  });

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RouteMapMultiplePlaces(
                                            recursos: places,
                                          )));

                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.primaryColor,
                                    shadowColor: Colors.transparent,
                                    shape: StadiumBorder()),
                                child: const Text('Generar ruta apartir de estos recursos'),
                              ))
                        ],
                      );
                    }else{
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Text("No se encontró interacciones en las fechas establecidas"),
                      );
                    }



                  } else if (snapshot.hasError) {
                    return Text("error");
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                future: apiPlaceRepository.getHistoryModel(
                    initDate!, endDate!),
              ),


            )
          ],
        ),
      ),
    );
  }
}
