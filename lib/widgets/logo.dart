import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  Logo({
    @required this.logo
  }) : assert(logo != null, '{logo} must be set!');

  final Logos logo;
  
  @override
  Widget build(BuildContext context) {
    try {
      final img = Image(
        image: logoProvider(logo: logo),
        filterQuality: FilterQuality.high
      );
      return img;
    } catch (e) {
      print(e);
    }
    return Placeholder();
  }
}

AssetImage logoProvider({Logos logo})
  => AssetImage(
    (() {
      switch (logo) {
        case Logos.rpljs:
          return "images/logo.png";
        case Logos.fivebyfive:
          return "images/fivebyfive.png";
      }
    })()
  );

enum Logos {
  rpljs,
  fivebyfive
}