import 'package:flutter/material.dart';

class RpljsLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context)
    => Image(image: rpljsLogoProvider());
}

AssetImage rpljsLogoProvider()
  => AssetImage('images/logo.png');