
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget myDivider (text){
  return Column(children: <Widget>[

    Row(children: <Widget>[
      Expanded(
        child: Container(
            margin: const EdgeInsets.only(left: 10.0, right: 20.0),
            child: const Divider(
              color: Colors.black26,
              height: 36,
            )),
      ),
      Text(text),
      Expanded(
        child: Container(
            margin: const EdgeInsets.only(left: 20.0, right: 10.0),
            child: const Divider(
              color: Colors.black26,
              height: 36,
            )),
      ),
    ]),

  ]);
}