
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/AppColor.dart';

class MyLocationMarker extends AnimatedWidget {
  const MyLocationMarker(Animation<double> animation, {Key? key}) : super(key: key,listenable: animation );

  @override
  Widget build(BuildContext context) {
    final value = (listenable as Animation<double>).value;
    final newValue = lerpDouble(0.6, 1.0, value)!;
    final size = MediaQuery.of(context).size.width;
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Container(
              height: size*0.7*newValue,
              width: size*0.7*newValue,
              decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.2), shape: BoxShape.circle),
            ),
          ),
          Center(
            child: Container(
              height: size*0.5*newValue,
              width: size*0.5*newValue,
              decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.35), shape: BoxShape.circle),
            ),
          ),
          Center(
            child: Container(
              height: size*0.3,
              width: size*0.3,
              decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.5), shape: BoxShape.circle),
            ),
          ),
          Center(
            child: Container(
              height: size*0.18,
              width: size*0.18,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.white, width: 2)
              ),
              child: ClipRRect(

                borderRadius: BorderRadius.circular(100),
                child: Image.asset("assets/images/user.jpeg",
                  height: size*0.16,
                  width: size*0.16,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}