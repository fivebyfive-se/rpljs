import 'dart:async';

import 'package:flutter/material.dart';

import 'package:rpljs/config/index.dart';
import 'package:rpljs/helpers/index.dart';

import 'package:rpljs/models/log-item.dart';

class Terminal extends StatelessWidget {
  Terminal({this.controller, this.initialData, this.stream, this.style});

  final Stream<List<TerminalChunk>> stream;
  final List<TerminalChunk> initialData;
  final TextStyle style;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final viewportSize = MediaQuery.of(context).size;
    final headingRex = RegExp(r'^\s*#+');

    return StreamBuilder<List<TerminalChunk>>(
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot)
        => Container(
          width: viewportSize.width,
          padding: padding(horizontal: 2, vertical: 1),
          decoration: BoxDecoration(
            gradient: Constants.theme.terminalGradient,
            border: BorderDirectional(
              bottom: BorderSide(
                color: Constants.theme.terminalBorder,
                width: minSize()
              )
            )
          ),
          child: ListView(
            controller: controller,
            children: <Widget>[
              ...snapshot.data.map(
                (span) => RichText(
                  text: TextSpan(
                    children: span.lines
                      .map((l) => l.trimRight())
                      .map((l) => TextSpan(
                        text: l.replaceFirst(headingRex,'') + "\n",
                        style: headingRex.hasMatch(l)
                          ? style.copyWith(
                              inherit: true,
                              fontWeight: FontWeight.bold,
                              fontSize: Constants.fontSizeLarge,
                              color: span.color ?? null
                            )
                          : null
                      )).toList(),
                    style: span.color == null 
                        ? style
                        : style.copyWith(color: span.color),
                  ),
                  softWrap: true,
                ))
            ],
        ))
    );
  }
}

class TerminalChunk {
  TerminalChunk.one(String line, {this.color})
    : lines = [line];

  TerminalChunk.fromLogItem(LogItem logItem)
    : lines = [logItem.toString()],
      color = logLevelToColor(logItem.level);

  TerminalChunk(this.lines, {this.color});

  final List<String> lines;
  final Color color;
}