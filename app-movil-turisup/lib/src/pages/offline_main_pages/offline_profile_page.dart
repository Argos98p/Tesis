import 'package:flutter/material.dart';

import '../../widgets/no_connection-animation.dart';

class OfflineProfilePage extends StatefulWidget {
  const OfflineProfilePage({super.key});

  @override
  State<OfflineProfilePage> createState() => _OfflineProfilePageState();
}

class _OfflineProfilePageState extends State<OfflineProfilePage> {
  @override
  Widget build(BuildContext context) {
    return  Center(
      child: NoConnectionWidget()
    );
  }
}
