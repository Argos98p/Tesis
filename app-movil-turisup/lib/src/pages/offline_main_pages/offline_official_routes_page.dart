import 'package:flutter/material.dart';

import '../../widgets/no_connection-animation.dart';

class OfflineOfficialRoutesPage extends StatefulWidget {
  const OfflineOfficialRoutesPage({super.key});

  @override
  State<OfflineOfficialRoutesPage> createState() => _OfflineOfficialRoutesPageState();
}

class _OfflineOfficialRoutesPageState extends State<OfflineOfficialRoutesPage> {
  @override
  Widget build(BuildContext context) {
    return  Center(
      child: NoConnectionWidget()
    );
  }
}
