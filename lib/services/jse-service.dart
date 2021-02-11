import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:jsparser/jsparser.dart';
import 'package:dartjsengine/dartjsengine.dart';

import 'package:rpljs/services/base/jse-service-base.dart';
import 'package:rpljs/services/models/jse-exception.dart';
import 'package:rpljs/services/models/jse-parse-result.dart';
import 'package:rpljs/services/models/jse-state.dart';
import 'package:rpljs/services/models/jse-ui-request.dart';
import 'package:rpljs/services/models/jse-variable.dart';
import 'package:rpljs/services/models/log-item.dart';

class JseService extends JseServiceBase {
  @protected bool      _builtinsAdded = false;
  @protected JseState  _currState = JseState.None;
  @protected JSEngine  _engine;
  @protected bool      _stopped = true;
  @protected List<LogItem> _log = <LogItem>[];

  @protected StreamController<JseState> 
    _state = StreamController();

  @protected StreamController<List<JseVariable>>
    _globals = StreamController();

  @protected StreamController<JseException>
    _errors = StreamController();

  @protected StreamController<JseUiRequest>
    _jsRequests = StreamController();

  /// True if service has been started, and not stopped
  @override bool get isRunning => (
    !_stopped &&  _currState.index > JseState.Stopped.index
  );

  /// State at last update
  @override JseState get currentState => _currState;

  /// Free resources
  @override
  void dispose() {
    _stopped = true;
    _state.close();
    _globals.close();
  }

  /// Stream of global variables added to [JsEngine].
  @override Stream<List<JseVariable>>
    get globals => _globals.stream;

  /// Stream of state changes
  @override Stream<JseState>
    get state   => _state.stream;

  /// Error-stream
  @override Stream<JseException>
    get errors  => _errors.stream;

  /// Stream of UI-requests
  @override Stream<JseUiRequest>
    get uiRequests => _jsRequests.stream;

  /// Asynchronously parse a string of Javascript code
  @override
  Future<JseParseResult> parseJs(String js) async {
    _ensureEngine(throwIfStopped: true);
    try {
      _streamState(JseState.Parsing);
      await (() async {
        final prog = parsejs(js);
        final retVal = _engine.visitProgram(prog);
        if (retVal?.jsValueOf != null) {
          _log.add(LogItem.trace(retVal.jsValueOf.toString() ?? "null"));
        }
        _streamGlobals();
        _streamOutput();
      })();
    } catch (e) {
      _streamError(JseException(message: e.toString()));

      _streamState(JseState.Idle);

      return JseParseResult.Error;
    }

    _streamState(JseState.Idle);
    return JseParseResult.Success;
  }

  /// Add global variables
  @override
  void addJsGlobals(Map<String,dynamic> globObjs)
    => addJsVariables(
      globObjs.entries
        .map((en) => jsVarFromValue(en.key, en.value))
    );

  @override
  void addJsVariables(List<JseVariable> vars) {
    _ensureEngine(throwIfStopped: true);

    vars.forEach((jv) {
      if (!_engine.globalScope.allVariables.any((ev) => ev.name == jv.name)) {
        _engine.globalScope.create(jv.name, value: jv.jsObject, constant: false);
      }  
    });
  }

  /// Add functions to global scope
  @override
  void addJsFunctions(Map<String,JsFunc> jsFuncs)
    => _addJsObjects(_wrapFunctions(jsFuncs));

  @override
  void addJsObjectWithFunctions(String name, Map<String,JsFunc> jsFuncs) {
    final obj = JsObject();
    obj.properties.addAll(_wrapFunctions(jsFuncs));

    _addJsObjects(Map.fromEntries([MapEntry(name, obj)]));
  }

  @protected
  Map<String,JsObject> _wrapFunctions(Map<String,JsFunc> funcs)
    => funcs.map((name, fun) => MapEntry(name, _wrapFunction(fun)));

  @protected
  JsFunction _wrapFunction(JsFunc func) => JsFunction(
    _engine.global,
    (en, args, ctx) {
      func.call(args);
      return null;
    });

  @protected
  void _addJsObjects(Map<String,JsObject> objs) {
    _ensureEngine(throwIfStopped: true);
    _engine.global.properties.addAll(objs);
  }

  @protected
  List<JseVariable> _getJseVariables() {
    _ensureEngine(throwIfStopped: true);
    return _engine.globalScope.allVariables
      .where((v) => v.name != 'global')
      .map((v) => JseVariable(name: v.name, jsObject: v.value))
      .toList();
  }


  @protected
  Future<void> _ensureEngine({bool throwIfStopped = false}) async {
    if (_engine == null) {
      await (() async {
        _streamState(JseState.Starting);
        _engine = JSEngine();
        _ensureBuiltins();
        _streamState(JseState.Idle);
      })();
    } else if (currentState.index <= JseState.Stopped.index) {
      _streamError(JseStoppedException());
    }
  }

  @protected
  void _ensureBuiltins() {
    if (_builtinsAdded) {
      return;
    }

    final mklog = (LogLevel level)
      => (JsArguments args) { 
        _log.add(LogItem(
          text:  args.valueOf.map((o) => o.toString()).join(" "),
          level: level
        ));
      };

    final clear = (args) {
      _streamRequest(JseUiRequestClear());
      return null;
    };

    final vardump = (args) {
      final vars = _getJseVariables();
      if (vars.length == 0) {
        _log.add(LogItem.debug('[vardump] no global variables set'));
      } else {
        _log.add(LogItem.debug('[vardump] found the following variables:'));
      }
      vars.forEach(
        (v) => _log.add(LogItem.debug("   ${v.name}: [${v.value.toString()}]"))
      );
      return null;
    };

    addJsFunctions({
      'clear': clear,
      'vardump': vardump,
      'log': mklog(LogLevel.debug)
    });
    addJsObjectWithFunctions('console', {
      'log': mklog(LogLevel.info),
      'warn': mklog(LogLevel.warn),
      'error': mklog(LogLevel.error),
      'trace': mklog(LogLevel.trace)
    });

    _builtinsAdded = true;
  }

  @protected
  void _streamRequest(JseUiRequest req) => _jsRequests.add(req) ;

  @protected
  void _streamState(JseState state) {
    _state.add(state);
    _currState = state;
  }

  @protected
  void _streamGlobals() => _globals.add(_getJseVariables());

  @protected
  void _streamOutput() {
    _streamRequest(new JseUiRequestLog([..._log].toList()));
    _log.clear();
  }

  @protected
  void _streamError(JseException err) => _errors.add(err);

  @protected
  static JseService _instance;

  static JseService getInstance() {
    if (_instance == null) {
      _instance = JseService();
    }
    return _instance;
  } 
}
