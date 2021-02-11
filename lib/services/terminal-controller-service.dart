import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rpljs/services/models/log-item.dart';
import 'package:rpljs/widgets/terminal.dart';

class TerminalControllerService {
  final List<TerminalChunk> currentState = <TerminalChunk>[];

  @protected
  final StreamController<List<TerminalChunk>> _ctrl 
    = StreamController.broadcast();
  Stream<List<TerminalChunk>> get stream => _ctrl.stream;

  void handleCommand(TerminalCommand cmd) {
    if (cmd is TerminalCommandPrint) {
      currentState.addAll([...cmd.chunks]);
    } else if (cmd is TerminalCommandClear) {
      currentState.clear();
    }
    _ctrl.add([...currentState]);
  }

  void log(List<LogItem> logItems)
    => handleCommand(TerminalCommandPrint.fromLogItems(logItems));

  void print(List<TerminalChunk> chunks)
    => handleCommand(TerminalCommandPrint(chunks));

  void clear()
    => handleCommand(TerminalCommandClear());

  static TerminalControllerService _instance;

  static TerminalControllerService getInstance()
    => _instance ?? (_instance = TerminalControllerService());
}

class TerminalCommand {}

class TerminalCommandClear extends TerminalCommand {}

class TerminalCommandPrint extends TerminalCommand {
  TerminalCommandPrint(this.chunks);

  TerminalCommandPrint.fromLogItems(List<LogItem> logItems)
    : chunks = logItems.map((li) => TerminalChunk.fromLogItem(li));

  final List<TerminalChunk> chunks;
}