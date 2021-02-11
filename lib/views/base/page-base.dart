import 'package:flutter/material.dart';
import 'package:rpljs/views/base/page-arguments.dart';
import 'package:rpljs/widgets/scaffold/page.dart';

abstract class PageBase<T extends PageArguments> extends StatefulWidget {
  PageBase({this.showDrawer});

  final bool showDrawer;

  Scaffold scaffold(BuildContext context, PageArgumentsBuilder builder)
    => scaffoldPage(context: context, builder: builder);
} 