import 'package:rpljs/services/jse-service/models/jse-verbosity.dart';

import '../models/index.dart';


abstract class JseService {
  bool                get isRunning;
  JseState            get currentState;
  JseVerbosity        get verbosity;
                      set verbosity(JseVerbosity verbosity);
  
  Stream<List<JseVariable>> get globals;
  Stream<JseState>          get state;
  Stream<JseException>      get errors;
  Stream<JseUiRequest>      get uiRequests;
  Stream<List<JseBuiltin>>  get builtins;

  void init();
  void dispose();
  
  Future<JseParseResult> parseJs(String js, {bool isSnippet = false});

  void addJsGlobals(Map<String,dynamic> globObjs); 
  void addJsVariables(List<JseVariable> vars);
  void addJsFunctions(List<JseBuiltinFunc> jsFuncs);
  void addJsObjectsWithFunctions(List<JseBuiltinObject> jsObjs);  
}