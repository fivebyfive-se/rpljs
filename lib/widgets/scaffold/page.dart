import 'package:flutter/material.dart';

import 'package:rpljs/config/constants.dart';

import 'package:rpljs/helpers/size-helpers.dart';

import 'package:rpljs/views/base/page-arguments.dart';

import 'package:rpljs/widgets/scaffold/app-bar.dart';
import 'package:rpljs/widgets/scaffold/drawer.dart';

Scaffold scaffoldPage({
  BuildContext context,
  PageArgumentsBuilder builder,
  bool drawer = true,
}) {
  final arguments = PageArguments.of(context);
  final viewportSize = MediaQuery.of(context).size;
  final appBar = scaffoldAppBar(context, arguments);
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
      minimum: padding(horizontal: 0, vertical: 0),
      child: Container(
        width: viewportSize.width,
        height: viewportSize.height - appBar.preferredSize.height,
        decoration: BoxDecoration(
          gradient: Constants.theme.backgroundGradient
        ),
        child: builder.call(context, arguments)
      ),
    ),
  );
}
