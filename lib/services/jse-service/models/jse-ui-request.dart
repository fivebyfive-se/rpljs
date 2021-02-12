import 'package:flutter/foundation.dart';
import 'package:rpljs/models/log-item.dart';

abstract class JseUiRequest {}

abstract class JseUiTypedRequest<T> extends JseUiRequest {
  JseUiTypedRequest({T payload}) : _payload = payload;

  @protected
  final T _payload;
} 

class JseUiRequestEcho extends JseUiTypedRequest<List<String>> {
  JseUiRequestEcho(List<String> lines)
    : super(payload: lines);
    
  List<String> get lines => _payload;
}

class JseUiRequestClear extends JseUiRequest {}

class JseUiRequestLog extends JseUiTypedRequest<List<LogItem>> {
  JseUiRequestLog(List<LogItem> items) 
    : super(payload: items);
 
  List<LogItem> get items => _payload;
}