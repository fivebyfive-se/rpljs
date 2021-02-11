import 'package:flutter/material.dart';

typedef PageArgumentsBuilder = Widget Function(
  BuildContext context,
  PageArguments arguments
);

Widget buildWithArguments<T extends PageArguments>({
  BuildContext context,
  PageArgumentsBuilder builder
}) => builder.call(
  context,
  PageArguments.of(context)
);

class PageArguments {
  PageArguments({
    this.routeName
  });

  final String routeName;

  PageArguments copyWith({String title, String routeName})
    => PageArguments(
      routeName: routeName ?? this.routeName
    );

  static PageArguments of(BuildContext context) {
    final routeSettings = ModalRoute.of(context).settings;
    final arguments = (routeSettings.arguments as PageArguments);
    
    return (arguments ?? PageArguments()).copyWith(
      routeName: routeSettings.name
    );
  }
}
