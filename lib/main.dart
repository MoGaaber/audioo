import 'package:audioo/ui.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'logic.dart';

main() {

  runApp(AppRoot());
}

class AppRoot extends StatefulWidget {
  @override
  _AppRootState createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => Logic(this),
      child: MaterialApp(home: Ui()),
    );
  }
}
