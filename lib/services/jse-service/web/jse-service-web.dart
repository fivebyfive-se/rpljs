import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:jsparser/jsparser.dart';
import 'package:dartjsengine/dartjsengine.dart';

import 'package:rpljs/models/log-item.dart';

import 'package:rpljs/services/jse-service/base/jse-service-base.dart';
import 'package:rpljs/services/jse-service/models/index.dart';

class JseServiceWeb extends JseService {
  @protected bool      _builtinsAdded = false;
  @protected JseState  _currState = JseState.None;
  @protected JSEngine  _engine;
  @protected bool      _stopped = true;
  @protected List<LogItem> 
                       _log = <LogItem>[];
  @protected List<JseBuiltin> 
                      _addedBuiltins = <JseBuiltin>[];

  @protected StreamController<JseState> 
    _state = StreamController.broadcast();

  @protected StreamController<List<JseVariable>>
    _globals = StreamController.broadcast();

  @protected StreamController<JseException>
    _errors = StreamController.broadcast();

  @protected StreamController<JseUiRequest>
    _jsRequests = StreamController.broadcast();

  @protected StreamController<List<JseBuiltin>>
    _builtins = StreamController.broadcast();

  /// True if service has been started, and not stopped
  @override bool get isRunning => (
    !_stopped &&  _currState.index > JseState.Stopped.index
  );

  /// State at last update
  @override JseState get currentState => _currState;

  @override
  Future<void> init() async {
    await _ensureEngine();
  }

  /// Free resources
  @override
  void dispose() {
    _stopped = true;
    _state.close();
    _globals.close();
    _errors.close();
    _jsRequests.close();
    _builtins.close();
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

  /// Stream of names of builtin functions
  @override Stream<List<JseBuiltin>>
    get builtins => _builtins.stream;

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
      _streamLogItem(LogItem.error(e.toString()));

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

  @override
  void addJsFunctions(List<JseBuiltinFunc> jsFuncs) {
    jsFuncs.forEach((fn) {
      _addedBuiltins.add(fn);
      _addJsObject(fn.name, _wrapFunction(fn.func));
    });
  }

  @override
  void addJsObjectsWithFunctions(List<JseBuiltinObject> jsObjs) {
    jsObjs.forEach((obj) {
      final jsObj = JsObject();
      obj.objFuncs.forEach((fn) {
        _addedBuiltins.add(fn.withPrefix(obj.name));
        jsObj.properties.putIfAbsent(fn.name, () => _wrapFunction(fn.func));
      });
      _addJsObject(obj.name, jsObj);
    });
  }

  @protected
  JsFunction _wrapFunction(JseFunc func) => JsFunction(
    _engine.global,
    (en, args, ctx) {
      func.call(args);
      return null;
    });

  @protected
  void _addJsObject(String name, JsObject value) {
    _ensureEngine(throwIfStopped: true);
    
    _engine.global.properties.putIfAbsent(name, () => value);
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
        await _ensureBuiltins();
        _streamState(JseState.Idle);
      })();
    } else if (currentState.index <= JseState.Stopped.index) {
      _streamError(JseStoppedException());
    }
  }

  @protected
  Future<void> _ensureBuiltins() async {
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
    final globFuncs = [
      JseBuiltinFunc(
        'clear',  clear, 0,
        doc: 'Clear output window'
      ),
      JseBuiltinFunc(
        'vardump', vardump, 0,
        doc: 'Dump names and values of global variables to output'
      ),
      JseBuiltinFunc(
        'log', mklog(LogLevel.debug), 1,
        doc: 'Write a value to output'
      )
    ];
    final globObjs = [
      JseBuiltinObject('console', [ 
        JseBuiltinFunc(
          'log', mklog(LogLevel.info), 1,
          doc: 'Log message to output'
        ),
        JseBuiltinFunc(
          'trace', mklog(LogLevel.trace), 1,
          doc: 'Log trace message to output'
        ),
        JseBuiltinFunc(
          'warn', mklog(LogLevel.warn), 1,
          doc: 'Log warning message to output'
        ),
        JseBuiltinFunc(
          'error', mklog(LogLevel.error), 1,
          doc: 'Log error message to output'
        ),
      ],
      doc: 'Global console object')
    ];

    addJsFunctions(globFuncs);
    addJsObjectsWithFunctions(globObjs);

    _streamBuiltins();

    _builtinsAdded = true;
  }

  @protected
  void _streamBuiltins() => _builtins.add(_addedBuiltins);

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
    _streamRequest(JseUiRequestLog([..._log].toList()));
    _log.clear();
  }

  @protected
  void _streamLogItem(LogItem item) 
    => _streamRequest(JseUiRequestLog([item].toList()));

  @protected
  void _streamError(JseException err) => _errors.add(err);
}
