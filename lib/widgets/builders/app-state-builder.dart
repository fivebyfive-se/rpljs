import 'package:flutter/material.dart';

import 'package:rpljs/state/app-state-model.dart';
import 'package:rpljs/state/app-state-provider.dart';

typedef AppStateWidgetBuilder = Function(
  BuildContext context,
  AppState state,
  AppStateProvider provider
);

class AppStateBuilder extends StatefulWidget {
  AppStateBuilder({
    @required this.builder
  }) : assert(builder != null, 'builder is required!');

  final AppStateWidgetBuilder builder;

  @override
  _AppStateBuilderState createState() => _AppStateBuilderState();
}

class _AppStateBuilderState extends State<AppStateBuilder> {
  @protected
  final AppStateProvider _provider = AppStateProvider.getInstance();

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<AppState>(
      stream: _provider.stream,
      initialData: _provider.snapshot,
      builder: (context, snapshot) => widget.builder(
        context,
        snapshot.data,
        _provider,
      )
    );
  }
}