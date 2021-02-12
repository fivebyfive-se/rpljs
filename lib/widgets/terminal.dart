import 'dart:async';

import 'package:flutter/material.dart';

import 'package:rpljs/config/index.dart';
import 'package:rpljs/helpers/index.dart';

import 'package:rpljs/models/log-item.dart';

class Terminal extends StatelessWidget {
  Terminal({this.stream, this.initialData, this.style});

  final Stream<List<TerminalChunk>> stream;
  final List<TerminalChunk> initialData;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final viewportSize = MediaQuery.of(context).size;

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
            children: <Widget>[
              ...snapshot.data.map(
                (span) => RichText(
                  text: TextSpan(
                    children: span.lines
                      .map((l) => l.trimRight())
                      .map((l) => TextSpan(text: "$l\n")).toList(),
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