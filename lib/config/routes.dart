import 'package:flutter/material.dart';

import 'package:rpljs/views/settings-page.dart';
import 'package:rpljs/views/start-page.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> routes = {
    StartPage.routeName: (context) => StartPage(),
    SettingsPage.routeName: (context) => SettingsPage()
  };

  static String initialRoute = StartPage.routeName;
}