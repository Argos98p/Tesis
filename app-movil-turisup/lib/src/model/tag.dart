
class Tag {
  final String nombre;

  Tag({
    required this.nombre
  });

  static List<Tag>  tagList= [
    Tag(nombre: 'Iglesia',),
    Tag(nombre: 'Museo',),
    Tag(nombre: 'Playa',),
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
  ];

  @override
  List<Object> get props => [nombre];
  String toJson() => '''  {
    "name": $nombre,
  }''';

}