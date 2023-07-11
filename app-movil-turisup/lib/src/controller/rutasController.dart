import 'package:flutter/cupertino.dart';

class RutasController extends ChangeNotifier {
  Map<int, List> rutas = {};
  List lugares = [];

  void eliminarLugares(index) {
    if (lugares.contains(index)) {
      lugares.remove(index);
      rutas.remove(index);
    }
    print(lugares);
    print(rutas);
  }

  void agregarLugares(int index, latitud, longitud) {
    if (!lugares.contains(index)) {
      List latlong = [];
      latlong.add(latitud);
      latlong.add(longitud);
      rutas[index] = latlong;
      lugares.add(index);
    }
    print(lugares);
    print(rutas);
  }

  Map<int, List> devolverRutas() {
    print('--------------controller rutas--------------------------------');
    // print(lugares);
    // print(rutas);
    return rutas;
  }
}
