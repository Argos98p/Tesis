import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OfflineMapPage extends StatelessWidget {
  static const String route = '/offline_map';

  const OfflineMapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Map')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                  'This is an offline map that is showing Anholt Island, Denmark.'),
            ),
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                  //center: LatLng(-2.903777, -79.018237),
                  minZoom:0,
                  maxZoom: 1,
                  //swPanBoundary: LatLng(-3.622695, -79.916608),
                  //nePanBoundary: LatLng(-2.549858, -77.745404),
                ),
                children: [


                  TileLayer(
                    tms:true,
                    errorTileCallback: (tile,varas){print("loooooooooooog");},
                    tileProvider: AssetTileProvider(),

                    maxZoom: 1,
                    urlTemplate: 'assets/test/{z}/{x}/{y}.png',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}