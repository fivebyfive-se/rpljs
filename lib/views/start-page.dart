import 'dart:async';

import 'package:dartjsengine/dartjsengine.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'package:rpljs/config/index.dart';

import 'package:rpljs/helpers/index.dart';

import 'package:rpljs/services/app-state.dart';
import 'package:rpljs/services/jse-service.dart';
import 'package:rpljs/services/terminal-controller-service.dart';

import 'package:rpljs/views/base/index.dart';
import 'package:rpljs/views/settings-page.dart';

import 'package:rpljs/widgets/builders/app-state-builder.dart';
import 'package:rpljs/widgets/scaffold/page.dart';

import 'package:rpljs/widgets/horizontal-chips.dart';
import 'package:rpljs/widgets/list-dialog-button.dart';
import 'package:rpljs/widgets/repl-input.dart';
import 'package:rpljs/widgets/terminal.dart';
import 'package:rpljs/widgets/txt.dart';


class StartPage extends PageBase<StartPageArguments> {
  StartPage() : super(showDrawer: true);

  static const String routeName = '/';
  static const String title = 'Start';

  final List<TerminalChunk> welcomeMessage = <TerminalChunk>[
    TerminalChunk.one("#Welcome to Rpljs", color: Constants.theme.primaryAccent),
    TerminalChunk(<String>[
"Please enter some JavaScript code in",
"the input field below.  To output a ",
"value, use the command `log`:"
    ]),
    TerminalChunk.one("    log(123 + 321)", 
      color: Constants.theme.secondaryAccent),
    TerminalChunk.one("To list all global variables, use:"),
    TerminalChunk.one("    vardump()", color: Constants.theme.tertiaryAccent),
    
  ];

  static StartPageNavigator get route => StartPageNavigator();

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final JseService       _jseService = JseServiceProvider.getInstance();
  final Stream<AppState> _appStateStream = AppStateProvider.getInstance().stream;
  final Map<String,bool> _runSnippets = <String,bool>{};
  AppState             _appState = AppStateProvider.getInstance().snapshot;
  List<JseVariable>    _jseVariables = [];
  List<JseBuiltinFunc> _jseBuiltins  = [];
  JseState             _jseState;

  TerminalControllerService _terminalCtrl 
    = TerminalControllerService.getInstance();

  ReplInputController _inputController;
  ScrollController _termScrollController;

  void _jseErrorHandler(JseException error) {
    print(error);
  }

  /// Translates requests between JseService and Terminal
  void _jseUiRequestHandler(JseUiRequest request) {
    if (request is JseUiRequestLog) {
      _terminalCtrl.print(
        request.items.map((li) => TerminalChunk.fromLogItem(li)).toList()
      );
    } else if (request is JseUiRequestEcho) {
      _terminalCtrl.echo(request.lines);
    } else if (request is JseUiRequestClear) {
      _terminalCtrl.clear();
    } else if (request is JseUiRequestSettings) {
      _terminalCtrl.print([TerminalChunk([
        "#appState.config:",
        "verbosity:       ${_appState.config.verbosity}",
        "hideSuggestions: ${_appState.config.hideSuggestions}"
      ], color: Constants.theme.quaternaryAccent)]);
    }
    _terminalUpdateScroll();
  }

  void _jseStateHandler(JseState nextState) => _jseState = nextState;

  void _jseVariablesHandler(List<JseVariable> variables) {
    _jseVariables
      ..clear()
      ..addAll(variables);
    setState(() {});
  }

  void _jseBuiltinsHandler(List<JseBuiltin> builtins) {
    _jseBuiltins.clear();

    builtins.forEach((b) { 
      if (b is JseBuiltinObject) {
        _jseBuiltins.addAll(b.funcs);
      } else if (b is JseBuiltinFunc) {
        _jseBuiltins.add(b);
      }
    });

    setState(() {});
  }

  void _jseServiceInit() {
    if (_jseState == null) {
      _jseState = _jseService.currentState;
      _jseService.globals.listen(_jseVariablesHandler);
      _jseService.builtins.listen(_jseBuiltinsHandler);
      _jseService.state.listen(_jseStateHandler);
      _jseService.uiRequests.listen(_jseUiRequestHandler);
      _jseService.errors.listen(_jseErrorHandler);
    }
    _jseService.init();
  }

  Future<void> _jseParse(String code) async {
    _jseService.verbosity = _appState.config.verbosity;
    await _jseService.parseJs(code);
  }

  Future<void> _jseParseSnippet(SnippetModel snippet) async {
    if (!_runSnippets.containsKey(snippet.uuid)) {
      await _jseParse(snippet.toJavaScript());
      _runSnippets[snippet.uuid] = true;
    }
  }

  Future<void> _inputHandler() async {
    if (_inputController.isNotEmpty) {
      await _jseParse(_inputController.text);
      _inputController.text = "";
    }
  }

  void _inputInit() {
    _inputController = ReplInputController();
  }

  void _terminalInit() {
    _termScrollController = ScrollController();
    _terminalCtrl.print(widget.welcomeMessage);
  }

  void _terminalUpdateScroll() {
    if (_termScrollController.hasClients && _termScrollController.position != null) {
      Future.delayed(
        Duration(milliseconds: 200),
        () => _termScrollController.animateTo(
          _termScrollController.position.maxScrollExtent ?? 0,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut
        )
      );
    }
  }

  void _appStateHandler(AppState appState) {
    _appState = appState;
    _appState.snippets
      .where((s) => s.runOnInit && !_runSnippets.containsKey(s.uuid))
      .forEach((snippet) => _jseParseSnippet(snippet));
  }   

  void _appStateInit()
    => _appStateStream.listen(_appStateHandler);


  @override
  void initState() {
    super.initState();
    
    _jseServiceInit();
    _inputInit();
    _terminalInit();
    _appStateInit();
  }

  @override
  Widget build(BuildContext rootContext) => AppStateBuilder(
    builder: (context, appState, appStateProvider) 
      => scaffoldPage(
        context: context,
        drawer: true,
        builder: (context, arguments) {

          final handleInput = () {
            if (_inputController.text != "") {
              appStateProvider.pushHistory(_inputController.text);
            }
            _inputHandler();
          };

          return Column(
            children: [
              flexp(8,
                Terminal(
                  controller: _termScrollController,
                  initialData: _terminalCtrl.currentState,
                  stream: _terminalCtrl.stream,
                  style: textStyleCode(),
                )
              ),
              _jseVariables.isEmpty ? spex(1) : flexp(1,
                Row(
                  children: [
                    flexp(2, Txt.h2("Vars:", extraTypes: [TxtType.code],)),
                    flexp(22, HorizontalChips<JseVariable>(
                      items: [..._jseVariables],
                      labelConverter: (v) => v.toString(),
                      tooltipConverter: (v) => "Insert ${v.name} in input field",
                      onPressed: (v) => _inputController.insertText(
                        v.name + ((v.jsObject is JsFunction) ? '()' : '')  
                      ),
                      backgroundColor: Constants.theme.varBackground,
                      textColor: Constants.theme.varForeground,
                    ))
                  ]
                )
              ),
              
              flexp(3,
                Container(
                  padding: padding(horizontal: 1, vertical: 2),
                  margin: marginOnly(top: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Constants.theme.inputBackground.withAlpha(0x00),
                        Constants.theme.inputBackground.withAlpha(0x80)
                      ]
                    )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    flexp(1,
                      ListDialogButton<SnippetModel>(
                        icon: LineAwesomeIcons.javascript__js_,
                        color: appState.snippets.isEmpty 
                          ? Constants.theme.foregroundDisabled
                          : Constants.theme.foreground,
                        dialogTitle: 'Snippets',
                        tooltip: 'JS snippets',
                        itemBuilder: (context) => [
                          ...appState.snippets.map((snippet) 
                            => ListDialogItem<SnippetModel>(
                              value: snippet,
                              child: ListTile(
                                title: Txt.h2(snippet.label),
                                subtitle: Txt.p(snippet.content),
                                trailing: btnIcon(
                                  icon: Icons.edit,
                                  color: Constants.theme.secondaryAccent,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pushNamed(
                                      SettingsPage.routeName,
                                      arguments: SettingsPageArguments(editItem: snippet.uuid)
                                    );
                                  }
                                ),
                                onTap: () {
                                  _jseParseSnippet(snippet);
                                  Navigator.of(context).pop();
                                }
                              )
                            ))
                        ],
                      )
                    ),
                    flexp(11, ReplInputField(
                      controller: _inputController,
                      onSubmit: handleInput,
                      history: appState.history,
                      variables: _jseVariables,
                      builtins: _jseBuiltins,
                      hideSuggestions: appState.config.hideSuggestions
                    ))
                  ])
                )
              )
            ],
          );
        }
      )
    );
}

class StartPageNavigator extends PageNavigator<StartPage,PageArguments> {
  StartPageNavigator() : super(routeName: StartPage.routeName);
}

class StartPageArguments extends PageArguments {
  StartPageArguments() 
  : super(routeName: StartPage.routeName);
}