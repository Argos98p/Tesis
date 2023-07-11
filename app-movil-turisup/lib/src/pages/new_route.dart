import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:turismup/src/model/post_new_route.dart';

import '../model/place_model.dart';
import '../model/user_data.dart';
import '../repository/place_api_repository.dart';
import '../utils/AppColor.dart';
import '../widgets/title_login_widget.dart';

class NewRoute extends StatefulWidget {
  NewRoute({Key? key,required this.recursos}) : super(key: key);

  List<PlaceModel> recursos;
  @override
  State<NewRoute> createState() => _NewRouteState();

}

class _NewRouteState extends State<NewRoute> {
  final _formKey = GlobalKey<FormState>();
  final titleCtr = TextEditingController();
  final descricionCtr = TextEditingController();
  Future? _future_save_route;
  final ApiPlaceRepository  _repository = ApiPlaceRepository();
  UserData? userData;

  @override
  void initState() {
    // TODO: implement initState
    _future_save_route=null;
    getInfo();
    super.initState();
  }
  Future getInfo() async {
    userData= await ApiPlaceRepository.getInjfoUsuario();
  }

  @override
  void dispose() {
    // TODO: implement dispose\
    _future_save_route=null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body:
      _future_save_route == null
          ?
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _titulo(),
                _nombreInput(),
                _descripcionInput(),
                SizedBox(
                  height: 50,
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() ) {
                        print(titleCtr.text);
                        print(descricionCtr.text);
                        List<String> elements = [];
                        widget.recursos.forEach((element) { elements.add(element.id!);});
                        print(elements);
                        _future_save_route=saveRoute(PostNewRoute(userId: userData!.id.toString(),nombre:titleCtr.text,descripcion:descricionCtr.text,lugares:elements));
                        //savePlace(newPlace);
                        setState(() {

                        });
                      }



                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                        shadowColor: Colors.transparent,
                        shape: StadiumBorder()),
                    child: const Text('Crear'),
                  ),
                ),
              ],
            ),
          ),

        ),
      ) : Center(
        child: FutureBuilder(
          future: _future_save_route,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data == 200) {
                Fluttertoast.showToast(msg: "Ruta guardada");
                Navigator.pop(context);
                return Text("ruta creada");

              }
              return Text("Error creando ruta");
            } else if (snapshot.connectionState== ConnectionState.waiting) {
              //Navigator.pop(context);
              return CircularProgressIndicator();
            }
            return CircularProgressIndicator();
          },

        ),

      ),
    );
  }

  Widget _titulo() {
    return Center(child: textLogin("Crea una nueva ruta"));
  }
  Widget _nombreInput() {
    return Container(
        width: MediaQuery. of(context). size. width,
        padding: EdgeInsets.all(10.0),
        child: TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo es obligatorio';
            }
            return null;
          },
          controller: titleCtr,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Nombre',
            prefixIcon: Icon(FontAwesomeIcons.placeOfWorship),
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: AppColor.textFieldBackground,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              borderSide:
              BorderSide(color: AppColor.textFieldBackground, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
            ),
          ),
        ));
  }

  Widget _descripcionInput() {
    return Container(
        width: MediaQuery. of(context). size. width,
        padding: EdgeInsets.all(10.0),
        child: TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo es obligatorio';
            }
            return null;
          },
          maxLines: 4,
          controller: descricionCtr,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Descripcion',
            prefixIcon: Icon(Icons.notes_sharp),
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: AppColor.textFieldBackground,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              borderSide:
              BorderSide(color: AppColor.textFieldBackground, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
            ),
          ),
        ));
  }

  Future<int?> saveRoute(PostNewRoute newRoute) async {
    int? result = await  _repository.createRoute(newRoute);
    return result;
  }
}
