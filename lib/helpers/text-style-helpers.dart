import 'package:flutter/material.dart';

import 'package:rpljs/config/index.dart' show Constants;

TextStyle textColor(Color color)
  => TextStyle(color: color);

TextStyle textStyleBody() 
  => TextStyle(
    fontFamily: Constants.fontSans,
    fontSize: Constants.fontSizeBase,
    color: Constants.theme.foreground,
  );

TextStyle textStyleCode()
  => textStyleBody().copyWith(
    fontFamily: Constants.fontMono,
    letterSpacing: 0.1
  );

TextStyle textStyleHeading()
  => textStyleBody().copyWith(
    fontWeight: FontWeight.w600
  );

TextStyle textStyleTitle()
  => textStyleHeading().copyWith(
    fontSize: Constants.fontSizeXLarge,
    fontWeight: FontWeight.w700
  );

TextStyle textStyleSubtitle()
  => textStyleTitle()
    .copyWith(fontSize: Constants.fontSizeLarge);
