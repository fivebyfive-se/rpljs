import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:rpljs/config/constants.dart';

import 'package:rpljs/models/log-item.dart';
import 'package:rpljs/widgets/terminal.dart' show TerminalChunk;

class TerminalControllerService {
  final List<TerminalChunk> currentState = <TerminalChunk>[];

  Stream<List<TerminalChunk>> get stream => _ctrl.stream;

  @protected
  final StreamController<List<TerminalChunk>> _ctrl 
    = StreamController.broadcast();

  @protected void _update() {
    _ctrl.add([...currentState]);
  }

  void handleCommand(TerminalCommand cmd) {
    if (cmd is TerminalCommandPrint) {
      currentState.addAll([...cmd.chunks]);
    } else if (cmd is TerminalCommandEcho) {
      currentState.add(cmd.chunk);
    } else if (cmd is TerminalCommandClear) {
      currentState.clear();
    }
    _update();
  }

  void log(List<LogItem> logItems)
    => handleCommand(TerminalCommandPrint.fromLogItems(logItems));

  void print(List<TerminalChunk> chunks)
    => handleCommand(TerminalCommandPrint(chunks));

  void echo(List<String> lines)
    => handleCommand(TerminalCommandEcho(lines));

  void clear()
    => handleCommand(TerminalCommandClear());

  static TerminalControllerService _instance;

  static TerminalControllerService getInstance()
    => _instance ?? (_instance = TerminalControllerService());
}

class TerminalCommand {}

class TerminalCommandClear extends TerminalCommand {}

class TerminalCommandEcho extends TerminalCommand {
  TerminalCommandEcho(this.lines);
  final List<String> lines;

  TerminalChunk get chunk => TerminalChunk(
    lines.map((l) => "\$ $l").toList(),
    color: Constants.theme.inputAccent
  );
}

class TerminalCommandPrint extends TerminalCommand {
  TerminalCommandPrint(this.chunks);

  TerminalCommandPrint.fromLogItems(List<LogItem> logItems)
    : chunks = logItems.map((li) => TerminalChunk.fromLogItem(li));

  final List<TerminalChunk> chunks;
}