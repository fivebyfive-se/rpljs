import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_typeahead_web/flutter_typeahead.dart';

import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'package:rpljs/config/constants.dart';

import 'package:rpljs/extensions/index.dart';

import 'package:rpljs/helpers/size-helpers.dart';
import 'package:rpljs/helpers/text-style-helpers.dart';

import 'package:rpljs/services/app-state.dart';
import 'package:rpljs/services/jse-service.dart';

import 'package:rpljs/widgets/txt.dart';

class ReplInputField extends StatefulWidget {
  ReplInputField({
    this.controller,
    this.history,
    this.variables, 
    this.builtins, 
    this.onSubmit
  });
  
  final ReplInputController controller;

  final List<InputHistoryModel> history;
  final List<JseVariable>    variables;
  final List<JseBuiltinFunc> builtins;
  
  final void Function()       onSubmit;

  @override
  _ReplInputFieldState createState() => _ReplInputFieldState();
}

class _ReplInputFieldState extends State<ReplInputField> {
  SuggestionsBoxController _suggestionsCtrl;

  ReplInputController get _ctrl => widget.controller;
  List<JseVariable> get _vars => widget.variables;
  List<JseBuiltin> get _builtins => widget.builtins;
  List<InputHistoryModel> get _history => widget.history;
  List<String> get _keywords => Constants.javascriptKeywords;

  Future<List<dynamic>> _getSuggestions(String pattern) async {
    if (pattern.isFalsy()) {
      return [];
    }
    final lastWord = pattern.split(RegExp(r'\b')).last;
    return [
      ..._vars.where((v) => v.name.startsWith(lastWord)).toList(),
      ..._builtins.where((b) => b.name.startsWith(lastWord)).toList(),
      ..._keywords.where((k) => k.startsWith(lastWord)).toList(),
      ..._history.where((v) => v.content.startsWith(pattern)).toList()
    ].take(7).toList();
  }

  Widget _suggestionTile({
    String left,
    String right,
    String subtitle,
    IconData icon,
    Color iconColor
  })

    => ListTile(
      title: RichText(
        text: TextSpan(children: [
          TextSpan(text: left, style: textStyleCode().copyWith(fontWeight: FontWeight.bold)),
          TextSpan(text: right, style: textStyleCode())
        ])
      ),
      subtitle: Txt.p(subtitle),
      leading: Icon(icon, color: iconColor)
    );

  Widget _suggestionItemBuilder(BuildContext context, dynamic suggestion) {
    final left = widget.controller.text.split(RegExp(r'\b')).last;
    String sugg = "";
    String subtitle = "";
    IconData icon;
    Color color;

    if (suggestion is InputHistoryModel) {
      sugg = suggestion.content; 
      subtitle = "Input history @${suggestion.timestamp.toIso8601String()}";
      icon = Icons.history;
      color = Constants.theme.historyForeground;
    } else if (suggestion is JseVariable) {
      sugg = suggestion.name;
      subtitle = "Global variable (${suggestion.displayString})";
      icon = LineAwesomeIcons.code;
      color = Constants.theme.varForeground;
    } else if (suggestion is JseBuiltin) {
      sugg = suggestion.name;
      subtitle = suggestion.doc;
      icon = LineAwesomeIcons.javascript__js__square;
      color = Constants.theme.varForeground.brighten(amt: 0.3);
    } else if (suggestion is String) {
      sugg = suggestion;
      subtitle = "JavaScript keyword";
      icon = LineAwesomeIcons.javascript__js_;
      color = Constants.theme.secondaryAccent;
    }
    final right = sugg.replaceFirst(left, "");
    return _suggestionTile(
      left: left,
      right: right,
      icon: icon,
      subtitle: subtitle,
      iconColor: color
    );
  }

  void _onSuggestionSelected(dynamic suggestion) {
    if (suggestion is InputHistoryModel) {
      _ctrl.text = suggestion.content;
    } else if (suggestion is JseBuiltinFunc) {
      final words = _ctrl.text.split(RegExp(r'\b'));
      final lastWord = words.removeLast();
      final suggestedWord = suggestion.name + "()";

      print("$lastWord => $suggestedWord");
      _ctrl.text = [...words, suggestedWord].join('');
      _ctrl.setCursor(
        position: _ctrl.text.length - (suggestion.numArgs == 0 ? 0 : 1)
      );
    } else {
      final words = _ctrl.text.split(RegExp(r'\b'));
      final lastWord = words.removeLast();
      final suggestedWord = (suggestion is JseVariable) 
        ? suggestion.name : suggestion;

      print("$lastWord => $suggestedWord");

      _ctrl.text = [...words, suggestedWord].join('');
    }
    _ctrl.requestFocus();
    _suggestionsCloseIfEmpty(closeAnyway: true);

    Future.delayed(
      Duration(milliseconds: 600),
      () {
        _suggestionsCtrl.close();
      }
    );
  }

  void _suggestionsCloseIfEmpty({bool closeAnyway = false, bool openIfNotEmpty = false}) {
    if (_ctrl.isEmpty || closeAnyway) {
      _suggestionsCtrl.close();
    } else if (_ctrl.isNotEmpty && openIfNotEmpty) {
      _suggestionsCtrl.open();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _suggestionsCtrl = SuggestionsBoxController();

    _suggestionsCtrl.close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Constants.theme;
    final inpIcon = (IconData i) => Icon(i, color: theme.inputAccent);
    final fireSubmit = () {
      widget.onSubmit?.call();
      _suggestionsCloseIfEmpty(closeAnyway: true);
    };

    return TypeAheadField(
      direction: AxisDirection.up,
      suggestionsCallback:  _getSuggestions,
      itemBuilder:          _suggestionItemBuilder,
      onSuggestionSelected: _onSuggestionSelected,
      suggestionsBoxController: _suggestionsCtrl,
      noItemsFoundBuilder: (ctx) => null,

      textFieldConfiguration: TextFieldConfiguration(
        autofocus: true,
        controller: _ctrl.controller,
        focusNode: _ctrl.focusNode,
        onSubmitted: (_) => fireSubmit(),
        style: textStyleCode().copyWith(color: theme.inputText),
        onChanged: (_) {
          _suggestionsCloseIfEmpty(openIfNotEmpty: true);
        },
        decoration: new InputDecoration(    
          contentPadding: padding(horizontal: 2, vertical: 1),                    
          fillColor: theme.inputBackground,
          prefixIcon: inpIcon(LineAwesomeIcons.dollar_sign),
          suffixIcon: IconButton(
            icon: inpIcon(Icons.subdirectory_arrow_left),
            onPressed: () => fireSubmit()
          )
        ),
      ),
    );
  }
}

class ReplInputController {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  TextEditingController
  get controller => _inputController;

  FocusNode
  get focusNode => _focusNode;

  bool
  get isEmpty    => _inputController.text.isFalsy();
  bool
  get isNotEmpty => _inputController.text.isTruthy();
  
  void requestFocus() {
    if (_focusNode.canRequestFocus) {
      _focusNode.requestFocus();
    }
  }

  void setCursor({int position = -1}) {
    final textLen = _inputController.text.length;
    final offset = position < 0
      ? position + textLen + 1
      : min(position, textLen); 

    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: offset)
    );
  }

  String
  get text => _inputController.text;
  set text(String input) {
    if (input == null || input == "") {
      _inputController.clear();
      requestFocus();
    } else {
      _inputController.text = input;
    }
    setCursor();
  }

  bool
  get validSelection => (
    _inputController.selection != null
      && _inputController.selection.isValid
  );

  void insertText(String newText) {
    if (validSelection) {
      final start = _inputController.selection.base.offset;
      final end   = _inputController.selection.extent.offset;
      final prefix = start == 0 || text[start - 1].isWhitespace() 
        ? "" : " "; // prefix with space, unless beginning of selection
                    // is at  beginning of text, or to the right of 
                    // an existing space. Mutatis mutandis for end
                    // of selection.
      final suffix = end == text.length || text[end].isWhitespace()
        ? "" : " ";
      final addText = "$prefix$newText$suffix";
      
      _inputController.text = text.replaceRange(start, end, addText);
      setCursor(position: end + addText.length);    
    } else {
      _inputController.text += newText;
      setCursor();    
    }
  }
}