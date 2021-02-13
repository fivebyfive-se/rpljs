import 'package:flutter/material.dart';
import 'package:rpljs/config/index.dart';
import 'package:rpljs/services/app-state.dart';
import 'package:rpljs/views/splash-page.dart';

Future<void> main() async {
  await AppStateProvider.init();
  
  runApp(Splash());
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'rpljs',
        home: SplashPage(
          timeout: 4,
          transition: 2,
          next: MyApp()
        )
    );
  }
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
