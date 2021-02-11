import 'package:flutter/material.dart';
import 'package:rpljs/views/base/page-arguments.dart';
import 'package:rpljs/views/base/page-base.dart';

class PageNavigator<T extends PageBase,U extends PageArguments> {
  PageNavigator({this.routeName});

  final String routeName;

  bool isActive(BuildContext context)
    => ModalRoute.of(context).settings.name == routeName;

  void navigateTo({
    BuildContext context,
    U arguments
  }) => Navigator
    .pushNamed(context, routeName, arguments: arguments);
}