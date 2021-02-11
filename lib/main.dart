import 'package:flutter/material.dart';

import 'package:rpljs/config/constants.dart';
import 'package:rpljs/config/routes.dart';
import 'package:rpljs/state/app-state-provider.dart';

Future<void> main() async {
  await AppStateProvider.init();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appTitle,
      theme: Constants.theme.toThemeData(),
      routes: Routes.routes,
      initialRoute: Routes.initialRoute,
    );
  }
}
