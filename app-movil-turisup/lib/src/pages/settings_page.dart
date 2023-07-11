import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turismup/src/pages/history_page.dart';
import 'package:turismup/src/providers/km_around_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/AppColor.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double? dropdownvalue;
  Map<String, double> kmAlrededor = {
    '0.5 km': 0.5,
    '1 km': 1,
    '5 km': 5,
    '10 km': 10,
    '20 km': 20,
    '30 km': 30,
    '50 km': 50,
    '+50 km': 1000
  };

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('km_around')) {
      dropdownvalue = prefs.getDouble('km_around')!;
      setState(() {});
    } else {
      prefs.setDouble('km_around', 50.0);
      dropdownvalue = 50.0;
      setState(() {});
    }
  }

  @override
  void initState() {
    getSharedPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: Colors.black,
        shadowColor: Colors.transparent,
        actions: [],
        title: const Text(
          'Configuraciones',
          style: TextStyle(color: AppColor.myTextColor),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recurso",
              style: TextStyle(
                  color: AppColor.primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Mostar en un radio de",
                  style: TextStyle(fontSize: 16),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 14),
                  decoration: BoxDecoration(
                      color: AppColor.primaryColorOpacity,
                      borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<double>(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: kmAlrededor
                          .map((key, value) {
                            return MapEntry(
                                key,
                                DropdownMenuItem<double>(
                                  value: value,
                                  child: Text(key),
                                ));
                          })
                          .values
                          .toList(),
                      value: dropdownvalue,
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            dropdownvalue = newValue;
                            print(dropdownvalue);
                            setKmAround(newValue);
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              "Historial",
              style: TextStyle(
                  color: AppColor.primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryPage()));
              },
              child: SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child:  Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:  [
                      Text("Mira tu historial de rutas",
                          style: TextStyle(fontSize: 15)),
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(FontAwesomeIcons.timeline),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const Text(
              "Pagina de administración",
              style: TextStyle(
                  color: AppColor.primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            InkWell(
              child: Container(
                width: double.infinity,
                height: 70,
                child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Presiona para ver el panel de admin')),
              ),
              onTap: () => launch("http://34.71.215.168:3000/",forceWebView: true, enableJavaScript: true, enableDomStorage: true),
            )
          ],
        ),
      ),
    );
  }

  setKmAround(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('km_around', value);
    KmAroundProvider themeProvider = Provider.of<KmAroundProvider>(context, listen: false);
    themeProvider.newValueKmAround(value);
  }
}
