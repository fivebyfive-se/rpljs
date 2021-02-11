import 'package:dartjsengine/dartjsengine.dart';

import 'package:rpljs/services/models/jse-exception.dart';
import 'package:rpljs/services/models/jse-state.dart';
import 'package:rpljs/services/models/jse-parse-result.dart';
import 'package:rpljs/services/models/jse-ui-request.dart';
import 'package:rpljs/services/models/jse-variable.dart';

typedef JsFunc = void Function(JsArguments);

abstract class JseServiceBase {
  bool                get isRunning;
  JseState            get currentState;

  Stream<List<JseVariable>> get globals;
  Stream<JseState>          get state;
  Stream<JseException>      get errors;
  Stream<JseUiRequest>      get uiRequests;

  void dispose();
  
  Future<JseParseResult> parseJs(String js);

  void addJsGlobals(Map<String,dynamic> globObjs); 
  void addJsVariables(List<JseVariable> vars);
  void addJsFunctions(Map<String,JsFunc> jsFuncs);
  void addJsObjectWithFunctions(String name, Map<String,JsFunc> jsFuncs);  
}