import 'package:flutter/material.dart';
import 'package:rpljs/config/constants.dart';
import 'package:rpljs/helpers/text-style-helpers.dart';
import 'package:rpljs/views/base/page-arguments.dart';

AppBar scaffoldAppBar(
  BuildContext context,
  PageArguments arguments
) 
  => AppBar(
    title: Text(
      "${Constants.appTitle}",
      style: textStyleHeading()
    ),
    backgroundColor: Constants.theme.appBarBackground,
    foregroundColor: Constants.theme.appBarForeground,
    bottomOpacity: 0.5,
  );