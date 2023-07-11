import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:readmore/readmore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'
    as htmlVideo;
import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:turismup/src/model/place_model.dart';
import 'package:turismup/src/model/post_new_comment_model.dart';
import 'package:turismup/src/utils/AppColor.dart';

import '../controller/mapController.dart';
import '../model/datos_comment.dart';
import '../model/user_data.dart';
import '../providers/custom_image_provider.dart';
import '../repository/place_api_repository.dart';
import '../service/connectivity_utils.dart';
import '../widgets/widget_list_images.dart';
import 'coments/coments.dart';
import 'one_place_images.dart';

class OnePlacePage extends StatefulWidget {
  const OnePlacePage({Key? key}) : super(key: key);

  @override
  State<OnePlacePage> createState() => _OnePlacePageState();
}

class _OnePlacePageState extends State<OnePlacePage> {
  Set<Marker> _markers = <Marker>{};
  final ApiPlaceRepository _placeRepository = ApiPlaceRepository();
  final ApiPlaceRepository _repository = ApiPlaceRepository();
  final ScrollController _scrollController = ScrollController();
  List<Datos_Comment> comentarios = [];
  bool offline = false;
  int numOpiniones = 0;
  PlaceModel? place;
  int? index;
  UserData? userData;
  String id = '';
  String pathVideo = '';
  List<XFile> videos = [];
  XFile? videofiles;
  double _scrollPosition = 0;
  _scrollListener() {
    setState(() {
      _scrollPosition = _scrollController.position.pixels;
    });
  }

  Future _getInfoUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? idAux = prefs.getInt('userId');
    print('+++');
    print(idAux);
    userData = await ApiPlaceRepository.getInjfoUsuario();
    setState(() {
      // id = idAux.toString();
      print('++++++++++++++++++++++++++++++++++');
      // print(id);
    });
  }

  @override
  void initState() {
    () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? idAux = prefs.getInt('userId');
      id = idAux.toString();
    }();

    _getInfoUser();
    //_scrollController.addListener(_scrollListener);
    Future.delayed(Duration.zero, () {
      final arguments = (ModalRoute.of(context)?.settings.arguments ??
          <String, dynamic>{}) as Map;
      place = arguments['place'];
      index = arguments['index'];
      if (arguments['offline'] != null) {
        offline = true;
      }
      cargarComentarios();
    });
    super.initState();
  }

  Future cargarComentarios() async {
    comentarios = await apiPlaceRepository.getComments(place!.id!);
    numOpiniones = comentarios.length;
    setState(() {});
  }

  final ImagePicker imgpicker = ImagePicker();
  List<XFile>? imagefiles;
  Future<int>? _futureNewComment;
  TextEditingController commentController = TextEditingController();
  int rate = 3;
  int activeIndex = 0;
  ApiPlaceRepository apiPlaceRepository = ApiPlaceRepository();

  // Future getInfoUser() async {
  //   userData = await ApiPlaceRepository.getInjfoUsuario();
  // }

  openImages(mySetState) async {
    try {
      var pickedfiles = await imgpicker.pickMultiImage();
      //you can use ImageCourse.camera for Camera capture
      if (pickedfiles != null) {
        imagefiles = pickedfiles;
        mySetState(() {});
      } else {
        print("No image is selected.");
      }
    } catch (e) {
      print("error while picking file.");
    }
  }

  Widget _carrucel(List paths, bool isOffline) {
    return SizedBox(
      // height: MediaQuery.of(context).size.height,
      width: double.infinity,
      height: 250,

      child: Stack(
        alignment: Alignment.center,
        children: [
          CarouselSlider.builder(
              onSlideChanged: (value) {},
              slideBuilder: (index) {
                return InkWell(
                  onTap: () {
                    CustomImageProvider customImageProvider =
                        CustomImageProvider(
                            imageUrls: List<String>.from(paths),
                            initialIndex: 0);
                    if (!isOffline) {
                      showImageViewerPager(context, customImageProvider,
                          swipeDismissible: true, onPageChanged: (page) {
                        setState(() {
                          activeIndex = page;
                          print(activeIndex);
                        });
                      }, onViewerDismissed: (page) {
                        // print("Dismissed while on page $page");
                      });
                    }
                  },
                  child: isOffline
                      ? Image.file(
                          File(paths[index]),
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          paths[index],
                          fit: BoxFit.cover,
                        ),
                );
              },
              slideIndicator: CircularWaveSlideIndicator(
                indicatorBackgroundColor: Colors.grey[350]!,
                currentIndicatorColor: Colors.blue[600]!,
                padding: const EdgeInsets.only(bottom: 15),
              ),
              itemCount: (paths.length)),
          /*Positioned(
            bottom: 10,
            child: AnimatedSmoothIndicator(
              activeIndex: activeIndex,
              count: paths.length,
              effect: const ExpandingDotsEffect(
                  spacing: 8.0,
                  radius: 4.0,
                  dotWidth: 20.0,
                  dotHeight: 8.0,
                  //paintStyle:  PaintingStyle.stroke,
                  strokeWidth: 1.5,
                  dotColor: AppColor.greyDisable,
                  activeDotColor: AppColor.primaryColor),
            ),
          ),*/
        ],
      ),
    );
  }

  Widget tituloInicio(String nombre) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0)),
    );
  }

  Widget divider() {
    return const Divider(
      height: 30,
      thickness: 1,
      color: AppColor.dividerColor,
    );
  }

  Widget etiquetas(PlaceModel place) {
    return Row(
      children: <Widget>[
        Container(
          width: 100,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppColor.primaryColorOpacity,
              borderRadius: BorderRadius.circular(10)),
          child: const Text('Sin etiqueta',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10.0,
                  color: Colors.blue)),
        ),
        Container(
          margin: const EdgeInsets.only(left: 25, right: 20),
          child: const Icon(
            Icons.star,
            color: Colors.yellow,
          ),
        ),
        place.rate! < 6
            ? Text(
                '${place!.rate!}  (${numOpiniones} Opiniones)',
                style: TextStyle(fontWeight: FontWeight.w500),
              )
            : const Text(
                ' sin comentarios',
                style: TextStyle(fontWeight: FontWeight.w500),
              )
      ],
    );
  }

  Widget organizacionRedes(List paths, String organizacion) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            FutureBuilder<bool>(
              future: ConnectivityUtils.hasConnection(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data!) {
                    return CircleAvatar(
                      backgroundImage: NetworkImage(paths[0]),
                      radius: 30,
                    );
                  } else {
                    return const CircleAvatar(
                      backgroundImage: AssetImage("assets/imageNotFound.jpg"),
                      radius: 30,
                    );
                  }
                }
                return const Text("error");
              },
            ),
            // ignore: prefer_const_constructors

            const SizedBox(
              width: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Promocionado por:',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 12.0,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  '$organizacion',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
              ],
            ),
          ],
        ),
        const Icon(
          color: Colors.pink,
          FontAwesomeIcons.instagram,
          size: 55,
        )
      ],
    );
  }

  Widget tituloDescripcion() {
    return Container(
      alignment: Alignment.centerLeft,
      child: const Text(
        'Descripción',
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget descricion(String descripcion) {
    return Container(
      alignment: Alignment.centerLeft,
      child: ReadMoreText('$descripcion',
          colorClickableText: Colors.blue[300],
          trimMode: TrimMode.Line,
          trimLines: 4,
          trimCollapsedText: 'Leer mas',
          trimExpandedText: 'Leer menos',
          style: const TextStyle(fontSize: 16.0)),
    );
  }

  List<String> imagenesComentarios() {
    List<String> listImagenes = [];
    for (int i = 0; i < comentarios.length; i++) {
      List<dynamic>? imagenes = comentarios[i].imagenes;
      if (imagenes != null) {
        listImagenes.addAll(imagenes.cast<String>());
      }
    }
    return listImagenes;
  }

  Widget tituloFotos2() {
    // List<String> imageUrls = [
    //   'https://empresas.blogthinkbig.com/wp-content/uploads/2019/11/Imagen3-245003649.jpg?w=800',
    //   'https://i.blogs.es/ceda9c/dalle/1366_2000.jpg',
    //   'https://www.iebschool.com/blog/wp-content/uploads/2022/11/image-51.png',
    //   'https://ep01.epimg.net/elpais/imagenes/2019/10/30/album/1572424649_614672_1572453030_noticia_normal.jpg',
    //   'https://previews.123rf.com/images/aprillrain/aprillrain2209/aprillrain220900194/191556087-imagen-abstracta-de-los-cielos-abiertos-el-camino-el-camino-al-cielo-ilustraci%C3%B3n-de-alta-calidad.jpg'
    // ];

    List<String> imageUrls = imagenesComentarios();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: const Text(
            'Fotos del lugar',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageViewer(imageUrls: imageUrls),
              ),
            );
          },
          child: const Text(
            'Fotos comentarios',
            style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }

  Widget tituloVideos() {
    return Container(
      alignment: Alignment.centerLeft,
      child: const Text(
        'Videos del lugar',
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget tituloFotosComentario() {
    return Container(
      alignment: Alignment.centerLeft,
      child: const Text(
        'Fotos del comentario del lugar',
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget tituloVideosComentario() {
    return Container(
      alignment: Alignment.centerLeft,
      child: const Text(
        'Videos del comentario del lugar',
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget tituloLocacion() {
    return Container(
      alignment: Alignment.centerLeft,
      child: const Text(
        'Locación',
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget locacion(double latitud, double longitud, List paths, String nombre) {
    final _controller = MapController();
    LatLng location = LatLng(longitud, latitud);
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Align(
            alignment: Alignment.bottomRight,
            heightFactor: 0.9,
            widthFactor: 2.5,
            child: Container(
                margin: const EdgeInsets.only(top: 15),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                height: 200,
                // ignore: prefer_const_constructors
                child: GoogleMap(
                  myLocationEnabled: true,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  zoomGesturesEnabled: true,
                  onMapCreated: (mapController) {
                    _controller.onMapCreated(mapController);
                  },
                  initialCameraPosition: CameraPosition(
                    // target: LatLng(-2.897541, -79.005064),
                    target: location,
                    zoom: 10,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('1'),
                      position: LatLng(longitud, latitud),
                      infoWindow: InfoWindow(title: nombre),
                    ),
                  },
                ))),
      ),
    );
  }

  Widget tituloOpiniones() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 10),
      child: const Text(
        'Opiniones',
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget tituloOpininar() {
    return Container(
      alignment: Alignment.centerLeft,
      child: const Text(
        'Calificar y opinar',
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget opinar(String paths, context, place) {
    return InkWell(
      child: Container(
        width: double.infinity,
        height: 120,
        margin: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: const Text('Comparte tu experiencia a otros'),
            ),
            // ignore: prefer_const_constructors
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  // ignore: prefer_const_constructors

                  child: offline
                      ? CircleAvatar(
                          backgroundImage:
                              AssetImage("assets/images/user-profile.png"),
                          radius: 30,
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(paths),
                          radius: 30,
                        ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 0, left: 0, bottom: 0),
                  child: RatingBar.builder(
                    unratedColor: AppColor.unratedStarColor,
                    initialRating: 3,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 30,
                    itemPadding: const EdgeInsets.only(right: 10),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: AppColor.ratedStarColor,
                    ),
                    ignoreGestures: true,
                    onRatingUpdate: (rating) {
                      print(rating);
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        commentController.text = "";
        imagefiles = [];
        videos = [];
        pathVideo = '';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showModalBottomSheet(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(40)),
              ),
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                    builder: (BuildContext context, mySetState) {
                  return SingleChildScrollView(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(40),
                            topLeft: Radius.circular(40)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Center(
                          child: (_futureNewComment == null)
                              ? Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      "Deja un Comentario",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Text(
                                        '¿Como fue tu experiencia en ${place.nombre}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    RatingBar.builder(
                                      unratedColor: Color(0xFF7580D0FF),
                                      initialRating: 3,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: false,
                                      itemCount: 5,
                                      itemPadding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.indigoAccent,
                                      ),
                                      onRatingUpdate: (rating) {
                                        rate = rating.round();
                                        mySetState(() {});
                                      },
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Divider(),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    TextField(
                                      controller: commentController,
                                      onChanged: (_) => mySetState(() {}),
                                      keyboardType: TextInputType.multiline,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          filled: true,
                                          hintStyle: const TextStyle(
                                              color: Color(0xFFC8BEBE)),
                                          hintText: "Tu comentario aqui",
                                          fillColor: Color(0xFFFAFAFA)),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF6086d6),
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                        onPressed: () {
                                          openImages(mySetState);
                                        },
                                        icon: Icon(Icons.add_a_photo_outlined),
                                        label: Text("Agregar fotos")),
                                    imagefiles != null
                                        ? Wrap(
                                            children:
                                                imagefiles!.map((imageone) {
                                              return Container(
                                                  child: Card(
                                                child: Container(
                                                  height: 100,
                                                  width: 100,
                                                  child: Image.file(
                                                      File(imageone.path)),
                                                ),
                                              ));
                                            }).toList(),
                                          )
                                        : Container(),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Divider(),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF6086d6),
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                        onPressed: () {
                                          openVideo();
                                          setState(() {});
                                        },
                                        icon: const Icon(
                                            Icons.video_file_outlined),
                                        label: const Text("Agregar videos")),
                                    pathVideo.isNotEmpty
                                        ? Container(
                                            width: 200,
                                            height: 20,
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.only(
                                                top: 10, bottom: 0),
                                            child: const Text(
                                              "Video seleccionado",
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: AppColor.primaryColor),
                                            ),
                                          )
                                        : SizedBox(),
                                    pathVideo != ''
                                        ? Center(
                                            child: Text(pathVideo),
                                          )
                                        : Container(),
                                    // _cargarVideosInput(),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 60,
                                          width: 125,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              setState(() {});
                                              mySetState(() {});
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFE4ECFF),
                                                shadowColor: Colors.transparent,
                                                shape: StadiumBorder()),
                                            child: const Text(
                                              'Cancelar',
                                              style: TextStyle(
                                                  color: Color(0xFF3062C9)),
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
                                            onPressed: () {
                                              if (videofiles != null) {
                                                imagefiles!.add(videofiles!);
                                              }
                                              mySetState(() {});
                                              _futureNewComment =
                                                  insertarComentario(
                                                      imagefiles ?? [],
                                                      place.id,
                                                      id,
                                                      commentController
                                                          .value.text,
                                                      rate ?? 1,
                                                      mySetState);
                                            },
                                            child: Text('Enviar'),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xFF3062C9),
                                                shadowColor: Colors.transparent,
                                                shape: StadiumBorder()),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    )
                                  ],
                                )
                              : Column(
                                  children: [
                                    FutureBuilder(
                                      future: _futureNewComment,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          if (snapshot.data == 200) {
                                            Navigator.pop(context);
                                            //
                                            Fluttertoast.showToast(
                                                msg: "Comentario creado",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 2,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                            return Text("Comentario creado");
                                          }
                                          return Text(snapshot.data.toString());
                                        } else if (snapshot.hasError) {
                                          Fluttertoast.showToast(
                                              msg: "Error en la creacion",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 2,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                          Navigator.pop(context);
                                          return Text("${snapshot.error}");
                                        }
                                        return const CircularProgressIndicator();
                                      },
                                    )
                                  ],
                                ),
                        ),
                      ),
                    ),
                  );
                });
              });
        });

        print('presionado');
      },
    );
  }

  Widget noVideos() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      width: double.infinity,
      height: 100,
      child: const Center(
        child: Text('No hay videos que mostrar'),
      ),
    );
  }

  Widget comentariosCard() {
    return Container(
      height: 190,
      width: 370,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: comentarios.length,
          itemBuilder: (context, int index) {
            return Container(
              width: 270,
              child: comentCard(comentarios[index]),
            );
          }),
    );
  }

  Widget comentCard(Datos_Comment comentario) {
    return Card(
      child: InkWell(
        onTap: () {
          print('////////presionado////////////');
          _mostrarInformacionCompleta(context, comentario);
        },
        child: Column(
          children: <Widget>[
            // Image.network(comentario.user!['foto']),
            ComentarioWidget(
              comentario: comentario.comentario,
              nombre: comentario.user?['nombre'],
              valoracion: (comentario.puntaje).toDouble(),
              // foto: coment.user?['foto'],
              foto:
                  ('https://img.freepik.com/vector-premium/perfil-avatar-hombre-icono-redondo_24640-14044.jpg?w=826'),
              // (comentario.user!['foto']),
            ),
            Container(
              width: 350,
              height: 60,
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(
                  left: 20.0, top: 10.0, right: 20, bottom: 20),
              child: SingleChildScrollView(
                child: ReadMoreText(comentario.comentario,
                    colorClickableText: Colors.blue[300],
                    trimMode: TrimMode.Line,
                    trimLines: 2,
                    trimCollapsedText: 'Leer mas',
                    trimExpandedText: 'Leer menos',
                    style: const TextStyle(fontSize: 13.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarInformacionCompleta(
      BuildContext context, Datos_Comment comentario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding:
              const EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          title: const Center(child: Text('Comentario')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 350,
                  height: 90,
                  child: ComentarioWidget(
                    comentario: comentario.comentario,
                    nombre: comentario.user?['nombre'],
                    valoracion: (comentario.puntaje).toDouble(),
                    // foto: coment.user?['foto'],
                    foto:
                        ('https://img.freepik.com/vector-premium/perfil-avatar-hombre-icono-redondo_24640-14044.jpg?w=826'),
                    // (comentario.user!['foto']),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 400,
                    height: 84,
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(
                        left: 10.0, top: 10.0, right: 10, bottom: 5),
                    child: SingleChildScrollView(
                      child: ReadMoreText(comentario.comentario,
                          colorClickableText: Colors.blue[300],
                          trimMode: TrimMode.Line,
                          trimLines: 6,
                          trimCollapsedText: 'Leer mas',
                          trimExpandedText: 'Leer menos',
                          style: const TextStyle(fontSize: 13.0)),
                    ),
                  ),
                ),
                divider(),
                tituloFotosComentario(),
                Visibility(
                  visible: comentario.imagenes == null ||
                      comentario.imagenes!.isEmpty,
                  replacement: SizedBox(
                    width: 300,
                    height: 250,
                    child: listaFotos(comentario.imagenes!, false),
                  ),
                  child: Container(
                    width: 300,
                    height: 100,
                    child: const Center(
                      child: Text('No existen imágenes'),
                    ),
                  ),
                ),
                divider(),
                tituloVideosComentario(),
                offline
                    ? SizedBox()
                    : comentario.video!.isNotEmpty
                        ? videoComentario(comentario.video![0])
                        : noVideos(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
          clipBehavior: Clip.none,
          contentPadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.1),
        );
      },
    );
  }

  Widget videoComentario(String idVideo) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      width: 350,
      height: 250,
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          child: htmlVideo.HtmlWidget(
            '''
                        <iframe
                          src="https://www.facebook.com/v2.3/plugins/video.php?
                          allowfullscreen=true&autoplay=false&href=https://www.facebook.com/turisUp/videos/${idVideo}/" 
                          style="width:300px;height:200px;"
                          allowFileAccess="false"
                          >
                        </iframe>
                      ''',
          ),
        ),
      ),
    );
  }

  Widget listaVideos(List<String> idVideos) {
    // cargarComentarios().
    List<String> videosComentario = [];
    for (int i = 0; i < comentarios.length; i++) {
      if (comentarios[i].video != null && comentarios[i].video is List) {
        List<String> listaVideos =
            (comentarios[i].video! as List).map((e) => e.toString()).toList();
        videosComentario.addAll(listaVideos);
      }
    }
    idVideos.addAll(videosComentario as Iterable<String>);
    return Container(
      margin: const EdgeInsets.only(top: 15),
      width: double.infinity,
      height: 250,
      child: Row(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: idVideos.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: htmlVideo.HtmlWidget(
                  '''
                      <iframe
                        src="https://www.facebook.com/v2.3/plugins/video.php?
                        allowfullscreen=true&autoplay=false&href=https://www.facebook.com/turisUp/videos/${idVideos[index]}/" 
                        style="width:300px;height:200px;"
                        allowFileAccess="false"
                        >
                      </iframe>
                    ''',
                ),
              );
            },
          ))
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
                      setState(() {
                        openVideo();
                      });
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

  openVideo() async {
    if (videos.isNotEmpty) {
      if (imagefiles!.contains(videos[0])) {
        imagefiles!.remove(videos[0]);
      }
      videos = [];
    }
    try {
      var pickedFileVideo =
          await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (pickedFileVideo != null) {
        setState(() {
          videofiles = pickedFileVideo;
          videos.add(videofiles!);
          pathVideo = videofiles!.path;
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

  Future<int> insertarComentario(List<XFile> imagesSelected, String lugarId,
      String userId, String comentario, int puntaje, mySetState) async {
    List<String> stringImages = [];
    for (int i = 0; i < imagesSelected.length; i++) {
      stringImages.add(imagesSelected[i].path);
    }

    int response = await _repository.insertComment(PostNewCommentModel(
        lugarId: lugarId,
        userId: userId,
        comentario: comentario,
        puntaje: puntaje,
        imagenes: stringImages));

    setState(() {});
    mySetState(() {});
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    // List<String> videos = [
    //   'https://fb.watch/jSSSuI41VR/',
    //   'https://fb.watch/jSU5yEHiE7/',
    //   'https://fb.watch/jSU7pCZAs1/',
    //   'https://fb.watch/jSU8zu1ewp/'
    // ];
    PlaceModel place = arguments['place'];
    int index = arguments['index'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _scrollPosition == 0
          ? AppBar(
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0.0,
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                    onPressed: () {
                      if (place.esFavorito == true) {
                        removeFromFavorite(place);
                      } else if (place.esFavorito == false) {
                        addToFavorite(place);
                      }
                    },
                    icon: place.esFavorito!
                        ? const Icon(
                            color: AppColor.primaryColor, Icons.favorite)
                        : const Icon(
                            Icons.favorite_border_outlined,
                            color: Colors.blueAccent,
                          )),
                IconButton(onPressed: () {}, icon: const Icon(Icons.share))
              ],
            )
          : AppBar(
              scrolledUnderElevation: 0.0,
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              actions: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border_outlined)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.share))
              ],
            ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, [place, index]);
          return false;
        },
        child: FutureBuilder<bool>(
            future: ConnectivityUtils.hasConnection(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  print("estadooooooo ${snapshot.data}");

                  bool offline = !snapshot!.data!;
                  return SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    controller: _scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).viewPadding.top,
                        ),
                        offline
                            ? _carrucel(place.localImages!, true)
                            : _carrucel(place.imagenesPaths!, false),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          child: Column(
                            children: [
                              tituloInicio(place.nombre ?? ""),
                              const SizedBox(
                                height: 10,
                              ),
                              etiquetas(place),
                              divider(),
                              organizacionRedes(place.imagenesPaths!,
                                  place.organizacion!.nombre!),
                              const SizedBox(
                                height: 25,
                              ),
                              tituloDescripcion(),
                              const SizedBox(
                                height: 10,
                              ),
                              descricion(place.descripcion!),
                              divider(),
                              tituloFotos2(),
                              offline
                                  ? listaFotos(place.localImages!, true)
                                  : listaFotos(place.imagenesPaths!, false),
                              divider(),
                              tituloVideos(),
                              offline
                                  ? SizedBox()
                                  : place.fbVideoIds!.isNotEmpty
                                      ? listaVideos(place.fbVideoIds!)
                                      : noVideos(),
                              divider(),
                              tituloLocacion(),
                              SizedBox(
                                height: 16,
                              ),
                              offline
                                  ? SizedBox()
                                  : locacion(
                                      place.coordenadas!.latitud,
                                      place.coordenadas!.longitud,
                                      place.imagenesPaths!,
                                      place.nombre ?? ""),
                              divider(),
                              tituloOpiniones(),
                              offline
                                  ? const Text(
                                      "comentarios no disponibles en offline")
                                  : comentariosCard(),
                              divider(),
                              // tituloOpiniones(),
                              // offline
                              //     ? const Text(
                              //         "comentarios no disponibles en offline")
                              //     : SizedBox(
                              //         height:
                              //             comentarios.isEmpty ? 200.0 : 250.0,
                              //         child: bulidComments(
                              //             comentarios)) /*cargarComentarios( id: place.id!, myFunc:setNumComments) */,
                              // divider(),
                              tituloOpininar(),
                              FutureBuilder(
                                future: ApiPlaceRepository.getInjfoUsuario(),
                                builder: (ctx, snapshot) {
                                  if (snapshot.hasData) {
                                    return opinar(snapshot.data!.urlPhoto,
                                        context, place);
                                  } else {
                                    return opinar(
                                        "https://imageio.forbes.com/specials-images/imageserve/61688aa1d4a8658c3f4d8640/Antonio-Juliano/0x0.jpg?format=jpg&width=960",
                                        context,
                                        place);
                                  }

                                  // Displaying LoadingSpinner to indicate waiting state
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }

              return Text("data");
            }),
      ),
    );
  }

  Widget bulidComments(List<Datos_Comment> comment) {
    return ListView.builder(
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        itemCount: comment.length,
        itemBuilder: (context, index) {
          final coment = comment[index];
          return ComentarioWidget(
            comentario: coment.comentario,
            nombre: coment.user?['nombre'],
            valoracion: (coment.puntaje).toDouble(),
            // foto: coment.user?['foto'],
            foto:
                ('https://empresas.blogthinkbig.com/wp-content/uploads/2019/11/Imagen3-245003649.jpg?w=800'),
          );
        });
  }

  Future<void> addToFavorite(PlaceModel place) async {
    UserData userData = await ApiPlaceRepository.getInjfoUsuario();
    Response response =
        await _placeRepository.addFavorite(userData.id.toString(), place.id!);
    if (response.statusCode == 200) {
      place.esFavorito = true;
      setState(() {});
    }
  }

  Future<void> removeFromFavorite(PlaceModel place) async {
    UserData userData = await ApiPlaceRepository.getInjfoUsuario();
    Response response = await _placeRepository.removeFavorite(
        userData.id.toString(), place.id!);
    if (response.statusCode == 200) {
      place.esFavorito = false;
      setState(() {});
    }
  }

  setNumComments(int n) {
    numOpiniones = n;
  }
}
