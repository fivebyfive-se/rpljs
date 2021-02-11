import 'package:flutter/painting.dart';
import 'package:rpljs/config/constants.dart';
import 'package:rpljs/theme/rpljs-theme.dart';

enum LogLevel {
  info,
  debug,
  trace,
  warn,
  error
}

class LogItem {
  LogItem({
    this.text,
    this.level = LogLevel.info,
  }) : timestamp = DateTime.now();

  final String text;
  final LogLevel level;
  final DateTime timestamp;

  LogItem.info(String text)
    : this(text: text, level: LogLevel.info);

  LogItem.debug(String text)
    : this(text: text, level: LogLevel.debug);

  LogItem.trace(String text)
    : this(text: text, level: LogLevel.trace);

  LogItem.warn(String text)
    : this(text: text, level: LogLevel.warn);

  LogItem.error(String text)
    : this(text: text, level: LogLevel.error);

  @override
  String toString()
    => level == LogLevel.trace || level == LogLevel.error
      ? "[${timestamp.toIso8601String()}] $text"
      : text;
}

Color logLevelToColor(LogLevel level) {
  switch (level) {
    case LogLevel.info:
      return Constants.theme.foreground;
    case LogLevel.trace:
      return Constants.theme.primaryAccent;
    case LogLevel.debug:
      return Constants.theme.secondaryAccent;
    case LogLevel.warn:
      return RpljsColors.orange;
    case LogLevel.error:
    default:
      return Constants.theme.error;      
  }
}


