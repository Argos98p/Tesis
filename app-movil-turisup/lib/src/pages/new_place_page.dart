import 'dart:convert';
import 'dart:io';
import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl_platform_interface/mapbox_gl_platform_interface.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart'
    as loc;
import 'package:turismup/src/model/place_model.dart';
import 'package:turismup/src/model/post_new_place_model.dart';
import 'package:turismup/src/model/tag.dart';
import 'package:turismup/src/repository/place_api_repository.dart';

import '../model/coordenadas_model.dart';
import '../model/user_data.dart';
import '../service/handle_location_permission.dart';
import '../utils/AppColor.dart';
import '../widgets/title_login_widget.dart';
import 'map/location_map_picker.dart';

class NewPlacePage extends StatefulWidget {
  const NewPlacePage({super.key});

  @override
  State<NewPlacePage> createState() => _NewPlacePage();
}

class _NewPlacePage extends State<NewPlacePage> {
  String? _currentAddress;
  Position? _currentPosition;

  final _formKey = GlobalKey<FormState>();
  final titleCtr = TextEditingController();
  final longitudCtr = TextEditingController();
  final latitudCtr = TextEditingController();
  final addressCtrCtr = TextEditingController();
  final locationCtr = TextEditingController();
  final linkCtr = TextEditingController();
  final labelCtr = TextEditingController();
  final fnCtr = TextEditingController();
  final descricionCtr = TextEditingController();
  final tagCtr = TextEditingController();

  String _title = '';
  double _longitud = 0;
  // double _longitud = -79.0725394865325;

  double _latitud = 0;

  // double _latitud = -2.872582244821001;
  List<XFile> videos = [];
  String _descricion = '';
  List<XFile> imagefiles = [];
  String pathVideo = '';
  XFile? videofiles;
  late List<String> pathsImagenes;
  final ImagePicker imgpicker = ImagePicker();
  // double distancia = 0.0;
  final myController = TextEditingController();
  Future? _future_save_place;
  bool? almostOneImage;
  List<Tag>? _tags;
  final List<Tag> _all_tags = Tag.tagList;
  final ApiPlaceRepository _repository = ApiPlaceRepository();
  Location? location;
  UserData? userData;

  @override
  void initState() {
    super.initState();
    location = Location.instance;
    getLocation();
    longitudCtr.text = _longitud.toString();
    latitudCtr.text = _latitud.toString();
    _tags = [];
    _future_save_place = null;
  }

  @override
  void dispose() {
    imagefiles.clear();
    _future_save_place = null;
    getInfoUSer();
    super.dispose();
  }

  Future<void> getInfoUSer() async {
    userData = await ApiPlaceRepository.getInjfoUsuario();
  }

  Future<void> getLocation() async {
    location?.getLocation().then((value) {
      _latitud = value.longitude!;
      _longitud = value.latitude!;
      print(_latitud);
      print(_longitud);
      longitudCtr.text = value.longitude.toString();
      latitudCtr.text = value.latitude.toString();
    });
  }

  set_latLng(LatLng point) {
    print(point);
    longitudCtr.text = point.longitude.toString();
    latitudCtr.text = point.latitude.toString();
    setState(() {});
  }

  Future<void> _getCurrentPosition(BuildContext context) async {
    print("entra aqui");
    final hasPermission = await handleLocationPermission(context);
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(
            desiredAccuracy: loc.LocationAccuracy.high)
        .then((Position position) {
      longitudCtr.text = position.longitude.toString();
      latitudCtr.text = position.latitude.toString();
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.myBackgroundColor,
      appBar: AppBar(
        foregroundColor: AppColor.myTextColor,
        backgroundColor: AppColor.myBackgroundColor,
        shadowColor: Colors.transparent,
        title: const Text(
          'nuevo',
          style: TextStyle(color: AppColor.myTextColor),
        ),
        actions: const [
          Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
        ],
      ),
      body: _future_save_place == null
          ? Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 20.0),
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  _titulo(),
                  const SizedBox(
                    height: 20,
                  ),
                  _nombreInput(),
                  _descripcionInput(),
                  _tagsInput(),
                  SizedBox(
                    height: 220,
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: Column(children: [
                            Flexible(flex: 2, child: _latitudInput()),
                            Flexible(flex: 2, child: _longitudInput()),
                          ]),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              onPressed: () {
                                //getLocation();
                                _getCurrentPosition(context);
                              },
                              icon: const Icon(
                                  FontAwesomeIcons.locationCrosshairs),
                              color: AppColor.primaryColor,
                            ),
                            IconButton(
                               onPressed: () {

                             Navigator.push(
                               context,
                               MaterialPageRoute(builder: (context) =>  LocationMapPicker(set_latLng)),
                             );
                                 // _showAlertDialog();
                               },
                               icon: const Icon(FontAwesomeIcons.mapLocationDot),
                               color: AppColor.primaryColor,
                             )
                          ],
                        )
                      ],
                    ),
                  ),
                  _divider(),
                  _cargarImagenInput(),
                  // _divider(),
                  //_cargarVideosInput(),
                  _divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 60,
                        width: 125,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primaryColorOpacity,
                              shadowColor: Colors.transparent,
                              shape: StadiumBorder()),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Color(0xFF3062C9)),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 40,
                      ),
                      SizedBox(
                        height: 60,
                        width: 125,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (pathVideo != '') {
                              pathsImagenes.add(pathVideo);
                            }
                            if (_formKey.currentState!.validate()) {
                              if (almostOneImage != null ||
                                  almostOneImage == true) {
                                _title = titleCtr.text;
                                _longitud = double.parse(longitudCtr.text);
                                _latitud = double.parse(latitudCtr.text);
                                _descricion = descricionCtr.text;

                                UserData user =
                                    await ApiPlaceRepository.getInjfoUsuario();
                                PostNewPlaceModel newPlace = PostNewPlaceModel(
                                  nombre: _title,
                                  coordenadas: Coordenadas.fromJson({
                                    "latitud": _latitud,
                                    "longitud": _longitud
                                  }),
                                  descripcion: _descricion,
                                  imagesPaths: pathsImagenes,
                                  userId: user!.id.toString(),
                                  categoria: tagCtr.text,
                                );
                                _future_save_place = savePlace(newPlace);
                                //savePlace(newPlace);
                                setState(() {});
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                              shadowColor: Colors.transparent,
                              shape: StadiumBorder()),
                          child: const Text('Enviar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : Center(
              child: FutureBuilder(
                future: _future_save_place,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    print(snapshot.data);
                    if (snapshot.data == 200) {
                      return _successPost(snapshot);
                    }
                    return _errroInPost(snapshot);
                  } else if (snapshot.hasError) {
                    //Navigator.pop(context);
                    return _errroInPost(snapshot);
                  }
                  return _processPost(snapshot);
                },
              ),
            ),
    );
  }

  void openFilterDialog() async {
    await FilterListDialog.display<Tag>(
      context,
      themeData: FilterListThemeData(context,
          choiceChipTheme: const ChoiceChipThemeData(
              selectedBackgroundColor: AppColor.primaryColor),
          controlButtonBarTheme: ControlButtonBarThemeData(context,
              controlButtonTheme: const ControlButtonThemeData(
                  primaryButtonBackgroundColor: AppColor.primaryColor))),
      listData: _all_tags,
      selectedListData: _tags,
      choiceChipLabel: (tag) => tag!.nombre,
      validateSelectedItem: (list, val) => list!.contains(val),
      onItemSearch: (tag, query) {
        return tag.nombre.toLowerCase().contains(query.toLowerCase());
      },
      enableOnlySingleSelection: true,
      applyButtonText: "Ok",
      onApplyButtonClick: (list) {
        setState(() {
          _tags = List.from(list!);
          tagCtr.text =
              _tags!.map((c) => c.nombre.toLowerCase()).toList().join(', ');
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _processPost(snapshot) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Espera porfavor estamos creando tu recurso...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Lottie.asset('assets/lottie_animations/loadMap.json'),
      ],
    );
  }

  Widget _successPost(snapshot) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Recurso creado',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Lottie.asset('assets/lottie_animations/CHECK.json'),
      ],
    );
  }

  Widget _errroInPost(snapshot) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Error en creando el recurso... ${snapshot.data.toString()}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Lottie.asset('assets/lottie_animations/error.json'),
      ],
    );
  }

  Widget _titulo() {
    return Center(child: textLogin("Añade tu propio lugar"));
  }

  Widget _tagsInput() {
    return InkWell(
      onTap: () {
        openFilterDialog();
      },
      child: Container(
          width: 320,
          padding: EdgeInsets.all(10.0),
          child: IgnorePointer(
            child: TextField(
              controller: tagCtr,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Tags',
                prefixIcon: Icon(FontAwesomeIcons.tag),
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
                  borderSide:
                      BorderSide(color: AppColor.primaryColor, width: 2),
                ),
              ),
            ),
          )),
    );
  }

  Widget _divider() {
    return (const Divider(
      height: 30,
      indent: 12,
      endIndent: 12,
    ));
  }

  Widget _nombreInput() {
    return Container(
        width: 320,
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
        width: 320,
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

  Widget _longitudInput() {
    return Container(
        width: 320,
        padding: EdgeInsets.all(10.0),
        child: TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Valor de longitud no valido';
            }
            if (double.parse(value) > 180.0 || double.parse(value) < -180.0) {
              return "El valor debe estar entre [-180, 180]";
            }

            return null;
          },
          controller: longitudCtr,
          keyboardType: TextInputType.number,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Longitud',
            helperText: "Longitud",
            prefixIcon: Icon(FontAwesomeIcons.locationDot),
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

  Widget _latitudInput() {
    return Container(
        width: 320,
        padding: EdgeInsets.all(10.0),
        child: TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Valor de latitud no valida';
            }
            if (double.parse(value) > 90.0 || double.parse(value) < -90.0) {
              return "El valor debe estar entre [-90, 90]";
            }
            return null;
          },
          controller: latitudCtr,
          keyboardType: TextInputType.number,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            helperText: "Latitud",
            hintText: 'Latitud',
            prefixIcon: Icon(FontAwesomeIcons.locationDot),
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

  List<String> convertirXFileAString(List<XFile> imageFiles) {
    List<String> stringList = [];
    for (int i = 0; i < imageFiles.length; i++) {
      stringList.add(imageFiles[i].path);
    }
    return stringList;
  }

  openVideo() async {
    if (videos.isNotEmpty) {
      if (pathsImagenes.contains(pathVideo)) {
        pathsImagenes.remove(pathVideo);
      }
      videos = [];
    }
    try {
      var pickedFileVideo =
          await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (pickedFileVideo != null) {
        setState(() {
          XFile videofiles = pickedFileVideo;
          // imagefiles.add(videofiles);
          videos.add(videofiles);
          pathVideo = videofiles.path;
        });
      } else {
        print('no se selecciono ningun video');
        setState(() {});
      }
    } catch (e) {
      // setState(() {});
      print('error');
    }
  }

  openImages() async {
    try {
      var pickedfiles = await imgpicker.pickMultiImage();
      //you can use ImageCourse.camera for Camera capture
      if (pickedfiles != null) {
        imagefiles = pickedfiles;
        pathsImagenes = convertirXFileAString(imagefiles);
        almostOneImage = true;

        setState(() {});
      } else {
        print("No image is selected.");
        setState(() {});
      }
    } catch (e) {
      print("error while picking file.");
    }
  }

  Widget _cargarImagenInput() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
      // height: 200,
      width: 200,
      child: Column(
        children: <Widget>[
          // ignore: prefer_const_constructors
          Text(
            'Imagenes del recurso',
            textAlign: TextAlign.left,
            style: const TextStyle(
                color: AppColor.myTextColor,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: Column(
              children: <Widget>[
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6086d6),
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: () {
                      openImages();
                    },
                    icon: Icon(Icons.add_a_photo_outlined),
                    label: Text("Agregar fotos")),
                // Text('Buscar Imagen'),
                almostOneImage == false || almostOneImage == null
                    ? const Text(
                        "Seleciona almenos una imagen",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      )
                    : const SizedBox(),
                imagefiles.isNotEmpty
                    ? Container(
                        width: 200,
                        height: 20,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 10, bottom: 0),
                        child: const Text(
                          "Imagenes Seleccionadas",
                          style: TextStyle(
                              fontSize: 14.0, color: AppColor.primaryColor),
                        ),
                      )
                    : const SizedBox(),
                imagefiles != null
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: imagefiles.map((imageone) {
                            return Container(
                                child: Card(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    imagefiles.remove(imageone);
                                    print(imagefiles);
                                    if (imagefiles.isEmpty) {
                                      almostOneImage = false;
                                    } else {
                                      almostOneImage = true;
                                    }
                                  });
                                },
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  child: Image.file(File(imageone.path)),
                                ),
                              ),
                            ));
                          }).toList(),
                        ),
                      )
                    : Container(),
                const Divider(),
                const SizedBox(
                  height: 20,
                ),
                _cargarVideosInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cargarVideosInput() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
      // height: 200,
      width: 200,
      child: Column(
        children: <Widget>[
          // ignore: prefer_const_constructors
          Text(
            'Video del recurso',
            textAlign: TextAlign.left,
            style: const TextStyle(
                color: AppColor.myTextColor,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            child: Column(
              children: <Widget>[
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6086d6),
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: () {
                      openVideo();
                    },
                    icon: const Icon(Icons.video_file_outlined),
                    label: const Text("Agregar videos")),
                pathVideo != ''
                    ? Container(
                        width: 200,
                        height: 20,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 10, bottom: 0),
                        child: const Text(
                          "Video seleccionado",
                          style: TextStyle(
                              fontSize: 14.0, color: AppColor.primaryColor),
                        ),
                      )
                    : SizedBox(),
                pathVideo != ''
                    ? Center(
                        child: Text(pathVideo),
                      )
                    : Container()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<int> savePlace(PostNewPlaceModel newPlace) async {
    int result = await _repository.insertPlace(newPlace);
    return result;
  }
}
