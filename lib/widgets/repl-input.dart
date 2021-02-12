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
    final m = (a, b) => b.endsWith(a) || a.startsWith(b);

    return [
      ..._vars.where((v) => m(v.name, pattern))
            .map((v) => ReplSuggestion.variable(pattern, v))
            .toList(),
      ..._builtins.where((b) => m(b.name, pattern))
            .map((b) => ReplSuggestion.builtin(pattern, b))
            .toList(),
      ..._keywords.where((k) => m(k, pattern))
            .map((k) => ReplSuggestion.keyword(pattern, k))
            .toList(),
      ..._history.where((h) => m(h.content, pattern))
            .map((h) => ReplSuggestion.history(pattern, h))
            .toList()
    ].take(8).toList();
  }


  Widget _suggestionItemBuilder(BuildContext context, dynamic sugg) {
    final suggestion = sugg as ReplSuggestion;
    final around = suggestion.suggestion.split(suggestion.pattern);
    final left = around.first;
    final right = around.last;
    final ts = textStyleCode().copyWith(
      fontSize: Constants.fontSizeLarge,
      color: suggestion.color);
    final ss = textStyleBody().copyWith(
      fontSize: Constants.fontSizeBase,
      fontWeight: FontWeight.w300,
      color: suggestion.color);

    return ListTile(
      title: RichText(
        text: TextSpan(children: [
          TextSpan(text: left, style: ts),
          TextSpan(
            text: suggestion.pattern, 
            style: ts.copyWith(fontWeight: FontWeight.bold)
          ),
          TextSpan(text: right, style: ts)
        ])
      ),
      subtitle: Txt.p(suggestion.description, style: ss),
      leading: Icon(suggestion.icon, color: suggestion.color)
    );
  }

  void _onSuggestionSelected(dynamic sugg) {
    final suggestion = sugg as ReplSuggestion;
    _ctrl.text = _ctrl.text.replaceFirst(
      suggestion.pattern,
      suggestion.suggestion
    );
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
      itemBuilder:              _suggestionItemBuilder,
      onSuggestionSelected:     _onSuggestionSelected,
      suggestionsBoxController: _suggestionsCtrl,
      suggestionsCallback:      _getSuggestions,
      noItemsFoundBuilder: (_) => null,

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

enum SuggestionSource {
  history,
  variable,
  builtin,
  keyword
}

class ReplSuggestion {
  ReplSuggestion(this.source, this.pattern, this.suggestion, this.description);

  ReplSuggestion.history(this.pattern, InputHistoryModel model)
    : suggestion = model.content,
      description = model.timestamp.toIso8601String(),
      source = SuggestionSource.history;

  ReplSuggestion.variable(this.pattern, JseVariable model)
    : suggestion = model.name,
      description = "Global variable (${model.displayString})",
      source = SuggestionSource.variable;

  ReplSuggestion.builtin(this.pattern, JseBuiltinFunc model)
    : suggestion = model.name + "()",
      description = model.doc,
      source = SuggestionSource.builtin;
  
  ReplSuggestion.keyword(this.pattern, this.suggestion)
    : description = 'JavaScript keyword',
      source = SuggestionSource.keyword;

  final SuggestionSource source;
  final String pattern;
  final String suggestion;
  final String description;

  Color get color {
    final t = Constants.theme;
    switch (source) {
      case SuggestionSource.builtin:
        return Constants.colors.palePink;
      case SuggestionSource.variable:
        return t.varForeground;
      case SuggestionSource.history:
        return t.historyForeground;
      case SuggestionSource.builtin:
      default:
        return t.secondaryAccent;
    }
  }

  IconData get icon {
    switch (source) {
      case SuggestionSource.builtin:
        return LineAwesomeIcons.code;
      case SuggestionSource.variable:
        return Icons.code;
      case SuggestionSource.history:
        return Icons.history_rounded;
      case SuggestionSource.builtin:
      default:
        return LineAwesomeIcons.javascript__js_;
    }
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