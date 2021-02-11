import 'package:flutter/material.dart';

import 'package:rpljs/config/constants.dart';


TextStyle textStyleBody() 
  => TextStyle(
    fontFamily: Constants.fontSans,
    fontSize: Constants.fontSizeBase,
    color: Constants.theme.foreground,
  );

TextStyle textStyleCode()
  => textStyleBody().copyWith(
    fontFamily: Constants.fontMono
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
