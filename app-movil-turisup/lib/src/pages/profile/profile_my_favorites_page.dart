import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turismup/src/repository/place_api_repository.dart';

import '../../model/place_model.dart';
import '../../model/user_data.dart';

class ProfileMyFavoritesPage extends StatefulWidget {
  const ProfileMyFavoritesPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProfileMyFavoritesPage();
  }
}

class _ProfileMyFavoritesPage extends State<ProfileMyFavoritesPage> {
  TextEditingController searchInput = TextEditingController();
  ApiPlaceRepository apiPlaceRepository = ApiPlaceRepository();
  UserData? userData;
  String id = '';

  Future getInfoUser() async {
    userData = await ApiPlaceRepository.getInjfoUsuario();
    id = (userData!.id).toString();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    getInfoUser();
    super.initState();
  }

  Widget myTextField(myIcon, myController,
      {myHintText = "", myBorderRadius = 12.0}) {
    return TextField(
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

  Widget placeCardWidget(PlaceModel place, int index, List<PlaceModel> places) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/onePlace',
          arguments: {'place': place, 'index': index},
        ).then((value) {
          value as List;
          places.remove(value[0]);
          setState(() {});
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(10),
        ),
        //
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Image.network(
                place.imagenesPaths![0],
                fit: BoxFit.cover,
                height: 100,
                width: 125,
              ),
            ),
            SizedBox(
              width: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.nombre!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                        "${place.region!.nombre!} | ${place.organizacion!.nombre!}"),
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                //IconButton(onPressed: () {}, icon: Icon(Icons.favorite))
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        /*  Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: myTextField(Icons.search, searchInput,
                  myHintText: "Buscar en tus favoritos", myBorderRadius: 30.0),
            ),*/
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: FutureBuilder<List<PlaceModel>>(
            // future: apiPlaceRepository.getFavorites(userData!.id.toString()),
              future: apiPlaceRepository.getFavorites(id),
              builder: (ctx, snapshot) {
                List<PlaceModel>? places = snapshot.data;
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return const Text("Error");
                  } else if (snapshot.hasData) {
                    // return Expanded(
                    //   child: SingleChildScrollView(
                    //       child: ListView.builder(
                    return ListView.builder(
                        itemCount: places?.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return placeCardWidget(places![index], index, places);
                        });
                  }
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }),
        ),
      ],
    );
  }
}