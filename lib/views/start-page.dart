import 'dart:async';

import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:rpljs/config/constants.dart';
import 'package:rpljs/services/jse-service.dart';
import 'package:rpljs/services/models/jse-exception.dart';
import 'package:rpljs/services/models/jse-parse-result.dart';
import 'package:rpljs/services/models/jse-state.dart';
import 'package:rpljs/services/models/jse-ui-request.dart';
import 'package:rpljs/services/models/jse-variable.dart';
import 'package:rpljs/services/models/log-item.dart';
import 'package:rpljs/services/terminal-controller-service.dart';
import 'package:rpljs/theme/size-helpers.dart';
import 'package:rpljs/theme/text-style-helpers.dart';
import 'package:rpljs/views/base/page-arguments.dart';
import 'package:rpljs/views/base/page-base.dart';
import 'package:rpljs/views/base/page-navigator.dart';
import 'package:rpljs/widgets/builders/app-state-builder.dart';
import 'package:rpljs/widgets/repl-input.dart';
import 'package:rpljs/widgets/scaffold/page.dart';
import 'package:rpljs/widgets/terminal.dart';

class StartPage extends PageBase<StartPageArguments> {
  StartPage() : super(showDrawer: true);

  static const String routeName = '/';
  static const String title = 'Start';

  final List<TerminalChunk> welcomeMessage = <TerminalChunk>[
    TerminalChunk.one("Welcome to Rpljs", color: Constants.theme.primaryAccent),
    TerminalChunk.one(""),
    TerminalChunk(<String>[
      "Please enter some JavaScript code ",
      "in the input field below.",
      "To output a value, use the command `log`:"
    ]),
    TerminalChunk.one("      log(123 + 321)",
      color: Constants.theme.secondaryAccent)
    
  ];

  static StartPageNavigator get route => StartPageNavigator();

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final JseService  _jseService = JseService.getInstance();

  List<JseVariable> _jseVariables = [];
  JseState          _jseState;

  TerminalControllerService _terminalCtrl 
    = TerminalControllerService.getInstance();

  ReplInputController _inputController;


  void _handleJseError(JseException error) {
    print(error);
  }

  /// Translates requests between JseService and Terminal
  void _handleJseUiRequest(JseUiRequest request) {
    if (request is JseUiRequestLog) {
      _terminalCtrl.print(
        request.items.map((li) => TerminalChunk.fromLogItem(li)).toList()
      );
    } else if (request is JseUiRequestClear) {
      _terminalCtrl.clear();
    }
  }

  void _handleJseState(JseState nextState) => _jseState = nextState;

  void _handleJseVariables(List<JseVariable> variables) {
    _jseVariables
      ..clear()
      ..addAll(variables);
  }

  Future<void> _handleInput() async {
    _initJseService();

    await _jseService.parseJs(_inputController.text);
    _inputController.text = "";
  }


  void _initJseService() {
    if (_jseState == null) {
      _jseState = _jseService.currentState;
      _jseService.globals.listen(_handleJseVariables);
      _jseService.state.listen(_handleJseState);
      _jseService.uiRequests.listen(_handleJseUiRequest);
      _jseService.errors.listen(_handleJseError);
    }
  }

  void _initInput() {
    _inputController = ReplInputController();
  }

  void _printWelcomeMessage()
    => _terminalCtrl.print(widget.welcomeMessage);

  @override
  void initState() {
    super.initState();

    _initInput();
    _printWelcomeMessage();
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
            _handleInput();
          };

          return Column(
            children: [
              Expanded(
                flex: 6,
                child: Terminal(
                  stream: _terminalCtrl.stream,
                  initialData: _terminalCtrl.currentState,
                  style: textStyleCode(),
                )
              ),
              Expanded(
                flex: 1,
                child: ReplInputField(
                  controller: _inputController,
                  onSubmit: handleInput
                ),
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