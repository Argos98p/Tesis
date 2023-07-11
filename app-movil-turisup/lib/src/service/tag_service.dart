import '../model/tag.dart';

class TagService {
  /// Mocks fetching language from network API with delay of 500ms.
  static Future<List<Tag>> getLanguages(String query) async {
    await Future.delayed(Duration(milliseconds: 500), null);
    return <Tag>[
      Tag(nombre: 'Iglesia',),
      Tag(nombre: 'Museo',),
      //Tag(nombre: 'Playa',),
      Tag(nombre: 'Montaña',),
      Tag(nombre: 'Hotel',),
      //Tag(nombre: 'Parque',),
      Tag(nombre: 'Restaurante',),
      //Tag(nombre: 'Rio',),
      //Tag(nombre: 'Mirador',),
      //Tag(nombre: 'Verde',),
      //Tag(nombre: 'Ruina',),
      Tag(nombre: 'Laguna',),
      //Tag(nombre: 'Acampar',),
      //Tag(nombre: 'Diversion',),
      //Tag(nombre: 'Arte',),
    ]
        .where((lang) => lang.nombre.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}