import 'package:flutter/material.dart';
import 'package:rpljs/config/constants.dart';
import 'package:rpljs/theme/size-helpers.dart';
import 'package:rpljs/views/base/page-arguments.dart';
import 'package:rpljs/widgets/scaffold/app-bar.dart';
import 'package:rpljs/widgets/scaffold/drawer.dart';

Scaffold scaffoldPage({
  BuildContext context,
  PageArgumentsBuilder builder,
  bool drawer = true
}) {
  final arguments = PageArguments.of(context);
  
  return Scaffold(
    backgroundColor: Constants.theme.background,
    appBar:
      scaffoldAppBar(context, arguments),
    drawer: drawer 
      ? scaffoldDrawer(context, arguments)
      : null,
    body: SafeArea(
      left: true,
      top: true,
      right: true,
      bottom: true,
      minimum: padding(horizontal: 2.0, vertical: 3.0),
      child: builder.call(context, arguments)
    ),
  );
}
