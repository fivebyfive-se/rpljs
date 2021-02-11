import '../models/index.dart';


abstract class JseService {
  bool                get isRunning;
  JseState            get currentState;

  Stream<List<JseVariable>> get globals;
  Stream<JseState>          get state;
  Stream<JseException>      get errors;
  Stream<JseUiRequest>      get uiRequests;
  Stream<List<JseBuiltin>>  get builtins;

  void init();
  void dispose();
  
  Future<JseParseResult> parseJs(String js);

  void addJsGlobals(Map<String,dynamic> globObjs); 
  void addJsVariables(List<JseVariable> vars);
  void addJsFunctions(List<JseBuiltinFunc> jsFuncs);
  void addJsObjectsWithFunctions(List<JseBuiltinObject> jsObjs);  
}