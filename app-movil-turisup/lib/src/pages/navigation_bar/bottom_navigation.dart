import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:turismup/src/utils/AppColor.dart';

import '../../service/network_connectivity.dart';

class BtnNavigation extends StatefulWidget {
  final Function currentIndex;
  const BtnNavigation({super.key, required this.currentIndex});

  @override
  State<BtnNavigation> createState() => _BtnNavigationState();
}

class _BtnNavigationState extends State<BtnNavigation> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  int index = 0;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      onTap: (int i) {
        setState(() {});
        index = i;
        widget.currentIndex(i);
      },
      type: BottomNavigationBarType.fixed,
      iconSize: 25.0,
      selectedFontSize: 12.0,
      selectedItemColor: AppColor.primaryColor,
      unselectedFontSize: 12.0,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.compass),
          label: 'Explorar',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.mapLocationDot),
          label: 'Mapa',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.route),
          label: 'Rutas',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.user),
          label: 'Perfil',
        ),
      ],
    );
  }
}
