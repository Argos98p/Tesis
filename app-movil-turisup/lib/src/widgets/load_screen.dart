import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

Widget LoadScreen(String msg){
  return Container(

    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:  [
          Text(msg, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),),
          SizedBox(height: 20,),
          Lottie.asset('assets/lottie_animations/loadMap.json'),
        ],
      ),
    ),
  );
}