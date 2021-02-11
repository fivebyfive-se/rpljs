import 'dart:math';

import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:rpljs/config/constants.dart';
import 'package:rpljs/extensions/string-extensions.dart';
import 'package:rpljs/theme/size-helpers.dart';
import 'package:rpljs/theme/text-style-helpers.dart';

class ReplInputField extends StatelessWidget {
  ReplInputField({this.controller, this.onSubmit});
  
  final ReplInputController controller;
  final void Function()       onSubmit;

  @override
  Widget build(BuildContext context) {
    final inpIcon = 
      (IconData i) => Icon(i, color: Constants.theme.inputAccent);

    return TextField(
      controller: controller.controller,
      focusNode: controller.focusNode,
      onSubmitted: (_) => onSubmit?.call(),
      style: textStyleCode().copyWith(color: Constants.theme.inputText),
      decoration: new InputDecoration(    
        contentPadding: padding(horizontal: 2, vertical: 1),                    
        fillColor: Constants.theme.inputBackground,
        prefixIcon: inpIcon(LineAwesomeIcons.dollar_sign),
        suffixIcon: IconButton(
          icon: inpIcon(Icons.subdirectory_arrow_left),
          onPressed: () => onSubmit?.call()
        )
      ),
    );
  }
}

class ReplInputController {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  TextEditingController get controller => _inputController;
  FocusNode get focusNode => _focusNode;
  
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

  String get text => _inputController.text;
  set text(String input) {
    if (input == null || input == "") {
      _inputController.clear();
      requestFocus();
    } else {
      _inputController.text = input;
    }
    setCursor();
  }

  bool get validSelection => (
    _inputController.selection != null
      && _inputController.selection.isValid
  );

  void insertText(String text) {
    if (validSelection) {
      final currText = _inputController.text;
      final start = _inputController.selection.base.offset;
      final end   = _inputController.selection.extent.offset;
      final prefix = start == 0 || currText[start - 1].isWhitespace() 
        ? "" : " ";
      final suffix = end == currText.length || currText[end].isWhitespace()
        ? "" : " ";
      final addText = "$prefix$text$suffix";
      
      _inputController.text = currText.replaceRange(start, end, addText);
      setCursor(position: end + addText.length);    
    } else {
      _inputController.text += text;
      setCursor();    
    }
  }
}