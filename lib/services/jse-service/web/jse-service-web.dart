import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:jsparser/jsparser.dart';
import 'package:dartjsengine/dartjsengine.dart';

import 'package:rpljs/models/log-item.dart';

import 'package:rpljs/services/jse-service/base/jse-service-base.dart';
import 'package:rpljs/services/jse-service/models/index.dart';
import 'package:rpljs/services/jse-service/models/jse-verbosity.dart';

class JseServiceWeb extends JseService {
  JseVerbosity verbosity = JseVerbosity.normal;
  
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
  Future<void> init() async => await _ensureEngine();

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
  @override Stream<List<JseVariable>> get globals => _globals.stream;

  /// Stream of state changes
  @override Stream<JseState> get state   => _state.stream;

  /// Error-stream
  @override Stream<JseException> get errors  => _errors.stream;

  /// Stream of UI-requests
  @override Stream<JseUiRequest> get uiRequests => _jsRequests.stream;

  /// Stream of names of builtin functions
  @override Stream<List<JseBuiltin>> get builtins => _builtins.stream;

  /// Asynchronously parse a string of Javascript code
  @override
  Future<JseParseResult> parseJs(
    String js, {
      bool isSnippet = false
    }
  ) async {
    _ensureEngine(throwIfStopped: true);
    try {
      _streamState(JseState.Parsing);
      await (() async {
        _echo([
          '//' + DateTime.now().toIso8601String(),
          ...js.split("\n")
        ], verbose: !isSnippet);

        final prog = parsejs(js);
        final retVal = _engine.visitProgram(prog);

        if (retVal?.jsValueOf != null) {
          _debug(retVal.jsValueOf.toString() ?? "null");
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

  /// Add global variables
  @override
  void addJsVariables(List<JseVariable> vars) {
    _ensureEngine(throwIfStopped: true);

    vars.forEach((jv) {
      if (!_engine.globalScope.allVariables.any((ev) => ev.name == jv.name)) {
        _engine.globalScope.create(jv.name, value: jv.jsObject, constant: false);
      }  
    });
  }

  /// Add global functions
  @override
  void addJsFunctions(List<JseBuiltinFunc> jsFuncs) {
    _addJsObjects(_builtinFuncsToJs(jsFuncs));
    _addedBuiltins.addAll(jsFuncs);
  }

  /// Add functions in global objects
  @override
  void addJsObjectsWithFunctions(List<JseBuiltinObject> jsObjs) {
    var omap = Map.fromEntries(jsObjs.map((obj) {
      final jsObj = JsObject();
      final funcs = _builtinFuncsToJs(obj.funcs);
      jsObj.properties.addAll(funcs);
      _addedBuiltins.addAll(obj.nsFuncs);      
      return MapEntry(obj.name, jsObj);
    }));

    _addJsObjects(omap);
  }

  void _ifVerbosity(bool verbose, bool quiet, Function() func) {
    if (
      quiet ||
      (verbose && verbosity == JseVerbosity.verbose) ||
      (!verbose && verbosity.index > JseVerbosity.quiet.index)
    ) {
      func.call();
    }
  }

  @protected
  void _debug(String message, {bool verbose = true, bool quiet = false}) {
    _ifVerbosity(verbose, quiet, () => _log.add(LogItem.debug(message)));
  }

  @protected 
  void _echo(List<String> lines, {bool verbose = true, bool quiet = false}) {
    _ifVerbosity(verbose, quiet, () => _streamRequest(JseUiRequestEcho(lines)));
  }

  @protected
  Map<String,JsFunction> _builtinFuncsToJs(List<JseBuiltinFunc> funcs)
    => Map.fromEntries(
      funcs.map((f) => MapEntry(f.name, _wrapFunction(f.func)))
    );

  @protected
  JsFunction _wrapFunction(JseFunc func) => JsFunction(
    _engine.global,
    (en, args, ctx) {
      func.call(args);
      return null;
    });

  @protected
  void _addJsObjects(Map<String, JsObject> objs) {
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
        _debug("Starting engine", verbose: true);
        _streamState(JseState.Starting);

        _engine = JSEngine();
        
        await _ensureBuiltins();
        
        _streamState(JseState.Idle);
        
        _debug("Engine started", verbose: true);
        _streamOutput();
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

    _debug("Adding builtin functions", verbose: true);

    final mklog = (LogLevel level, {String funcName})
      => JseBuiltinFunc(
          funcName ?? level.toString().replaceAll("LogLevel.", ""),
          (JsArguments args) 
            => _log.add(LogItem(
              text:  args.valueOf.map((o) => o.toString()).join(" "),
              level: level
            )),
          1,
          doc: "Log a $level message to output"
        );

    final clear = JseBuiltinFunc(
        'clear', (args) {
          _streamRequest(JseUiRequestClear());
          return null;
        }, 0, doc: 'Clear output');

    final vardump = JseBuiltinFunc(
        'vardump', (args) {
          final vars = _getJseVariables();

          if (vars.length == 0) {
            _log.add(LogItem.debug('[vardump] no global variables set'));
          } else {
            _log.add(LogItem.debug('[vardump] found the following variables:'));
          }

          vars.forEach(
            (v) => _log.add(
              LogItem.debug("   ${v.name}: [${v.value.toString()}]")
            )
          );
          return null;
        }, 0, doc: "List global variables");

    final listBuiltins = JseBuiltinFunc(
      'builtins', 
      (_) {
        _log.add(LogItem.info("Found ${_addedBuiltins.length} builtins:"));
        _addedBuiltins.cast<JseBuiltinFunc>().forEach((b) {
          _log.add(LogItem.debug("   ${b.name}(${b.numArgs})"));
          _log.add(LogItem.info( "   ${b.doc}."));
        });
      },
      0, doc: 'List builtin functions'
    );

    final listSettings = JseBuiltinFunc(
      'settings',
      (_) {
        _streamRequest(JseUiRequestSettings());
      },
      0, doc: 'List current app settings'
    );

    final globFuncs = [
      vardump,
      listBuiltins,
      listSettings,
      mklog(LogLevel.debug, funcName: 'log')
    ];

    final globObjs = [
      JseBuiltinObject('console', [ 
        mklog(LogLevel.info, funcName: 'log'),
        mklog(LogLevel.trace),
        mklog(LogLevel.debug),
        mklog(LogLevel.warn),
        mklog(LogLevel.error),
        clear
      ],
      doc: 'Global console object')
    ];


    addJsFunctions(globFuncs);
    addJsObjectsWithFunctions(globObjs);

    _debug("Added ${globFuncs.length} functions, 1 object", verbose: true);

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
