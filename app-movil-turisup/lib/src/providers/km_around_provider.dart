import 'package:flutter/material.dart';

class KmAroundProvider extends ChangeNotifier {
  double _km_around = 80.0;

  double get km_around => _km_around;
  void newValueKmAround(double value) {
    _km_around = value;
    notifyListeners();
  }

}