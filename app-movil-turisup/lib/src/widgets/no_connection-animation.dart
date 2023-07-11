import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget NoConnectionWidget(){
  return Container(

    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:  [
          //Text(msg, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),),
          SizedBox(height: 20,),
          Lottie.asset('assets/lottie_animations/no-internet.json'),
        ],
      ),
    ),
  );
}